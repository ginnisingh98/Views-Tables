--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_BALANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_BALANCES_PVT" AS
  /* $Header: OKLRCBLB.pls 120.0 2005/09/29 06:24:58 dkagrawa noship $ */

  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : create_contract_balance
  --Description : Calls the Table API of OKL_CONTRACT_BALANCES to create a record
  --              to store the contract balances.
  --History     :
  --              01-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE create_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_rec         IN         okl_cblv_rec
                       , x_cblv_rec         OUT NOCOPY okl_cblv_rec) AS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CONTRACT_BAL_REC';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_CONTRACT_BALANCES_PVT.CREATE_CONTRACT_BALANCE';
    l_debug_enabled VARCHAR2(10);


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCBLB.pls call create_contract_balance(REC)');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CBL_PVT.insert_row(p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_cblv_rec       => p_cblv_rec,
                           x_cblv_rec       => x_cblv_rec);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_cbl_pvt.insert_row(rec) returned with status '||x_return_status||' id '||x_cblv_rec.id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCBLB.pls call create_contract_balance(REC)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_contract_balance; -- end of record insert api - REC

  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : create_contract_balance
  --Description : Calls the Table API of OKL_CONTRACT_BALANCES to create records
  --              to store the contract balances.
  --History     :
  --              01-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE create_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl
                       , x_cblv_tbl         OUT NOCOPY okl_cblv_tbl) AS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CONTRACT_BAL_TBL';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_CONTRACT_BALANCES_PVT.CREATE_CONTRACT_BALANCE';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCBLB.pls call create_contract_balance(TBL)');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CBL_PVT.insert_row(p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_cblv_tbl       => p_cblv_tbl,
                           x_cblv_tbl       => x_cblv_tbl);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_cbl_pvt.insert_row (tbl) returned with status '||x_return_status
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCBLB.pls call create_contract_balance(TBL)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_contract_balance; -- end of table insert api - TBL

  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : create_contract_balance
  --Description : Calls the Table API of OKL_CONTRACT_BALANCES to update a record
  --              with the contract balances.
  --History     :
  --              01-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE update_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_rec         IN         okl_cblv_rec
                       , x_cblv_rec         OUT NOCOPY okl_cblv_rec) AS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'UPDATE_CONTRACT_BAL_REC';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_CONTRACT_BALANCES_PVT.UPDATE_CONTRACT_BALANCE';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCBLB.pls call update_contract_balance(REC)');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CBL_PVT.update_row(p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_cblv_rec       => p_cblv_rec,
                           x_cblv_rec       => x_cblv_rec);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_cbl_pvt.update_row(rec) returned with status '||x_return_status||'id '||x_cblv_rec.id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCBLB.pls call update_contract_balance(REC)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END update_contract_balance; -- end of record update api - REC

  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : create_contract_balance
  --Description : Calls the Table API of OKL_CONTRACT_BALANCES to update records
  --              with the contract balances.
  --History     :
  --              01-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE update_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl
                       , x_cblv_tbl         OUT NOCOPY okl_cblv_tbl) AS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'UPDATE_CONTRACT_BAL_TBL';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_CONTRACT_BALANCES_PVT.UPATE_CONTRACT_BALANCE';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCBLB.pls call update_contract_balance(TBL)');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CBL_PVT.update_row(p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_cblv_tbl       => p_cblv_tbl,
                           x_cblv_tbl       => x_cblv_tbl);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_cbl_pvt.update_row (tbl) returned with status '||x_return_status
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCBLB.pls call update_contract_balance(TBL)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END update_contract_balance; -- end of table update api - TBL

  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : create_contract_balance
  --Description : Calls the Table API of OKL_CONTRACT_BALANCES to delete records
  --              present in the balances table.
  --History     :
  --              01-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE delete_contract_balances(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl) AS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'DELETE_CONTRACT_BAL_TBL';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_CONTRACT_BALANCES_PVT.DELETE_CONTRACT_BALANCE';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCBLB.pls call delete_contract_balance(TBL)');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CBL_PVT.delete_row(p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_cblv_tbl       => p_cblv_tbl);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_cbl_pvt.delete_row (tbl) returned with status '||x_return_status
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCBLB.pls call delete_contract_balance(TBL)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END delete_contract_balances; -- end of table update api - TBL

  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : create_contract_balance
  --Description : Calls the Table API of OKL_CONTRACT_BALANCES to validate a record
  --              in the contract balances table.
  --History     :
  --              01-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE validate_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_rec         IN         okl_cblv_rec) AS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'VALID_CONTRACT_BAL_REC';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_CONTRACT_BALANCES_PVT.VALIDATE_CONTRACT_BALANCE';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCBLB.pls call validate_contract_balance(REC)');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CBL_PVT.validate_row(p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_cblv_rec       => p_cblv_rec);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_cbl_pvt.validate_row(rec) returned with status '||x_return_status
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCBLB.pls call validate_contract_balance(REC)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END validate_contract_balance; -- end of record validate api - REC

  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : create_contract_balance
  --Description : Calls the Table API of OKL_CONTRACT_BALANCES to validate a set
  --              of records in the contract balances table.
  --History     :
  --              01-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE validate_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl) AS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'VALID_CONTRACT_BAL_TBL';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_CONTRACT_BALANCES_PVT.VALIDATE_CONTRACT_BALANCE';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCBLB.pls call validate_contract_balance(TBL)');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CBL_PVT.validate_row(p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_cblv_tbl       => p_cblv_tbl);

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_cbl_pvt.validate_row(tbl) returned with status '||x_return_status
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCBLB.pls call validate_contract_balance(TBL)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END validate_contract_balance; -- end of record validate api - TBL

END OKL_CONTRACT_BALANCES_PVT; -- End of package Body

/
