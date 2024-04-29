--------------------------------------------------------
--  DDL for Package Body OKL_AM_SYSTEM_PARAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SYSTEM_PARAMS_PUB" AS
/* $Header: OKLPASAB.pls 115.0 2003/10/17 21:20:13 rmunjulu noship $ */

  -- Start of comments
  --
  -- Procedure Name  : process_system_params
  -- Description     : procedure to create or update rec in OKL_SYSTEM_PARAMS_ALL_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE process_system_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type) IS

        l_api_name VARCHAR2(30) := 'process_system_params';
      	l_api_version CONSTANT NUMBER := G_API_VERSION;
        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_SYSTEM_PARAMS_PUB.process_system_params',
                         'Begin(+)');
       END IF;

       -- Check API version, initialize message list and create savepoint
       l_return_status := OKL_API.start_activity(
                                       p_api_name      => l_api_name,
                                       p_pkg_name      => G_PKG_NAME,
                                       p_init_msg_list => p_init_msg_list,
                                       l_api_version   => l_api_version,
                                       p_api_version   => p_api_version,
                                       p_api_type      => '_PVT',
                                       x_return_status => x_return_status);

       -- Rollback if error setting activity for api
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Call PVT Process
       OKL_AM_SYSTEM_PARAMS_PVT.process_system_params(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => G_FALSE,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec,
                    x_sypv_rec       => x_sypv_rec);

       -- raise exception if api returns error
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

       x_return_status := l_return_status;

       -- End Activity
       OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_SYSTEM_PARAMS_PUB.process_system_params',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_SYSTEM_PARAMS_PUB.process_system_params',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_SYSTEM_PARAMS_PUB.process_system_params',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OTHERS',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_SYSTEM_PARAMS_PUB.process_system_params',
                             'EXP - OTHERS');
           END IF;
  END process_system_params;

END OKL_AM_SYSTEM_PARAMS_PUB;

/
