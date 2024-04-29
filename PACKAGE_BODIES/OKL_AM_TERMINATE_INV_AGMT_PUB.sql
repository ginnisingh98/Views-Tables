--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMINATE_INV_AGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMINATE_INV_AGMT_PUB" AS
/* $Header: OKLPTIAB.pls 115.2 2003/10/20 22:14:52 rmunjulu noship $ */

  -- Start of comments
  --
  -- Procedure Name  : terminate_investor_agreement
  -- Description     : procedure to terminate investor agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU 3061748 Created
  --
  -- End of comments
  PROCEDURE terminate_investor_agreement(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_ia_rec         IN   ia_rec_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL) IS

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

  BEGIN

       -- *************
       -- Create Savepoint
       -- *************

       SAVEPOINT terminate_ia_trx;

       -- *************
       -- Call PVT Terminate IA Prog
       -- *************

       OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement(
                 p_api_version     =>  p_api_version,
                 p_init_msg_list   =>  G_FALSE,
                 x_return_status   =>  l_return_status,
                 x_msg_count       =>  x_msg_count,
                 x_msg_data        =>  x_msg_data,
                 p_ia_rec          =>  p_ia_rec,
                 p_control_flag    =>  p_control_flag);

       -- Raise exception if error
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE G_EXCEPTION_ERROR;
       END IF;

       -- *************
       -- Set the return status
       -- *************

       x_return_status := l_return_status;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO terminate_ia_trx;
            x_return_status := G_RET_STS_ERROR;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO terminate_ia_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN
            ROLLBACK TO terminate_ia_trx;

            -- Set the oracle error message
            OKL_API.set_message(
                 p_app_name      => G_APP_NAME_1,
                 p_msg_name      => G_UNEXPECTED_ERROR,
                 p_token1        => G_SQLCODE_TOKEN,
                 p_token1_value  => SQLCODE,
                 p_token2        => G_SQLERRM_TOKEN,
                 p_token2_value  => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;

  END terminate_investor_agreement;

  -- Start of comments
  --
  -- Procedure Name  : concurrent_expire_inv_agrmt
  -- Description     : This procedure is called by concurrent manager to terminate
  --                   ended investor agreements. When running the concurrent
  --                   manager request, a request can be made for a single IA to
  --                   be terminated or else all the ended IAs will be picked
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU 3061748 Created
  --
  -- End of comments
  PROCEDURE concurrent_expire_inv_agrmt(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                    p_ia_id          IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL) IS

  BEGIN

          -- Call the PVT conc prog
          OKL_AM_TERMINATE_INV_AGMT_PVT.concurrent_expire_inv_agrmt(
                       errbuf           => errbuf,
                       retcode          => retcode,
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       p_ia_id          => p_ia_id,
                       p_date           => p_date);

  EXCEPTION

     WHEN OTHERS THEN
         -- Set the oracle error message
         OKL_API.set_message(
            p_app_name      => G_APP_NAME_1,
            p_msg_name      => G_UNEXPECTED_ERROR,
            p_token1        => G_SQLCODE_TOKEN,
            p_token1_value  => SQLCODE,
            p_token2        => G_SQLERRM_TOKEN,
            p_token2_value  => SQLERRM);

  END concurrent_expire_inv_agrmt;

END OKL_AM_TERMINATE_INV_AGMT_PUB;

/
