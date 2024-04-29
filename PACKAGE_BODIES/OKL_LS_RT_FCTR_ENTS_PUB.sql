--------------------------------------------------------
--  DDL for Package Body OKL_LS_RT_FCTR_ENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LS_RT_FCTR_ENTS_PUB" AS
/* $Header: OKLPLRFB.pls 120.4 2005/07/05 12:30:29 asawanka noship $ */

PROCEDURE insert_ls_rt_fctr_ents(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrfv_rec              IN  lrfv_rec_type
    ,x_lrfv_rec              OUT  NOCOPY lrfv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'insert_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.insert_ls_rt_fctr_ents (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END insert_ls_rt_fctr_ents;


PROCEDURE insert_ls_rt_fctr_ents(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrfv_tbl              IN  lrfv_tbl_type
    ,x_lrfv_tbl              OUT  NOCOPY lrfv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'insert_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.insert_ls_rt_fctr_ents (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END insert_ls_rt_fctr_ents;


PROCEDURE lock_ls_rt_fctr_ents(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_lrfv_rec              IN lrfv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'lock_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.lock_ls_rt_fctr_ents (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END lock_ls_rt_fctr_ents;


PROCEDURE lock_ls_rt_fctr_ents(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrfv_tbl              IN  lrfv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'lock_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.lock_ls_rt_fctr_ents (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END lock_ls_rt_fctr_ents;


PROCEDURE update_ls_rt_fctr_ents(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrfv_rec              IN  lrfv_rec_type
    ,x_lrfv_rec              OUT  NOCOPY lrfv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'update_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.update_ls_rt_fctr_ents (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END update_ls_rt_fctr_ents;


PROCEDURE update_ls_rt_fctr_ents(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrfv_tbl              IN  lrfv_tbl_type
    ,x_lrfv_tbl              OUT  NOCOPY lrfv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'update_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.update_ls_rt_fctr_ents (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END update_ls_rt_fctr_ents;


PROCEDURE delete_ls_rt_fctr_ents(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lrfv_rec              IN lrfv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'delete_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.delete_ls_rt_fctr_ents (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END delete_ls_rt_fctr_ents;


PROCEDURE delete_ls_rt_fctr_ents(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_lrfv_tbl           IN lrfv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'delete_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.delete_ls_rt_fctr_ents (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END delete_ls_rt_fctr_ents;


PROCEDURE validate_ls_rt_fctr_ents(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_lrfv_rec         IN  lrfv_rec_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'validate_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.validate_ls_rt_fctr_ents (REC)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END validate_ls_rt_fctr_ents;


PROCEDURE validate_ls_rt_fctr_ents(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_lrfv_tbl          IN  lrfv_tbl_type) IS

  l_program_name         CONSTANT VARCHAR2(35) := 'validate_ls_rt_fctr_ents';
  l_api_name             CONSTANT VARCHAR2(65) := 'okl_ls_rt_fctr_ents_pub.validate_ls_rt_fctr_ents (TBL)';
  p_transaction_control           VARCHAR2(1)  := G_TRUE;
  lx_return_status                VARCHAR2(1);

BEGIN

 null;

END validate_ls_rt_fctr_ents;

END okl_ls_rt_fctr_ents_pub;

/
