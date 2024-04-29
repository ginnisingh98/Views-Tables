--------------------------------------------------------
--  DDL for Package BSC_COLOR_REPOSITORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_REPOSITORY" AUTHID CURRENT_USER AS
/* $Header: BSCRCOLS.pls 120.0.12000000.1 2007/07/17 07:44:24 appldev noship $ */

NO_COLOR         CONSTANT NUMBER := 8421504;
EXCELLENT_COLOR  CONSTANT NUMBER := 24865;
GOOD_COLOR       CONSTANT NUMBER := 1;
AVERAGE_COLOR    CONSTANT NUMBER := 49919;
LOW_COLOR        CONSTANT NUMBER := 2;
POOR_COLOR       CONSTANT NUMBER := 192;

TYPE t_color_rec IS RECORD (
  color_id    bsc_sys_colors_b.color_id%TYPE
, short_name  bsc_sys_colors_b.short_name%TYPE
, perf_seq    bsc_sys_colors_b.perf_sequence%TYPE
, numeric_eq  bsc_sys_colors_b.user_numeric_equivalent%TYPE
);

TYPE t_array_colors IS TABLE OF t_color_rec
    INDEX BY BINARY_INTEGER;

g_array_colors  t_array_colors;

G_COLOR_SET     BOOLEAN := FALSE;

FUNCTION get_color_props
RETURN t_array_colors;

END BSC_COLOR_REPOSITORY;

 

/
