--------------------------------------------------------
--  DDL for Package Body OKL_LS_RT_FCTR_SETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LS_RT_FCTR_SETS_PUB" AS
/* $Header: OKLPLRTB.pls 120.4 2005/07/05 12:30:37 asawanka noship $ */

PROCEDURE insert_ls_rt_fctr_sets(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrtv_rec              IN  lrtv_rec_type
    ,x_lrtv_rec              OUT  NOCOPY lrtv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'insert_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.insert_ls_rt_fctr_sets (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END insert_ls_rt_fctr_sets;


PROCEDURE insert_ls_rt_fctr_sets(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrtv_tbl              IN  lrtv_tbl_type
    ,x_lrtv_tbl              OUT  NOCOPY lrtv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'insert_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.insert_ls_rt_fctr_sets (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END insert_ls_rt_fctr_sets;


PROCEDURE lock_ls_rt_fctr_sets(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_lrtv_rec              IN lrtv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'lock_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.lock_ls_rt_fctr_sets (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END lock_ls_rt_fctr_sets;


PROCEDURE lock_ls_rt_fctr_sets(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrtv_tbl              IN  lrtv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'lock_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.lock_ls_rt_fctr_sets (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END lock_ls_rt_fctr_sets;


PROCEDURE update_ls_rt_fctr_sets(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrtv_rec              IN  lrtv_rec_type
    ,x_lrtv_rec              OUT  NOCOPY lrtv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'update_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.update_ls_rt_fctr_sets (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END update_ls_rt_fctr_sets;


PROCEDURE update_ls_rt_fctr_sets(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrtv_tbl              IN  lrtv_tbl_type
    ,x_lrtv_tbl              OUT  NOCOPY lrtv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'update_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.update_ls_rt_fctr_sets (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END update_ls_rt_fctr_sets;


PROCEDURE delete_ls_rt_fctr_sets(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrtv_rec              IN lrtv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'delete_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.delete_ls_rt_fctr_sets (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END delete_ls_rt_fctr_sets;


PROCEDURE delete_ls_rt_fctr_sets(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_lrtv_tbl           IN lrtv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'delete_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.delete_ls_rt_fctr_sets (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END delete_ls_rt_fctr_sets;


PROCEDURE validate_ls_rt_fctr_sets(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_lrtv_rec         IN  lrtv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'validate_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.validate_ls_rt_fctr_sets (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END validate_ls_rt_fctr_sets;


PROCEDURE validate_ls_rt_fctr_sets(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_lrtv_tbl          IN  lrtv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'validate_ls_rt_fctr_sets';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_sets_pub.validate_ls_rt_fctr_sets (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END validate_ls_rt_fctr_sets;

END OKL_LS_RT_FCTR_SETS_PUB;

/
