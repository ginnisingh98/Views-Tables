--------------------------------------------------------
--  DDL for Package Body OKL_FE_ADJ_MATRIX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_ADJ_MATRIX_PUB" AS
/* $Header: OKLPPAMB.pls 120.1 2005/12/23 16:18:59 viselvar noship $ */

  --------------------------------------------------------------------------------
  --PACKAGE CONSTANTS
  --------------------------------------------------------------------------------

  g_db_error           CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  g_prog_name_token    CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  g_no_parent_record   CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  g_unexpected_error   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token      CONSTANT VARCHAR2(200) := 'SQLerrm';
  g_sqlcode_token      CONSTANT VARCHAR2(200) := 'SQLcode';
  g_exception_halt_validation EXCEPTION;
  g_invalid_adj_cat_dates     EXCEPTION;
  g_exception_cannot_update   EXCEPTION;
  g_invalid_start_date        EXCEPTION;

  -- procedure to give the details of the adjustment matrix given the Adjustment
  -- matrix id and the version number

  PROCEDURE get_version(p_api_version    IN            NUMBER
                       ,p_init_msg_list  IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2
                       ,p_adj_mat_id     IN            NUMBER
                       ,p_version_number IN            NUMBER
                       ,x_pamv_rec          OUT NOCOPY okl_pamv_rec
                       ,x_pal_rec           OUT NOCOPY okl_pal_rec
                       ,x_ech_rec           OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl           OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl           OUT NOCOPY okl_ecv_tbl) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'get_version';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.get_version(l_api_version
                                     ,p_init_msg_list
                                     ,l_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,p_adj_mat_id
                                     ,p_version_number
                                     ,x_pamv_rec
                                     ,x_pal_rec
                                     ,x_ech_rec
                                     ,x_ecl_tbl
                                     ,x_ecv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END get_version;

  -- procedure to give the details of the latest version of adjustment matrix
  -- given the adjusment matrix id

  PROCEDURE get_version(p_api_version   IN            NUMBER
                       ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status    OUT NOCOPY VARCHAR2
                       ,x_msg_count        OUT NOCOPY NUMBER
                       ,x_msg_data         OUT NOCOPY VARCHAR2
                       ,p_adj_mat_id    IN            NUMBER
                       ,x_pamv_rec         OUT NOCOPY okl_pamv_rec
                       ,x_pal_rec          OUT NOCOPY okl_pal_rec
                       ,x_ech_rec          OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl          OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl          OUT NOCOPY okl_ecv_tbl) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'get_version';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.get_version(l_api_version
                                     ,p_init_msg_list
                                     ,l_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,p_adj_mat_id
                                     ,x_pamv_rec
                                     ,x_pal_rec
                                     ,x_ech_rec
                                     ,x_ecl_tbl
                                     ,x_ecv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END get_version;

  -- procedure to create a new version of the Pricing Adjustment Matrix

  PROCEDURE create_version(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_pal_rec       IN            okl_pal_rec
                          ,x_pal_rec          OUT NOCOPY okl_pal_rec) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'create_version';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.create_version(l_api_version
                                        ,p_init_msg_list
                                        ,l_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,p_pal_rec
                                        ,x_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END create_version;

  --procedure to create a Pricing Adjusment Matrix with the associated adjustment categories

  PROCEDURE insert_adj_mat(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_pamv_rec      IN            okl_pamv_rec
                          ,p_pal_rec       IN            okl_pal_rec
                          ,x_pamv_rec         OUT NOCOPY okl_pamv_rec
                          ,x_pal_rec          OUT NOCOPY okl_pal_rec) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'insert_adj_mat';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.insert_adj_mat(l_api_version
                                        ,p_init_msg_list
                                        ,l_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,p_pamv_rec
                                        ,p_pal_rec
                                        ,x_pamv_rec
                                        ,x_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END insert_adj_mat;

  -- procedure to update a particular version of the Pricing Adjustment matrix

  PROCEDURE update_adj_mat(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_pal_rec       IN            okl_pal_rec
                          ,x_pal_rec          OUT NOCOPY okl_pal_rec) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'update_adj_factor';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.update_adj_mat(l_api_version
                                        ,p_init_msg_list
                                        ,l_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,p_pal_rec
                                        ,x_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END update_adj_mat;

  -- procedure to raise the workflow which submits the record and changes the status.

  PROCEDURE submit_adj_mat(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_version_id    IN            NUMBER) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'submit_adj_factor';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.submit_adj_mat(l_api_version
                                        ,p_init_msg_list
                                        ,l_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,p_version_id);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END submit_adj_mat;

  -- procedure to validate the pricing adjustment matrix

  PROCEDURE validate_adj_mat(p_api_version   IN            NUMBER
                            ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                            ,x_return_status    OUT NOCOPY VARCHAR2
                            ,x_msg_count        OUT NOCOPY NUMBER
                            ,x_msg_data         OUT NOCOPY VARCHAR2
                            ,p_pal_rec       IN            okl_pal_rec
                            ,p_ech_rec       IN            okl_ech_rec
                            ,p_ecl_tbl       IN            okl_ecl_tbl
                            ,p_ecv_tbl       IN            okl_ecv_tbl) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'validate_adj_factor';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.validate_adj_mat(p_api_version
                                          ,p_init_msg_list
                                          ,l_return_status
                                          ,x_msg_count
                                          ,x_msg_data
                                          ,p_pal_rec
                                          ,p_ech_rec
                                          ,p_ecl_tbl
                                          ,p_ecv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END validate_adj_mat;

  -- procedure to handle when the process is going through the process of approval

  PROCEDURE handle_approval(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_version_id    IN            NUMBER) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'handle_approval';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.handle_approval(p_api_version
                                         ,p_init_msg_list
                                         ,l_return_status
                                         ,x_msg_count
                                         ,x_msg_data
                                         ,p_version_id);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;


    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END handle_approval;

  PROCEDURE invalid_objects(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2           DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_version_id    IN            NUMBER
                           ,x_obj_tbl          OUT NOCOPY invalid_object_tbl) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'invalid_objects';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.invalid_objects(l_api_version
                                         ,p_init_msg_list
                                         ,l_return_status
                                         ,x_msg_count
                                         ,x_msg_data
                                         ,p_version_id
                                         ,x_obj_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END invalid_objects;

  -- to calculate the start date of the new version

  PROCEDURE calc_start_date(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_pal_rec       IN            okl_pal_rec
                           ,x_cal_eff_from     OUT NOCOPY DATE) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'calc_start_date';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_pal_rec                    okl_pal_rec  := p_pal_rec;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_adj_matrix_pvt.calc_start_date(l_api_version
                                         ,p_init_msg_list
                                         ,l_return_status
                                         ,x_msg_count
                                         ,x_msg_data
                                         ,l_pal_rec
                                         ,x_cal_eff_from);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_Pub');
  END calc_start_date;

END okl_fe_adj_matrix_pub;

/
