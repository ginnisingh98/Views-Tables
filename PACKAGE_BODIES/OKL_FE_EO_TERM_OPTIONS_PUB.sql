--------------------------------------------------------
--  DDL for Package Body OKL_FE_EO_TERM_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_EO_TERM_OPTIONS_PUB" AS
/* $Header: OKLPEOTB.pls 120.2 2005/12/23 16:20:05 viselvar noship $ */

  PROCEDURE get_item_lines(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_po_id         IN            NUMBER
                          ,p_po_version    IN            VARCHAR2
                          ,x_eto_tbl          OUT NOCOPY okl_eto_tbl) AS
    l_api_name                   VARCHAR2(40) := 'GET_ITEM_LINES';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the get item lines in the pvt

    okl_fe_eo_term_options_pvt.get_item_lines(l_api_version
                                             ,p_init_msg_list
                                             ,l_return_status
                                             ,x_msg_count
                                             ,x_msg_data
                                             ,p_po_id
                                             ,p_po_version
                                             ,x_eto_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
  END get_item_lines;

  PROCEDURE get_eo_term_values(p_api_version   IN            NUMBER
                              ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                              ,x_return_status    OUT NOCOPY VARCHAR2
                              ,x_msg_count        OUT NOCOPY NUMBER
                              ,x_msg_data         OUT NOCOPY VARCHAR2
                              ,p_po_id         IN            NUMBER
                              ,p_po_version    IN            VARCHAR2
                              ,x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS
    l_api_name                   VARCHAR2(40) := 'GET_PURCHASE_OPTION_VALUES';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the get item lines in the pvt

    okl_fe_eo_term_options_pvt.get_eo_term_values(l_api_version
                                                 ,p_init_msg_list
                                                 ,l_return_status
                                                 ,x_msg_count
                                                 ,x_msg_data
                                                 ,p_po_id
                                                 ,p_po_version
                                                 ,x_etv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
  END get_eo_term_values;

  PROCEDURE get_end_of_term_option(p_api_version   IN            NUMBER
                                  ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                                  ,x_return_status    OUT NOCOPY VARCHAR2
                                  ,x_msg_count        OUT NOCOPY NUMBER
                                  ,x_msg_data         OUT NOCOPY VARCHAR2
                                  ,p_po_id         IN            NUMBER
                                  ,p_po_version    IN            VARCHAR2
                                  ,x_ethv_rec         OUT NOCOPY okl_ethv_rec
                                  ,x_eve_rec          OUT NOCOPY okl_eve_rec
                                  ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                                  ,x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS
    l_api_name                   VARCHAR2(40) := 'GET_PURCHASE_OPTION';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the get item lines in the pvt

    okl_fe_eo_term_options_pvt.get_end_of_term_option(l_api_version
                                                     ,p_init_msg_list
                                                     ,l_return_status
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,p_po_id
                                                     ,p_po_version
                                                     ,x_ethv_rec
                                                     ,x_eve_rec
                                                     ,x_eto_tbl
                                                     ,x_etv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
  END get_end_of_term_option;

  PROCEDURE insert_end_of_term_option(p_api_version   IN            NUMBER
                                     ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                                     ,x_return_status    OUT NOCOPY VARCHAR2
                                     ,x_msg_count        OUT NOCOPY NUMBER
                                     ,x_msg_data         OUT NOCOPY VARCHAR2
                                     ,p_ethv_rec      IN            okl_ethv_rec
                                     ,p_eve_rec       IN            okl_eve_rec
                                     ,p_eto_tbl       IN            okl_eto_tbl
                                     ,p_etv_tbl       IN            okl_etv_tbl
                                     ,x_ethv_rec         OUT NOCOPY okl_ethv_rec
                                     ,x_eve_rec          OUT NOCOPY okl_eve_rec
                                     ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                                     ,x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS
    l_api_name                   VARCHAR2(40) := 'INSERT_PURCHASE_OPTION';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the get item lines in the pvt

    okl_fe_eo_term_options_pvt.insert_end_of_term_option(l_api_version
                                                        ,p_init_msg_list
                                                        ,l_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data
                                                        ,p_ethv_rec
                                                        ,p_eve_rec
                                                        ,p_eto_tbl
                                                        ,p_etv_tbl
                                                        ,x_ethv_rec
                                                        ,x_eve_rec
                                                        ,x_eto_tbl
                                                        ,x_etv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
  END insert_end_of_term_option;

  PROCEDURE update_end_of_term_option(p_api_version   IN            NUMBER
                                     ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                                     ,x_return_status    OUT NOCOPY VARCHAR2
                                     ,x_msg_count        OUT NOCOPY NUMBER
                                     ,x_msg_data         OUT NOCOPY VARCHAR2
                                     ,p_eve_rec       IN            okl_eve_rec
                                     ,p_eto_tbl       IN            okl_eto_tbl
                                     ,p_etv_tbl       IN            okl_etv_tbl
                                     ,x_eve_rec          OUT NOCOPY okl_eve_rec
                                     ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                                     ,x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS
    l_api_name                   VARCHAR2(40) := 'UPDATE_PURCHASE_OPTION';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the get item lines in the pvt

    okl_fe_eo_term_options_pvt.update_end_of_term_option(l_api_version
                                                        ,p_init_msg_list
                                                        ,l_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data
                                                        ,p_eve_rec
                                                        ,p_eto_tbl
                                                        ,p_etv_tbl
                                                        ,x_eve_rec
                                                        ,x_eto_tbl
                                                        ,x_etv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
  END update_end_of_term_option;

  PROCEDURE create_version(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_eve_rec       IN            okl_eve_rec
                          ,p_eto_tbl       IN            okl_eto_tbl
                          ,p_etv_tbl       IN            okl_etv_tbl
                          ,x_eve_rec          OUT NOCOPY okl_eve_rec
                          ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                          ,x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS
    l_api_name                   VARCHAR2(40) := 'CREATE_VERSION';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the create version in the pvt

    okl_fe_eo_term_options_pvt.create_version(l_api_version
                                             ,p_init_msg_list
                                             ,l_return_status
                                             ,x_msg_count
                                             ,x_msg_data
                                             ,p_eve_rec
                                             ,p_eto_tbl
                                             ,p_etv_tbl
                                             ,x_eve_rec
                                             ,x_eto_tbl
                                             ,x_etv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
  END create_version;

  PROCEDURE validate_end_of_term_option(p_api_version   IN            NUMBER
                                       ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                                       ,x_return_status    OUT NOCOPY VARCHAR2
                                       ,x_msg_count        OUT NOCOPY NUMBER
                                       ,x_msg_data         OUT NOCOPY VARCHAR2
                                       ,p_end_of_ver_id IN            NUMBER) AS
    l_api_name                   VARCHAR2(40) := 'validate_purchase_option';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the validate purchase option in the pvt

    okl_fe_eo_term_options_pvt.validate_end_of_term_option(l_api_version
                                                          ,p_init_msg_list
                                                          ,l_return_status
                                                          ,x_msg_count
                                                          ,x_msg_data
                                                          ,p_end_of_ver_id);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
  END validate_end_of_term_option;

  PROCEDURE handle_approval(p_api_version        IN            NUMBER
                           ,p_init_msg_list      IN            VARCHAR2 DEFAULT okl_api.g_false
                           ,x_return_status         OUT NOCOPY VARCHAR2
                           ,x_msg_count             OUT NOCOPY NUMBER
                           ,x_msg_data              OUT NOCOPY VARCHAR2
                           ,p_end_of_term_ver_id IN            NUMBER) AS
    l_api_name                   VARCHAR2(40) := 'handle approval';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            '_PUB'
                                             ,x_return_status =>            l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Call the validate purchase option in the pvt

    okl_fe_eo_term_options_pvt.handle_approval(l_api_version
                                              ,p_init_msg_list
                                              ,l_return_status
                                              ,x_msg_count
                                              ,x_msg_data
                                              ,p_end_of_term_ver_id);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_unexp_error
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                g_exc_name_others
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                '_PUB');
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
                                             ,'_PVT'
                                             ,l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_eo_term_options_pvt.invalid_objects(l_api_version
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
                           ,p_eve_rec       IN            okl_eve_rec
                           ,x_cal_eff_from     OUT NOCOPY DATE) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'calc_start_date';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_eve_rec                    okl_eve_rec  := p_eve_rec;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_eo_term_options_pvt.calculate_start_date(l_api_version
                                                   ,p_init_msg_list
                                                   ,l_return_status
                                                   ,x_msg_count
                                                   ,x_msg_data
                                                   ,l_eve_rec
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

  -- to calculate the t date of the new version

  PROCEDURE submit_end_of_term(p_api_version        IN            NUMBER
                              ,p_init_msg_list      IN            VARCHAR2 DEFAULT okl_api.g_false
                              ,x_return_status         OUT NOCOPY VARCHAR2
                              ,x_msg_count             OUT NOCOPY NUMBER
                              ,x_msg_data              OUT NOCOPY VARCHAR2
                              ,p_end_of_term_ver_id IN            NUMBER) AS
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'submit_end_of_term';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_Pub'
                                             ,l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_fe_eo_term_options_pvt.submit_end_of_term(l_api_version
                                                 ,p_init_msg_list
                                                 ,l_return_status
                                                 ,x_msg_count
                                                 ,x_msg_data
                                                 ,p_end_of_term_ver_id);

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
  END submit_end_of_term;

END okl_fe_eo_term_options_pub;

/
