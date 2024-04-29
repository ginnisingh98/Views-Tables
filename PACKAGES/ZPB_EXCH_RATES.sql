--------------------------------------------------------
--  DDL for Package ZPB_EXCH_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_EXCH_RATES" AUTHID CURRENT_USER AS
/* $Header: ZPBEXCRT.pls 120.0.12010.2 2005/12/23 06:00:21 appldev noship $ */

PROCEDURE LOAD_RATES (errbuf            OUT NOCOPY VARCHAR2,
                      retcode           OUT NOCOPY VARCHAR2,
                      p_gen_cross_rates IN VARCHAR2,
                      p_data_aw         IN VARCHAR2,
                      p_code_aw         IN VARCHAR2,
                      p_bus_area_id     IN VARCHAR2
                      );

--PROCEDURE LOAD_RATES_CP (p_gen_cross_rates IN VARCHAR2);
FUNCTION LOAD_RATES_CP (p_gen_cross_rates IN VARCHAR2,
                        p_bus_area_id     IN VARCHAR2) RETURN NUMBER;


END ZPB_EXCH_RATES ;

 

/
