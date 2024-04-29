--------------------------------------------------------
--  DDL for Package Body OKL_OVERRIDE_TAX_BASIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OVERRIDE_TAX_BASIS_PVT" AS
/* $Header: OKLROTBB.pls 120.0 2005/08/26 19:58:14 sechawla noship $ */

  -- Start of comments
  --
  -- Procedure Name  : override_tax_basis
  -- Description     : procedure to create or update rec in OKL_TAX_BASIS_OVERRIDE
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SECHAWLA -  Created
  --
  -- End of comments
  PROCEDURE override_tax_basis(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_rec                     IN tbov_rec_type,
    x_tbov_rec                     OUT NOCOPY tbov_rec_type) IS

        l_api_name VARCHAR2(30) := 'override_tax_basis';
      	l_api_version CONSTANT NUMBER := G_API_VERSION;
        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

	-- Check if record already exists in okl_tax_basis_override
    CURSOR l_taxbasis_csr(cp_try_id IN NUMBER, cp_org_id IN NUMBER) IS
    SELECT 'x'
    FROM   okl_tax_basis_override
    WHERE  try_id = cp_try_id
    AND    org_id = cp_org_id;

    l_dummy 				VARCHAR2(1);


  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_OVERRIDE_TAX_BASIS_PVT.override_tax_basis',
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


       OPEN  l_taxbasis_csr(p_tbov_rec.try_id, p_tbov_rec.org_id);
       FETCH l_taxbasis_csr INTO l_dummy;
       IF l_taxbasis_csr%FOUND THEN
          OKL_TAX_BASIS_OVERRIDE_PUB.update_tax_basis_override
		           (p_api_version    => p_api_version,
                    p_init_msg_list  => G_FALSE,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_tbov_rec       => p_tbov_rec,
                    x_tbov_rec       => x_tbov_rec);

          -- raise exception if api returns error
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
          END IF;
	   ELSE
	      -- Call TAPI insert
          OKL_TAX_BASIS_OVERRIDE_PUB.insert_tax_basis_override
                    (p_api_version    => p_api_version,
                    p_init_msg_list  => G_FALSE,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_tbov_rec       => p_tbov_rec,
                    x_tbov_rec       => x_tbov_rec);

          -- raise exception if api returns error
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
          END IF;
	   END IF;
       CLOSE l_taxbasis_csr;


       x_return_status := l_return_status;

       -- End Activity
       OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_OVERRIDE_TAX_BASIS_PVT.override_tax_basis',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
			IF l_taxbasis_csr%ISOPEN THEN
			   CLOSE l_taxbasis_csr;
			END IF;
            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_OVERRIDE_TAX_BASIS_PVT.override_tax_basis',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            IF l_taxbasis_csr%ISOPEN THEN
			   CLOSE l_taxbasis_csr;
			END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_OVERRIDE_TAX_BASIS_PVT.override_tax_basis',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            IF l_taxbasis_csr%ISOPEN THEN
			   CLOSE l_taxbasis_csr;
			END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OTHERS',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_OVERRIDE_TAX_BASIS_PVT.override_tax_basis',
                             'EXP - OTHERS');
           END IF;
  END override_tax_basis;

  -- Start of comments
  --
  -- Procedure Name  : override_tax_basis
  -- Description     : procedure to create or update rec in OKL_TAX_BASIS_OVERRIDE
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SMODUGA -  Created
  --
  -- End of comments
  PROCEDURE override_tax_basis(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_tbl                    IN tbov_tbl_type,
    x_tbov_tbl                    OUT NOCOPY tbov_tbl_type) IS
        l_api_name VARCHAR2(30) := 'override_tax_basis';
      	l_api_version CONSTANT NUMBER := G_API_VERSION;
        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        i                              NUMBER := 0;
  BEGIN
       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_OVERRIDE_TAX_BASIS_PVT.override_tax_basis',
                         'Begin(+)');
       END IF;
       OKL_API.init_msg_list(p_init_msg_list);
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
       IF (p_tbov_tbl.COUNT > 0) THEN
      i := p_tbov_tbl.FIRST;
      LOOP

        override_tax_basis(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tbov_rec                     => p_tbov_tbl(i),
          x_tbov_rec                     => x_tbov_tbl(i));
        EXIT WHEN (i = p_tbov_tbl.LAST);
        i := p_tbov_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_OVERRIDE_TAX_BASIS_PVT.override_tax_basis',
                             'EXP - OTHERS');
           END IF;
  END override_tax_basis;

END OKL_OVERRIDE_TAX_BASIS_PVT;

/
