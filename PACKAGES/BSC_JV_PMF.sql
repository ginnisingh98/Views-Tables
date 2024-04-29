--------------------------------------------------------
--  DDL for Package BSC_JV_PMF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_JV_PMF" AUTHID CURRENT_USER AS
/* $Header: BSCJPFS.pls 120.0 2005/06/01 15:07:42 appldev noship $ */

PROCEDURE get_pmf_measure(
    p_Measure_ShortName        IN  VARCHAR2,
    x_function_name            OUT NOCOPY  VARCHAR2,
    x_region_code             OUT NOCOPY  VARCHAR2
);

PROCEDURE get_pmf_measure(
    p_Measure_ShortName        IN  VARCHAR2,
    x_function_name            OUT NOCOPY  VARCHAR2,
    x_region_code             OUT NOCOPY  VARCHAR2,
    x_graph_no               OUT NOCOPY NUMBER
);


END bsc_jv_pmf;

 

/
