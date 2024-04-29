--------------------------------------------------------
--  DDL for Package OPI_EDW_FACT_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_FACT_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIMFSZS.pls 120.1 2005/06/07 03:27:59 appldev  $*/

-- procedure to count COGS Fact rows.

  PROCEDURE OPI_EDW_COGS_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length COGS Fact rows.

  PROCEDURE OPI_EDW_COGS_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);

-- procedure to count Inventory Daily Status Fact rows.

  PROCEDURE OPI_EDW_IDS_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length Inventory Daily Status Fact rows.

  PROCEDURE OPI_EDW_IDS_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


-- procedure to count Job Details Fact rows.

  PROCEDURE OPI_EDW_JOB_DTL_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length Job Details Fact rows.

  PROCEDURE OPI_EDW_JOB_DTL_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


-- procedure to count Job Resource Fact rows.

  PROCEDURE OPI_EDW_JOB_RSRC_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length Job Resource Fact rows.

  PROCEDURE OPI_EDW_JOB_RSRC_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


-- procedure to count Resource Utilization Fact rows.

  PROCEDURE OPI_EDW_RES_UTIL_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length Resource Utilization Fact rows.

  PROCEDURE OPI_EDW_RES_UTIL_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


-- procedure to count UOM Conversion Fact rows.

  PROCEDURE OPI_EDW_UOM_CONV_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

-- procedure to get average row length UOM Conversion Fact rows.

  PROCEDURE OPI_EDW_UOM_CONV_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER);


END OPI_EDW_FACT_SZ;


 

/
