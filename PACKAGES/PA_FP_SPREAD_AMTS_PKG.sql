--------------------------------------------------------
--  DDL for Package PA_FP_SPREAD_AMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_SPREAD_AMTS_PKG" AUTHID CURRENT_USER AS
--$Header: PAFPSCPS.pls 120.2 2007/02/06 10:11:17 dthakker noship $

  PROCEDURE spread_amounts
            ( p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE
             ,x_return_status      OUT NOCOPY VARCHAR2
             ,x_msg_count          OUT NOCOPY NUMBER
             ,x_msg_data           OUT NOCOPY VARCHAR2);


END PA_FP_SPREAD_AMTS_PKG;

/
