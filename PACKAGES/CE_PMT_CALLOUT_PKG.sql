--------------------------------------------------------
--  DDL for Package CE_PMT_CALLOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_PMT_CALLOUT_PKG" AUTHID CURRENT_USER AS
/* $Header: cepmtcos.pls 120.1 2005/12/06 12:58:20 svali noship $ */
--

G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

PROCEDURE documents_payable_rejected(p_api_version NUMBER,
							 p_init_msg_list VARCHAR2,
							 p_commit VARCHAR2,
							 x_return_status OUT NOCOPY VARCHAR2,
							 x_msg_count OUT NOCOPY NUMBER,
							 x_msg_data OUT NOCOPY VARCHAR2,
							 p_rejected_docs_group_id NUMBER);

PROCEDURE payments_completed(p_api_version NUMBER,
					 p_init_msg_list VARCHAR2,
					 p_commit VARCHAR2,
					 x_return_status OUT NOCOPY VARCHAR2,
					 x_msg_count OUT NOCOPY NUMBER,
					 x_msg_data OUT NOCOPY VARCHAR2,
					 p_completed_pmts_group_id NUMBER);

PROCEDURE payment_voided(p_api_version	NUMBER,
				 p_payment_id	NUMBER,
				 p_void_date	DATE,
				 p_init_msg_list	VARCHAR2,
				 p_commit	VARCHAR2,
				 x_return_status OUT NOCOPY	VARCHAR2,
				 x_msg_count	OUT NOCOPY NUMBER,
				 x_msg_data	OUT NOCOPY VARCHAR2);

END CE_PMT_CALLOUT_PKG;

 

/
