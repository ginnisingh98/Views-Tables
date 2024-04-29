--------------------------------------------------------
--  DDL for Package Body OPI_EDW_FACT_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_FACT_SZ" AS
/* $Header: OPIMFSZB.pls 120.1 2005/06/10 11:35:52 appldev  $*/

-- procedure to count COGS Fact rows.

  PROCEDURE OPI_EDW_COGS_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
    OPI_EDW_COGS_F_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
    OPI_EDW_COGS_FOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
    p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;

-- procedure to get average row length COGS Fact rows.

  PROCEDURE OPI_EDW_COGS_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_COGS_F_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    OPI_EDW_COGS_FOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len);
  END;

-- procedure to count Inventory Daily Status Fact rows.

  PROCEDURE OPI_EDW_IDS_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
    OPI_EDW_INV_DAILY_STAT_F_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
    OPI_EDW_INV_DAILY_STAT_FOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
    p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;

-- procedure to get average row length Inventory Daily Status Fact rows.

  PROCEDURE OPI_EDW_IDS_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_INV_DAILY_STAT_F_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    OPI_EDW_INV_DAILY_STAT_FOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len) ;
  END;

-- procedure to count Job Details Fact rows.

  PROCEDURE OPI_EDW_JOB_DTL_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
    OPI_EDW_JOB_DETAIL_F_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
    OPI_EDW_JOB_DETAIL_FOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
    p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;

-- procedure to get average row length Job Details Fact rows.

  PROCEDURE OPI_EDW_JOB_DTL_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_JOB_DETAIL_F_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    OPI_EDW_JOB_DETAIL_FOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len);
  END;


-- procedure to count Job Resource Fact rows.

  PROCEDURE OPI_EDW_JOB_RSRC_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
     OPI_EDW_JOB_RSRC_F_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
     OPI_EDW_JOB_RSRC_FOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
     p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;

-- procedure to get average row length Job Resource Fact rows.

  PROCEDURE OPI_EDW_JOB_RSRC_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_JOB_RSRC_F_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    OPI_EDW_JOB_RSRC_FOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len);
  END;


-- procedure to count Resource Utilization Fact rows.

  PROCEDURE OPI_EDW_RES_UTIL_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
    OPI_EDW_RES_UTIL_F_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
    OPI_EDW_RES_UTIL_FOPM_SZ.cnt_rows(p_from_date, p_to_date, p_pmi_num_rows) ;
    p_num_rows := p_opi_num_rows + p_pmi_num_rows ;
  END;

-- procedure to get average row length Resource Utilization Fact rows.

  PROCEDURE OPI_EDW_RES_UTIL_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_RES_UTIL_F_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    OPI_EDW_RES_UTIL_FOPM_SZ.est_row_len(p_from_date, p_to_date, p_pmi_row_len) ;
    p_avg_row_len := greatest(p_opi_row_len + p_pmi_row_len);
  END;


-- procedure to count UOM Conversion Fact rows.

  PROCEDURE OPI_EDW_UOM_CONV_F_CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
    p_opi_num_rows NUMBER := 0 ;
    p_pmi_num_rows NUMBER := 0 ;
  BEGIN
    OPI_EDW_UOM_CONV_F_SZ.cnt_rows(p_from_date, p_to_date, p_opi_num_rows) ;
    p_num_rows := p_opi_num_rows;
  END;

-- procedure to get average row length UOM Conversion Fact rows.

  PROCEDURE OPI_EDW_UOM_CONV_F_EST_ROW_LEN(p_from_date DATE,
                   p_to_date DATE,
                   p_avg_row_len OUT NOCOPY NUMBER) IS
	p_opi_row_len NUMBER := 0 ;
	p_pmi_row_len NUMBER := 0 ;
  BEGIN
    OPI_EDW_UOM_CONV_F_SZ.est_row_len(p_from_date, p_to_date, p_opi_row_len) ;
    p_avg_row_len := p_opi_row_len;
  END;


END;


/
