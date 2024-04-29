--------------------------------------------------------
--  DDL for Package PA_BGT_BASELINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BGT_BASELINE_PKG" AUTHID CURRENT_USER AS
-- $Header: PAFCBALS.pls 120.1 2005/08/03 01:03:55 rshaik noship $
   PROCEDURE MAINTAIN_BAL_FCHK(
                p_project_id                  IN  number,
                p_budget_version_id           IN  number,
        	p_baselined_budget_version_id IN  NUMBER, --R12 Funds Management Uptake :Parameter to store newly baselined version ID
                p_bdgt_ctrl_type              IN  varchar2,
                p_calling_mode                IN  varchar2,
                p_bdgt_intg_flag              IN  varchar2,
                x_return_status               OUT NOCOPY varchar2,
                x_error_message_code          OUT NOCOPY varchar2);

END PA_BGT_BASELINE_PKG;

 

/
