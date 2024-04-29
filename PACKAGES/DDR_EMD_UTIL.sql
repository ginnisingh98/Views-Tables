--------------------------------------------------------
--  DDL for Package DDR_EMD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_EMD_UTIL" AUTHID CURRENT_USER AS
/* $Header: ddremdus.pls 120.1.12010000.2 2010/03/03 04:18:11 vbhave noship $ */

  TYPE number_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE date_tbl IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE varchar_tbl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

  c_populate_custom     CONSTANT VARCHAR2(1) := 'C';
  c_populate_standard   CONSTANT VARCHAR2(1) := 'S';
  c_batch_size          CONSTANT NUMBER      := 50000;

  error   CONSTANT VARCHAR2(1) := 'E';
  success CONSTANT VARCHAR2(1) := 'S';

  new_item_period  CONSTANT NUMBER := 30;

  PROCEDURE create_exception(p_mfg_org_cd           IN VARCHAR2
                           , p_rtl_org_cd           IN VARCHAR2
                           , p_excptn_type          IN VARCHAR2
                           , p_excptn_src_code      IN VARCHAR2
                           , p_excptn_date          IN VARCHAR2
                           , p_org_bsns_unit_id     IN VARCHAR2
                           , p_mfg_sku_item_id      IN VARCHAR2
                           , p_rtl_sku_item_id      IN VARCHAR2
                           , p_user_id              IN VARCHAR2
                           , p_excptn_qty           IN VARCHAR2 DEFAULT NULL
                           , p_excptn_amt           IN VARCHAR2 DEFAULT NULL);
  PROCEDURE delete_exception(p_excptn_type          IN VARCHAR2
                           , p_excptn_src_code      IN VARCHAR2
                           , p_date_offset          IN NUMBER DEFAULT 0);

  PROCEDURE delete_all_exceptions(p_end_date        IN DATE
                                , p_excptn_type     IN VARCHAR2 DEFAULT NULL
                                , p_excptn_src_code IN VARCHAR2 DEFAULT NULL
                                , x_return_status    OUT NOCOPY VARCHAR2
                                , x_msg              OUT NOCOPY VARCHAR2
                                );

  PROCEDURE calc_exception_measures(p_date_offset          IN NUMBER
                                   ,p_bsns_unit_cd         IN VARCHAR2 DEFAULT NULL
                                   ,p_rtl_org_cd           IN VARCHAR2 DEFAULT NULL
                                   ,p_calc_ifpl_excptn     IN BOOLEAN
                                   ,p_calc_oosim_excptn    IN BOOLEAN
                                   ,p_calc_npisales_excptn IN BOOLEAN
                                   ,x_return_status    OUT NOCOPY VARCHAR2
                                   ,x_msg              OUT NOCOPY VARCHAR2
                                   );
END ddr_emd_util;

/
