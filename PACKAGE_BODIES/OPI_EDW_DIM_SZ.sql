--------------------------------------------------------
--  DDL for Package Body OPI_EDW_DIM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_DIM_SZ" AS
/* $Header: OPIMDSZB.pls 120.1 2005/06/10 11:51:28 appldev  $*/

-- procedure to count inventory Locator Dimension rows.

  PROCEDURE EDW_MTL_INV_LOC_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
  BEGIN
    EDW_MTL_INVENTORY_LOC_M_SZ.cnt_rows(p_from_date, p_to_date, p_num_rows) ;
  END EDW_MTL_INV_LOC_M_CNT_ROWS;

-- procedure to get average row length inventory Locator Dimension rows.

  PROCEDURE EDW_MTL_INV_LOC_M_est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
  BEGIN
    EDW_MTL_INVENTORY_LOC_M_SZ.est_row_len(p_from_date, p_to_date, p_avg_row_len) ;
  END;


-- procedure to count Activity Dimension rows.

  PROCEDURE EDW_OPI_ACTV_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
      OPI_EDW_OPI_ACTV_M_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
      EDW_OPI_ACTV_MOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
	p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;
-- procedure to get average row length Activity Dimension rows.

  PROCEDURE EDW_OPI_ACTV_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_OPI_ACTV_M_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    EDW_OPI_ACTV_MOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len) ;
  END;

-- procedure to count Lot Dimension rows.

  PROCEDURE EDW_OPI_LOT_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
      OPI_EDW_OPI_LOT_M_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
      EDW_OPI_LOT_MOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
	p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;
-- procedure to get average row length Lot Dimension rows.

  PROCEDURE EDW_OPI_LOT_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_OPI_LOT_M_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    EDW_OPI_LOT_MOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len) ;
  END;


-- procedure to count Production Operation Dimension rows.

  PROCEDURE EDW_OPI_OPRN_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER)  IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
     OPI_EDW_OPI_OPRN_M_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
      EDW_OPI_OPRN_MOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
	p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;

-- procedure to get average row length Production Operation Dimension rows.

  PROCEDURE EDW_OPI_OPRN_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
     OPI_EDW_OPI_OPRN_M_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
     EDW_OPI_OPRN_MOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len);
  END;


-- procedure to count Production Line Dimension rows.

  PROCEDURE EDW_OPI_PRDL_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER)  IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
     OPI_EDW_OPI_PRDL_M_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
	p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;

-- procedure to get average row length Production Line Dimension rows.

  PROCEDURE EDW_OPI_PRDL_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
     OPI_EDW_OPI_PRDL_M_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
     p_avg_row_len := p_opi_row_len;
  END;

END OPI_EDW_DIM_SZ;


/
