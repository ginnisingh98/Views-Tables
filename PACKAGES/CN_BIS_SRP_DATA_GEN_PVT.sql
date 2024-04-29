--------------------------------------------------------
--  DDL for Package CN_BIS_SRP_DATA_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_BIS_SRP_DATA_GEN_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvbsums.pls 115.2.1158.4 2003/07/29 17:12:17 ctoba noship $

-- -------------------------------------------------------------------------+
-- generate_base_summ_data_c with complete refresh mode.
--  Procedure to be called by the concurrent program to populate the
--  salesperson base summary table CN_SRP_DATA_SUMM_F.
-- -------------------------------------------------------------------------+
PROCEDURE generate_base_summ_data_c(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2,
                                    p_start_date IN VARCHAR2, p_end_date IN VARCHAR2);

-- -------------------------------------------------------------------------+
-- generate_base_summ_data_f with fast refresh mode.
--  Procedure to be called by the concurrent program to populate the
--  salesperson base summary table CN_SRP_DATA_SUMM_F.
-- -------------------------------------------------------------------------+
PROCEDURE generate_base_summ_data_f(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2);

END CN_BIS_SRP_DATA_GEN_PVT;

 

/
