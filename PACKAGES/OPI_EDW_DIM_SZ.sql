--------------------------------------------------------
--  DDL for Package OPI_EDW_DIM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_DIM_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIMDSZS.pls 120.1 2005/06/10 11:45:59 appldev  $*/

-- procedure to count inventory Locator Dimension rows.

  PROCEDURE EDW_MTL_INV_LOC_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);
-- procedure to get average row length inventory Locator Dimension rows.

  PROCEDURE EDW_MTL_INV_LOC_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);

-- procedure to count Activity Dimension rows.

  PROCEDURE EDW_OPI_ACTV_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);
-- procedure to get average row length Activity Dimension rows.

  PROCEDURE EDW_OPI_ACTV_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


-- procedure to count Lot Dimension rows.

  PROCEDURE EDW_OPI_LOT_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);
-- procedure to get average row length Lot Dimension rows.

  PROCEDURE EDW_OPI_LOT_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


-- procedure to count Production Operation Dimension rows.

  PROCEDURE EDW_OPI_OPRN_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length Production Operation Dimension rows.

  PROCEDURE EDW_OPI_OPRN_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


-- procedure to count Production Line Dimension rows.

  PROCEDURE EDW_OPI_PRDL_M_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length Production Line Dimension rows.

  PROCEDURE EDW_OPI_PRDL_M_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);

END;


 

/
