--------------------------------------------------------
--  DDL for Package Body CN_BIS_SRP_MV_REFRESH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_BIS_SRP_MV_REFRESH_PVT" AS
-- $Header: cnvmvrfb.pls 115.6.1158.6 2003/07/29 17:13:11 ctoba noship $

PROCEDURE refresh_mv(p_top_mv_name IN VARCHAR2,x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN
NULL;

END refresh_mv;

PROCEDURE refresh_mv_generic(p_mv_name IN VARCHAR2,
                    x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN

NULL;

END refresh_mv_generic;


PROCEDURE refresh_quota_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN
    NULL;
END refresh_quota_mv;

PROCEDURE refresh_quota_sum_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN
NULL;
END refresh_quota_sum_mv;

PROCEDURE refresh_comm_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN
NULL;
END refresh_comm_mv;

PROCEDURE refresh_q_c_res_mv(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN
NULL;
END refresh_q_c_res_mv;

END CN_BIS_SRP_MV_REFRESH_PVT;

/
