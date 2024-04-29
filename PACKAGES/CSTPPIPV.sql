--------------------------------------------------------
--  DDL for Package CSTPPIPV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPIPV" AUTHID CURRENT_USER AS
/* $Header: CSTPIPVS.pls 120.2.12010000.2 2011/11/14 01:29:08 yuyun ship $*/

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|       trf_invoice_to_inventory                                             |
|       This procedure generates the necessary interface transactions to     |
|       transfer the invoice price variances of items that match the user    |
|       specified parameters to inventory.                                   |
|                                                                            |
|  p_item_option:                                                            |
|       1:  All Asset items                                                  |
|       2:  Specific Asset Item                                              |
|       5:  Category Items                                                   |
|                                                                            |
|  p_invoice_project_option:                                                 |
|       1:  All invoices                                                     |
|       2:  Project invoices                                                 |
|                                                                            |
|  aida.inventory_transfer_status:                                           |
|       N:     Not transferred                                               |
|       NULL:  Transferred or Not Applicable                                 |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE trf_invoice_to_inventory(
        errbuf                     OUT NOCOPY          VARCHAR2,
        retcode                    OUT NOCOPY          NUMBER,
        p_organization_id          IN           NUMBER,
        p_description              IN           VARCHAR2 DEFAULT NULL,
        p_item_option              IN           NUMBER,
        p_item_dummy               IN           NUMBER DEFAULT NULL,
        p_category_dummy           IN           NUMBER DEFAULT NULL,
        p_specific_item_id         IN           NUMBER DEFAULT NULL,
        p_category_set_id          IN           NUMBER DEFAULT NULL,
        p_category_validate_flag   IN           VARCHAR2 DEFAULT NULL,
        p_category_structure       IN           NUMBER DEFAULT NULL,
        p_category_id              IN           NUMBER DEFAULT NULL,
        p_invoice_project_option   IN           NUMBER,
        p_project_dummy            IN           NUMBER DEFAULT NULL,
        p_project_id               IN           NUMBER DEFAULT NULL,
        p_adj_account_dummy        IN           NUMBER,
        p_adj_account              IN           NUMBER,
        p_cutoff_date              IN           VARCHAR2,
        p_transaction_process_mode IN           NUMBER
);

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|       trf_invoice_to_wip                                                   |
|       This procedure generates the necessary interface transactions to     |
|       transfer the invoice price variances of items that match the user    |
|       specified parameters to the corresponding work orders in Work In     |
|       Process. Currently it's only processing the invoice price variances  |
|       of Outside Processing and Direct items for Maintenance Work Order.   |
|                                                                            |
|  p_item_type:                                                              |
|       1:  Outside Processing and Direct items                              |
|       2:  Outside Processing items only                                    |
|       3:  Direct Items only                                                |
|                                                                            |
|  p_item_option:                                                            |
|       1:  All OSP items                                                    |
|       2:  Specific OSP Item                                                |
|       5:  Category OSP Items                                               |
|                                                                            |
|  p_invoice_project_option:                                                 |
|       1:  All invoices                                                     |
|       2:  Project invoices                                                 |
|                                                                            |
|  aida.inventory_transfer_status:                                           |
|       N:     Not transferred                                               |
|       NULL:  Transferred or Not Applicable                                 |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE trf_invoice_to_wip(
        errbuf                     OUT NOCOPY          VARCHAR2,
        retcode                    OUT NOCOPY          NUMBER,
        p_organization_id          IN           NUMBER,
        p_description              IN           VARCHAR2 DEFAULT NULL,
        p_work_order_id            IN           NUMBER DEFAULT NULL,
        p_item_type                IN           NUMBER,
        p_item_type_dummy          IN           NUMBER DEFAULT NULL,
        p_item_option              IN           NUMBER DEFAULT NULL,
        p_item_dummy               IN           NUMBER DEFAULT NULL,
        p_category_dummy           IN           NUMBER DEFAULT NULL,
        p_specific_item_id         IN           NUMBER DEFAULT NULL,
        p_category_set_id          IN           NUMBER DEFAULT NULL,
        p_category_validate_flag   IN           VARCHAR2 DEFAULT NULL,
        p_category_structure       IN           NUMBER DEFAULT NULL,
        p_category_id              IN           NUMBER DEFAULT NULL,
        p_project_dummy            IN           NUMBER DEFAULT NULL,
        p_project_id               IN           NUMBER DEFAULT NULL,
        p_adj_account_dummy        IN           NUMBER,
        p_adj_account              IN           NUMBER,
        p_cutoff_date              IN           VARCHAR2,
        p_transaction_process_mode IN           NUMBER
);

FUNCTION trf_invoice_to_wip(
        errbuf                     OUT NOCOPY          VARCHAR2,
        retcode                    OUT NOCOPY          NUMBER,
        p_organization_id          IN           NUMBER,
        p_description              IN           VARCHAR2 DEFAULT NULL,
	p_work_order_id            IN           NUMBER DEFAULT NULL,
        p_item_type                IN           NUMBER,
        p_item_option              IN           NUMBER DEFAULT NULL,
        p_specific_item_id         IN           NUMBER DEFAULT NULL,
        p_category_set_id          IN           NUMBER DEFAULT NULL,
        p_category_id              IN           NUMBER DEFAULT NULL,
        p_project_id               IN           NUMBER DEFAULT NULL,
        p_adj_account              IN           NUMBER,
        p_cutoff_date              IN           VARCHAR2,
        p_transaction_process_mode IN           NUMBER,
	p_request_id		   IN		NUMBER,
	p_user_id		   IN		NUMBER,
	p_login_id		   IN		NUMBER,
	p_prog_appl_id		   IN 		NUMBER,
	p_prog_id	           IN		NUMBER
) return NUMBER;

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|       generate_trf_info                                                    |
|       This procedure generates the invoice price variances information     |
|       for the specified inventory item and cutoff date                     |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE generate_trf_info (
        p_organization_id          IN  NUMBER,
        p_inventory_item_id        IN  NUMBER,
        p_invoice_project_option   IN  NUMBER,
        p_project_id               IN  NUMBER,
        p_cost_group_id            IN  NUMBER,
        p_cutoff_date              IN  DATE,
  	p_user_id                  IN  NUMBER,
        p_login_id                 IN  NUMBER,
        p_request_id               IN  NUMBER,
        p_prog_id                  IN  NUMBER,
        p_prog_app_id              IN  NUMBER,
        p_batch_id                 IN  NUMBER,
        p_default_txn_date         IN  DATE,
        x_err_num                  OUT NOCOPY NUMBER,
        x_err_code                 OUT NOCOPY VARCHAR2,
        x_err_msg                  OUT NOCOPY VARCHAR2
);

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|       generate_wip_info                                                    |
|       This procedure generates the invoice price variances information     |
|       for the specified OSP or Direct item on the specified po             |
|       distribution and cutoff date.                                        |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE generate_wip_info (
	p_organization_id    	   IN  NUMBER,
	p_inventory_item_id  	   IN  NUMBER,
	p_project_id	     	   IN  NUMBER,
	p_po_distribution_id  	   IN  NUMBER,
        p_cutoff_date              IN  DATE,
  	p_user_id                  IN  NUMBER,
        p_login_id                 IN  NUMBER,
        p_request_id               IN  NUMBER,
        p_prog_id                  IN  NUMBER,
        p_prog_app_id              IN  NUMBER,
        p_batch_id                 IN  NUMBER,
	p_transaction_process_mode IN  NUMBER,
        p_default_txn_date         IN  DATE,
        x_err_num                  OUT NOCOPY NUMBER,
        x_err_code                 OUT NOCOPY VARCHAR2,
        x_err_msg                  OUT NOCOPY VARCHAR2
);

PROCEDURE get_upd_txn_date (
        p_po_distribution_id IN    NUMBER,
        p_default_txn_date   IN    DATE,
        p_organization_id    IN    NUMBER, --BUG#5709567-FPBUG5109100 --Bug #13075737, Release commented p_organization_id
        x_transaction_date   OUT NOCOPY   DATE,
        x_err_num            OUT NOCOPY   NUMBER,
        x_err_code           OUT NOCOPY   VARCHAR2,
        x_err_msg            OUT NOCOPY   VARCHAR2
);

PROCEDURE get_default_date (
        p_organization_id   IN    NUMBER,
        x_default_date      OUT NOCOPY   DATE,
        x_err_num           OUT NOCOPY   NUMBER,
        x_err_code          OUT NOCOPY   VARCHAR2,
        x_err_msg           OUT NOCOPY   VARCHAR2
);

END CSTPPIPV;

/
