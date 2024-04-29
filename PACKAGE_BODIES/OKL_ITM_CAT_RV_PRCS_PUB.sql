--------------------------------------------------------
--  DDL for Package Body OKL_ITM_CAT_RV_PRCS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ITM_CAT_RV_PRCS_PUB" AS
/* $Header: OKLPICPB.pls 120.4 2005/10/30 03:31:59 appldev noship $ */

PROCEDURE insert_itm_cat_rv_prcs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_icpv_rec              IN  icpv_rec_type
    ,x_icpv_rec              OUT  NOCOPY icpv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'insert_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.insert_itm_cat_rv_prcs (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.insert_row(p_api_version   => G_API_VERSION,
                         p_init_msg_list => G_FALSE,
                         x_return_status => lx_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_icpv_rec      => p_icpv_rec,
                         x_icpv_rec      => x_icpv_rec);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END insert_itm_cat_rv_prcs;


PROCEDURE insert_itm_cat_rv_prcs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_icpv_tbl              IN  icpv_tbl_type
    ,x_icpv_tbl              OUT  NOCOPY icpv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'insert_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.insert_itm_cat_rv_prcs (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.insert_row(p_api_version   => G_API_VERSION,
                         p_init_msg_list => G_FALSE,
                         x_return_status => lx_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_icpv_tbl      => p_icpv_tbl,
                         x_icpv_tbl      => x_icpv_tbl);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END insert_itm_cat_rv_prcs;


PROCEDURE lock_itm_cat_rv_prcs(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_icpv_rec              IN icpv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'lock_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.lock_itm_cat_rv_prcs (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.lock_row(p_api_version   => G_API_VERSION,
                       p_init_msg_list => G_FALSE,
                       x_return_status => lx_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_icpv_rec      => p_icpv_rec);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END lock_itm_cat_rv_prcs;


PROCEDURE lock_itm_cat_rv_prcs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_icpv_tbl              IN  icpv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'lock_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.lock_itm_cat_rv_prcs (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.lock_row(p_api_version   => G_API_VERSION,
                       p_init_msg_list => G_FALSE,
                       x_return_status => lx_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_icpv_tbl      => p_icpv_tbl);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END lock_itm_cat_rv_prcs;


PROCEDURE update_itm_cat_rv_prcs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_icpv_rec              IN  icpv_rec_type
    ,x_icpv_rec              OUT  NOCOPY icpv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'update_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.update_itm_cat_rv_prcs (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.update_row(p_api_version   => G_API_VERSION,
                         p_init_msg_list => G_FALSE,
                         x_return_status => lx_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_icpv_rec      => p_icpv_rec,
                         x_icpv_rec      => x_icpv_rec);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END update_itm_cat_rv_prcs;


PROCEDURE update_itm_cat_rv_prcs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_icpv_tbl              IN  icpv_tbl_type
    ,x_icpv_tbl              OUT  NOCOPY icpv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'update_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.update_itm_cat_rv_prcs (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.update_row(p_api_version   => G_API_VERSION,
                         p_init_msg_list => G_FALSE,
                         x_return_status => lx_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_icpv_tbl      => p_icpv_tbl,
                         x_icpv_tbl      => x_icpv_tbl);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END update_itm_cat_rv_prcs;


PROCEDURE delete_itm_cat_rv_prcs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_icpv_rec              IN icpv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'delete_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.delete_itm_cat_rv_prcs (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.delete_row(p_api_version   => G_API_VERSION,
                         p_init_msg_list => G_FALSE,
                         x_return_status => lx_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_icpv_rec      => p_icpv_rec);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END delete_itm_cat_rv_prcs;


PROCEDURE delete_itm_cat_rv_prcs(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_icpv_tbl           IN icpv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'delete_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.delete_itm_cat_rv_prcs (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.delete_row(p_api_version   => G_API_VERSION,
                         p_init_msg_list => G_FALSE,
                         x_return_status => lx_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_icpv_tbl      => p_icpv_tbl);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END delete_itm_cat_rv_prcs;


PROCEDURE validate_itm_cat_rv_prcs(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_icpv_rec         IN  icpv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'validate_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.validate_itm_cat_rv_prcs (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.validate_row(p_api_version   => G_API_VERSION,
                           p_init_msg_list => G_FALSE,
                           x_return_status => lx_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_icpv_rec      => p_icpv_rec);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END validate_itm_cat_rv_prcs;


PROCEDURE validate_itm_cat_rv_prcs(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_icpv_tbl          IN  icpv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'validate_itm_cat_rv_prcs';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_itm_cat_rv_prcs_pub.validate_itm_cat_rv_prcs (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

  IF p_transaction_control = G_TRUE THEN
    SAVEPOINT l_program_name;
  END IF;

  IF p_init_msg_list = OKL_API.G_TRUE THEN
    FND_MSG_PUB.initialize;
  END IF;

  okl_icp_pvt.validate_row(p_api_version   => G_API_VERSION,
                           p_init_msg_list => G_FALSE,
                           x_return_status => lx_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_icpv_tbl      => p_icpv_tbl);

  IF lx_return_status = G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

END validate_itm_cat_rv_prcs;

END okl_itm_cat_rv_prcs_pub;

/
