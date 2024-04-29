--------------------------------------------------------
--  DDL for Package EDW_OPI_ACTV_MOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OPI_ACTV_MOPM_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIPACZS.pls 120.2 2005/06/16 03:53:13 appldev  $*/

-- procedure to count Lot Dimension rows.

  PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                          p_to_date   IN  DATE,
                          p_num_rows  OUT NOCOPY NUMBER);

-- procedure to get average row length Lot Dimension rows.

  PROCEDURE  est_row_len (p_from_date    IN  DATE,
                          p_to_date      IN  DATE,
                          p_avg_row_len  OUT NOCOPY NUMBER);
END EDW_OPI_ACTV_MOPM_SZ;

 

/
