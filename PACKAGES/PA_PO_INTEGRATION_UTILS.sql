--------------------------------------------------------
--  DDL for Package PA_PO_INTEGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PO_INTEGRATION_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPOUTLS.pls 120.2.12010000.2 2009/08/19 10:23:54 anuragar ship $ */

G_err_code NUMBER;
G_INVOKE_PA_SEC NUMBER:=0; --anuragag for 8815657
--anuragag for 8815657
FUNCTION PA_USER_PO_ACCESS_CHECK(x_po_header_id IN NUMBER,
                                 x_proj_user_id   IN NUMBER,
                                 x_mode IN  VARCHAR2 DEFAULT 'VIEW'  /* Mode can have 2 values 'VIEW'  or 'UPDATE'*/)
RETURN varchar2;
--anuragag for 8815657
FUNCTION PA_USER_PO_ACCESS_PROJ(x_proj_id IN NUMBER,
                                 x_proj_user_id   IN NUMBER)
RETURN varchar2;


FUNCTION Allow_Project_Info_Change ( p_po_distribution_id IN po_distributions_all.po_distribution_id%type)
RETURN varchar2;

--Added for bug 4407908
/*This is a public API, which will update PA_ADDITION_FLAG in
  rcv_receiving_sub_ledger table. This API will be called from
  purchasing module at the time of receipt creation.*/

PROCEDURE Update_PA_Addition_Flg (p_api_version       IN  NUMBER,
                                  p_init_msg_list     IN  VARCHAR2 default FND_API.G_FALSE,
                                  p_commit            IN  VARCHAR2 default FND_API.G_FALSE,
                                  p_validation_level  IN  NUMBER   default FND_API.G_VALID_LEVEL_FULL,
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_msg_count         OUT NOCOPY NUMBER,
                                  x_msg_data          OUT NOCOPY VARCHAR2,
                                  p_rcv_transaction_id  IN  NUMBER,
                                  p_po_distribution_id  IN  NUMBER,
				  p_accounting_event_id IN  NUMBER);

END pa_po_integration_utils;

/
