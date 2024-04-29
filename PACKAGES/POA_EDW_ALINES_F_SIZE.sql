--------------------------------------------------------
--  DDL for Package POA_EDW_ALINES_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_ALINES_F_SIZE" AUTHID CURRENT_USER AS
/* $Header: poaszals.pls 120.0 2005/06/02 01:33:06 appldev noship $ */

  PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                          p_to_date   IN  DATE,
                          p_num_rows  OUT NOCOPY NUMBER);

  PROCEDURE  est_row_len (p_from_date    IN  DATE,
                          p_to_date      IN  DATE,
                          p_avg_row_len  OUT NOCOPY NUMBER);
END;

 

/
