--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_TYPES_PUB" AUTHID CURRENT_USER as
/* $Header: PAFTYPPS.pls 120.1 2005/08/19 16:32:25 mwasowic noship $ */

procedure delete
    (p_fin_plan_type_id               IN     pa_fin_plan_types_b.fin_plan_type_id%type,
     p_record_version_number          IN     pa_fin_plan_types_b.record_version_number%type,
     x_return_status       	      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count           	      OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data		              OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_fin_plan_types_pub;
 

/
