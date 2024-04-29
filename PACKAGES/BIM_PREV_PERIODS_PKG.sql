--------------------------------------------------------
--  DDL for Package BIM_PREV_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_PREV_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: bimbpps.pls 115.3 2000/03/07 13:03:24 pkm ship       $*/

PROCEDURE BIM_PREV_PERIODS(
  p_period_type             IN VARCHAR2
 ,p_start_date              IN DATE
 ,p_end_date                IN DATE
 ,p_prev_start_date     IN OUT DATE
 ,p_prev_END_date       IN OUT DATE
 );

END BIM_PREV_PERIODS_PKG;

 

/
