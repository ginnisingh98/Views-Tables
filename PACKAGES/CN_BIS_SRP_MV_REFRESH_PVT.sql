--------------------------------------------------------
--  DDL for Package CN_BIS_SRP_MV_REFRESH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_BIS_SRP_MV_REFRESH_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvmvrfs.pls 115.3.1158.4 2003/07/29 17:13:31 ctoba noship $

-- -------------------------------------------------------------------------+
-- refresh_quota_mv
--  Procedure to be called by the concurrent program to refresh the
--  materialized View:
--
--  CN_SRP_QUOTA_MV
-- -------------------------------------------------------------------------+
PROCEDURE refresh_quota_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2);

-- -------------------------------------------------------------------------+
-- refresh_quota_sum_mv
--  Procedure to be called by the concurrent program to refresh the
--  materialized View:
--
--  CN_SRP_QUOTA_SUM_MV
-- -------------------------------------------------------------------------+
PROCEDURE refresh_quota_sum_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2);

-- -------------------------------------------------------------------------+
-- refresh_comm_mv
--  Procedure to be called by the concurrent program to refresh the
--  materialized View:
--
--  CN_SRP_COMM_MV
-- -------------------------------------------------------------------------+
PROCEDURE refresh_comm_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2);

-- -------------------------------------------------------------------------+
-- refresh_q_c_res_mv
--  Procedure to be called by the concurrent program to refresh the
--  materialized View:
--
--  CN_SRP_Q_C_RES_MV
-- -------------------------------------------------------------------------+
PROCEDURE refresh_q_c_res_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2);

END CN_BIS_SRP_MV_REFRESH_PVT;

 

/
