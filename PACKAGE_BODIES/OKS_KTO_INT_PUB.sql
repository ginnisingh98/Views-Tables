--------------------------------------------------------
--  DDL for Package Body OKS_KTO_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_KTO_INT_PUB" AS
/* $Header: OKSPORDB.pls 120.1 2006/02/08 04:22:30 gchadha noship $ */


-------------------------------------------------------------------------------
--
-- global package structures
--
-------------------------------------------------------------------------------
--
-- global constants
--
G_EXCEPTION_HALT_VALIDATION     EXCEPTION;
G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(200) := 'OKS_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN        	        CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_KTO_INT_PUB';
G_APP_NAME			CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_API_TYPE                      VARCHAR2(30)           := '_PROCESS';

L_LOG_ENABLED			VARCHAR2(200);


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


PROCEDURE create_order_from_k(ERRBUF             OUT NOCOPY VARCHAR2
			      ,RETCODE           OUT NOCOPY NUMBER
			      ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
                              ,p_default_date    IN DATE  DEFAULT OKC_API.G_MISS_DATE
                              ,P_Customer_id     IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_Grp_id          IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_org_id          IN  NUMBER DEFAULT OKC_API.G_MISS_NUM
			      ,P_contract_hdr_id_lo IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_hdr_id_hi IN NUMBER DEFAULT OKC_API.G_MISS_NUM
			      -- Bug 4915691 --
     		              ,P_contract_line_id_lo in NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_line_id_hi in NUMBER DEFAULT OKC_API.G_MISS_NUM
			      -- Bug 4915691 --
                              ) IS

l_api_version           CONSTANT NUMBER := 1;
lx_order_id             okx_order_headers_v.id1%TYPE := NULL;
lx_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count            NUMBER := 0;
lx_msg_data             VARCHAR2(2000);
l_trace_mode            VARCHAR2(1) := OKC_API.G_TRUE;
l_contract_id           NUMBER;
l_Customer_id           NUMBER;
l_Grp_id                NUMBER;
l_org_id                NUMBER;
l_contract_hdr_id_lo    NUMBER;
l_contract_hdr_id_hi    NUMBER;



BEGIN
  --
  -- call full version of create_order_from_k
  --
  OKS_KTO_INT_PUB.create_order_from_k(p_api_version   => l_api_version
                                    ,p_init_msg_list => OKC_API.G_TRUE
                                    ,p_commit        => OKC_API.G_TRUE
                                    ,x_return_status => lx_return_status
                                    ,x_msg_count     => lx_msg_count
                                    ,x_msg_data      => lx_msg_data
                                    ,p_contract_id   => p_contract_id
                                    ,p_default_date  => p_default_date
                                    ,P_Customer_id   => p_Customer_id
                                    ,P_Grp_id        => p_Grp_id
                                    ,P_org_id        => p_org_id
			            ,P_contract_hdr_id_lo  => p_contract_hdr_id_lo
                                    ,P_contract_hdr_id_hi => p_contract_hdr_id_hi
				    -- BUG 4915691 --
		                    ,P_contract_line_id_lo  => p_contract_line_id_lo
                                    ,P_contract_line_id_hi => p_contract_line_id_hi
				    -- BUG 4915691 --
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

PROCEDURE create_order_from_k(p_api_version       IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                             ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,p_commit            IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_return_status     OUT NOCOPY VARCHAR2
                             ,x_msg_count         OUT NOCOPY NUMBER
                             ,x_msg_data          OUT NOCOPY VARCHAR2
			     ,p_contract_id       IN  okc_k_headers_b.ID%TYPE
                             ,p_default_date      IN DATE  DEFAULT OKC_API.G_MISS_DATE
                              ,P_Customer_id     IN NUMBER     DEFAULT  OKC_API.G_MISS_NUM
                              ,P_Grp_id          IN NUMBER      DEFAULT OKC_API.G_MISS_NUM
                              ,P_org_id          IN  NUMBER     DEFAULT OKC_API.G_MISS_NUM
			      ,P_contract_hdr_id_lo in NUMBER    DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_hdr_id_hi in NUMBER    DEFAULT OKC_API.G_MISS_NUM
			       -- Bug 4915691 --
   			      ,P_contract_line_id_lo in NUMBER    DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_line_id_hi in NUMBER    DEFAULT OKC_API.G_MISS_NUM
                               -- Bug 4915691 --
                              ,x_order_id        OUT NOCOPY okx_order_headers_v.id1%TYPE
                             ) Is

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
  -- call the main routine
  OKS_OC_INT_KTO_PVT.create_order_from_k(p_api_version   => l_api_version
                                        ,p_init_msg_list => OKC_API.G_FALSE
                                        ,x_return_status => lx_return_status
                                        ,x_msg_count     => lx_msg_count
                                        ,x_msg_data      => lx_msg_data
         		                ,p_contract_id   => p_contract_id
                                        ,p_default_date   => p_default_date
                                        ,P_Customer_id   => p_Customer_id
                                        ,P_Grp_id        => p_Grp_id
                                        ,P_org_id        => p_org_id
			                ,P_contract_hdr_id_lo  => p_contract_hdr_id_lo
                                        ,P_contract_hdr_id_hi => p_contract_hdr_id_hi
					-- Bug 4915691 --
					,P_contract_line_id_lo  => p_contract_line_id_lo
                                        ,P_contract_line_id_hi => p_contract_line_id_hi
       				        -- Bug 4915691 --
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



END OKS_KTO_INT_PUB;

/
