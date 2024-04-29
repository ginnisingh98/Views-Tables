--------------------------------------------------------
--  DDL for Package Body OKL_VAR_INT_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VAR_INT_PARAMS_PVT" AS
/* $Header: OKLRVIRB.pls 120.0 2005/09/28 10:16:02 dkagrawa noship $ */

  -------------------------------------------------------------------------------
  -- PROCEDURE create_var_int_params
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_var_int_params
  -- Description     : This procedure is a wrapper that creates interest rate parameters for
  --                 : variable rate interest
  --
  -- Business Rules  : this procedure is used to create Variable rate Parameters
  --                   this procedure inserts records into the OKL_VAR_INT_PARAMS_V  table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 29-JUL-2005 dkagrawa created
  -- End of comments

  PROCEDURE create_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_rec      IN  virv_rec_type,
                                  x_virv_rec      OUT NOCOPY virv_rec_type)IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'create_var_int_params';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Record/Table Type Declarations
    l_virv_rec		virv_rec_type;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VAR_INT_PARAMS_PVT.create_var_int_params';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVISB.pls call create_var_int_params for record');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_virv_rec := p_virv_rec;

    -- call the TAPI insert_row to create varaible rate parameters
    OKL_VIR_PVT.insert_row(p_api_version       => p_api_version
                          ,p_init_msg_list     => p_init_msg_list
                          ,x_return_status     => x_return_status
                          ,x_msg_count         => x_msg_count
                          ,x_msg_data          => x_msg_data
                          ,p_virv_rec          => l_virv_rec
                          ,x_virv_rec          => x_virv_rec);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_vir_pvt.insert_row returned with status '||x_return_status||' id '||x_virv_rec.id
                              );
    END IF;

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                   ,x_msg_data	=> x_msg_data
                         );

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVISB.pls call create_var_int_params for record');
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
  END create_var_int_params;


-------------------------------------------------------------------------------
  -- PROCEDURE create_var_int_params
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_var_int_params
  -- Description     : This procedure is a wrapper that creates interest rate parameters for
  --                 : variable rate interest
  --
  -- Business Rules  : this procedure is used to create Variable rate Parameters
  --                   this procedure inserts records into the OKL_VAR_INT_PARAMS_V  table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 29-JUL-2005 dkagrawa created
  -- End of comments

  PROCEDURE create_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_tbl      IN  virv_tbl_type,
                                  x_virv_tbl      OUT NOCOPY virv_tbl_type)IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'create_var_int_params';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Record/Table Type Declarations
    l_virv_tbl   virv_tbl_type;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VAR_INT_PARAMS_PVT.create_var_int_params';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVISB.pls call create_var_int_params for table');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_virv_tbl := p_virv_tbl;

    -- call the TAPI insert_row to create varaible rate parameters
    OKL_VIR_PVT.insert_row(p_api_version       => p_api_version
                          ,p_init_msg_list     => p_init_msg_list
                          ,x_return_status     => x_return_status
                          ,x_msg_count         => x_msg_count
                          ,x_msg_data          => x_msg_data
                          ,p_virv_tbl          => l_virv_tbl
                          ,x_virv_tbl          => x_virv_tbl);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_vir_pvt.insert_row returned with status '||x_return_status
                              );
    END IF;

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count
                         ,x_msg_data  => x_msg_data
                         );

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVISB.pls call create_var_int_params for table');
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
  END create_var_int_params;

  -------------------------------------------------------------------------------
  -- PROCEDURE update_var_int_params
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_var_int_params
  -- Description     : This procedure is a wrapper that updates the Variable rate parameters
  --                   for a record
  --
  -- Business Rules  : this procedure is used to update Variable rate Parameters
  --                   this procedure updates records of the OKL_VAR_INT_PARAMS_V table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 01-AUG-2005 dkagrawa created
  -- End of comments

  PROCEDURE update_var_int_params(p_api_version   IN  NUMBER,
                                     p_init_msg_list IN  VARCHAR2,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER,
                                     x_msg_data      OUT NOCOPY VARCHAR2,
                                     p_virv_rec      IN  virv_rec_type,
                                     x_virv_rec      OUT NOCOPY virv_rec_type) IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'update_var_int_params';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Record/Table Type Declarations
    l_virv_rec    virv_rec_type;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VAR_INT_PARAMS_PVT.update_var_int_params';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'start debug OKLRVISB.pls call update_var_int_params for record');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_virv_rec := p_virv_rec;

    -- call the TAPI update_row to update variable rate parametrs
    OKL_VIR_PVT.update_row(p_api_version    => p_api_version
                          ,p_init_msg_list  => p_init_msg_list
                          ,x_return_status  => x_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data
                          ,p_virv_rec       => l_virv_rec
                          ,x_virv_rec       => x_virv_rec);
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,'okl_vir_pvt.update_row returned with status '||x_return_status||' id '||x_virv_rec.id
                             );
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                  ,x_msg_data	=> x_msg_data
                        );

    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'ends debug OKLRVISB.pls call update_var_int_params for record');
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
  END update_var_int_params;

  -------------------------------------------------------------------------------
  -- PROCEDURE update_var_int_params
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_var_int_params
  -- Description     : This procedure is a wrapper that updates the Variable rate parameters
  --                   for a table
  --
  -- Business Rules  : this procedure is used to update Variable rate Parameters
  --                   this procedure updates records of the OKL_VAR_INT_PARAMS_V table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 01-AUG-2005 dkagrawa created
  -- End of comments

  PROCEDURE update_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_tbl      IN  virv_tbl_type,
                                  x_virv_tbl      OUT NOCOPY virv_tbl_type) IS
     -- Variables Declarations
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'update_var_int_params';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Record/Table Type Declarations
    l_virv_tbl    virv_tbl_type;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VAR_INT_PARAMS_PVT.update_var_int_params';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'start debug OKLRVISB.pls call update_var_int_params for table');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_virv_tbl := p_virv_tbl;

    -- call the TAPI update_row to update variable rate parametrs
    OKL_VIR_PVT.update_row(p_api_version    => p_api_version
                          ,p_init_msg_list  => p_init_msg_list
                          ,x_return_status  => x_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data
                          ,p_virv_tbl       => l_virv_tbl
                          ,x_virv_tbl       => x_virv_tbl);
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,'okl_vir_pvt.update_row returned with status '||x_return_status
                             );
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data => x_msg_data
                        );
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'ends debug OKLRVISB.pls call update_var_int_params for table');
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
  END update_var_int_params;

  -------------------------------------------------------------------------------
  -- PROCEDURE delete_var_int_params
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_var_int_params
  -- Description     : This procedure is a wrapper that deletes the Variable rate parameters
  --                   for a table
  --
  -- Business Rules  : this procedure is used to delete Variable rate Parameters
  --                   this procedure delete records of the OKL_VAR_INT_PARAMS_V table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 01-AUG-2005 dkagrawa created
  -- End of comments

  PROCEDURE delete_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_tbl      IN  virv_tbl_type ) IS

     -- Variables Declarations
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'delete_var_int_params';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Record/Table Type Declarations
    l_virv_tbl    virv_tbl_type;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VAR_INT_PARAMS_PVT.delete_var_int_params';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'start debug OKLRVISB.pls call delete_var_int_params for table');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_virv_tbl := p_virv_tbl;

    -- call the TAPI delete_row to delete variable rate parametrs
    OKL_VIR_PVT.delete_row(p_api_version    => p_api_version
                          ,p_init_msg_list  => p_init_msg_list
                          ,x_return_status  => x_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data
                          ,p_virv_tbl       => l_virv_tbl
                          );
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,'okl_vir_pvt.delete_row returned with status '||x_return_status
                             );
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data => x_msg_data
                        );
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'ends debug OKLRVISB.pls call delete_var_int_params for a table');
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
  END delete_var_int_params;

  -------------------------------------------------------------------------------
  -- PROCEDURE validate_var_int_params
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_var_int_params
  -- Description     : This procedure is a wrapper that validate the Variable rate parameters
  --                   for a record
  --
  -- Business Rules  : this procedure is used to validate Variable rate Parameters
  --                   this procedure validate record of the OKL_VAR_INT_PARAMS_V table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 01-AUG-2005 dkagrawa created
  -- End of comments

  PROCEDURE validate_var_int_params(
      p_api_version                  IN  NUMBER,
      p_init_msg_list                IN  VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_virv_rec                     IN  virv_rec_type) IS


      l_api_name            CONSTANT VARCHAR2(30) := 'validate_var_int_params';
      l_api_version         CONSTANT NUMBER       := 1.0;
      l_return_status       VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

      l_virv_rec            virv_rec_type;

      l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VAR_INT_PARAMS_PVT.validate_var_int_params';
      l_debug_enabled       VARCHAR2(10);

  Begin

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      -- check for logging on PROCEDURE level
      l_debug_enabled := okl_debug_pub.check_log_enabled;

      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'start debug OKLRVISB.pls call validate_var_int_params for record');
      END IF;

      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list

      l_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name,
        p_pkg_name      => g_pkg_name,
        p_init_msg_list => p_init_msg_list,
        l_api_version   => l_api_version,
        p_api_version   => p_api_version,
        p_api_type      => g_api_type,
        x_return_status => x_return_status);

      -- check if activity started successfully
      If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      l_virv_rec := p_virv_rec;
      --call the TAPI validate_row to validate the row.
      okl_vir_pvt.validate_row(
                              p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_virv_rec       => l_virv_rec);

      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                               l_module,'okl_vir_pvt.validate_row returned with status '||x_return_status
                               );
      END IF;

      -- check return status
      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
      raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                           x_msg_data   => x_msg_data
                          );
      IF(NVL(l_debug_enabled,'N')='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'ends debug OKLRVISB.pls call validate_var_int_params for a record');
      END IF;

    EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

      when OTHERS then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);
  END validate_var_int_params;

  -------------------------------------------------------------------------------
  -- PROCEDURE validate_var_int_params
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_var_int_params
  -- Description     : This procedure is a wrapper that validate the Variable rate parameters
  --                   for a table
  --
  -- Business Rules  : this procedure is used to validate Variable rate Parameters
  --                   this procedure validate records of the OKL_VAR_INT_PARAMS_V table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 01-AUG-2005 dkagrawa created
  -- End of comments

 PROCEDURE validate_var_int_params(
       p_api_version                  IN  NUMBER,
       p_init_msg_list                IN  VARCHAR2,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_virv_tbl                     IN  virv_tbl_type) IS


       l_api_name            CONSTANT VARCHAR2(30) := 'validate_var_int_params';
       l_api_version         CONSTANT NUMBER       := 1.0;
       l_return_status       VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

       l_virv_tbl            virv_tbl_type;

       l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VAR_INT_PARAMS_PVT.validate_var_int_params';
       l_debug_enabled       VARCHAR2(10);

   Begin

       x_return_status := OKL_API.G_RET_STS_SUCCESS;

       -- check for logging on PROCEDURE level
       l_debug_enabled := okl_debug_pub.check_log_enabled;

       IF(NVL(l_debug_enabled,'N')='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'start debug OKLRVISB.pls call validate_var_int_params for table');
       END IF;

       -- call START_ACTIVITY to create savepoint, check compatibility
       -- and initialize message list

       l_return_status := OKL_API.START_ACTIVITY(
         p_api_name      => l_api_name,
         p_pkg_name      => g_pkg_name,
         p_init_msg_list => p_init_msg_list,
         l_api_version   => l_api_version,
         p_api_version   => p_api_version,
         p_api_type      => g_api_type,
         x_return_status => x_return_status);

       -- check if activity started successfully
       If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
       End If;

       l_virv_tbl := p_virv_tbl;
       --call the TAPI validate_row to validate the row.
       okl_vir_pvt.validate_row(
                               p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_virv_tbl       => l_virv_tbl);

       IF(NVL(l_debug_enabled,'N')='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,'okl_vir_pvt.validate_row returned with status '||x_return_status
                                );
       END IF;

       -- check return status
       If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
       raise OKL_API.G_EXCEPTION_ERROR;
       End If;

       OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                            x_msg_data   => x_msg_data
                           );
       IF(NVL(l_debug_enabled,'N')='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'ends debug OKLRVISB.pls call validate_var_int_params for a table');
       END IF;

     EXCEPTION
       when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
         p_api_name  => l_api_name,
         p_pkg_name  => g_pkg_name,
         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_api_type  => g_api_type);

       when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
         p_api_name  => l_api_name,
         p_pkg_name  => g_pkg_name,
         p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_api_type  => g_api_type);

       when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
         p_api_name  => l_api_name,
         p_pkg_name  => g_pkg_name,
         p_exc_name  => 'OTHERS',
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_api_type  => g_api_type);
   END validate_var_int_params;

END OKL_VAR_INT_PARAMS_PVT;

/
