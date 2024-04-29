--------------------------------------------------------
--  DDL for Package ARP_TRX_SUM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_SUM_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTUSUMS.pls 115.3 2002/11/15 04:05:22 anukumar ship $ */


FUNCTION get_batch_summary(
  p_batch_id IN number,
  p_mode     IN varchar2 ) RETURN number;


PROCEDURE get_batch_summary_all (p_batch_id IN number,
                                 l_actual_count OUT NOCOPY number,
                                 l_actual_amount OUT NOCOPY number );

END ARP_TRX_SUM_UTIL;

 

/
