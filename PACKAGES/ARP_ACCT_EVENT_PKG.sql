--------------------------------------------------------
--  DDL for Package ARP_ACCT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ACCT_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXLUTS.pls 120.4 2006/08/09 18:35:59 hyu noship $ */

PROCEDURE update_dates_for_trx_event
(p_source_id_int_1    IN NUMBER,
 p_trx_number         IN VARCHAR2,
 p_legal_entity_id    IN NUMBER,
 p_ledger_id          IN NUMBER,
 p_org_id             IN NUMBER,
 p_event_id           IN NUMBER,
 p_valuation_method   IN VARCHAR2,
 p_entity_type_code   IN VARCHAR2,
 p_event_type_code    IN VARCHAR2,
 p_curr_event_date    IN DATE,
 p_event_date         IN DATE,
 p_status             IN VARCHAR2,
 p_action             IN VARCHAR2,
 p_curr_trx_date      IN DATE,
 p_transaction_date   IN DATE,
 x_event_id           OUT NOCOPY NUMBER);

--{
PROCEDURE get_ar_trx_event_info
(p_entity_code      IN VARCHAR2,
 p_source_int_id    IN NUMBER);

PROCEDURE get_xla_event_info
(p_entity_code     IN VARCHAR2,
 p_source_int_id   IN NUMBER);

PROCEDURE ar_event_existence
(p_entity_code       IN VARCHAR2,
 p_source_int_id     IN NUMBER,
 x_result           OUT NOCOPY VARCHAR2);

/*------------------------------------------------------------------------------+
 | Input arguments                                                              |
 | ---------------                                                              |
 | * p_init_msg_list in                                                         |
 |      FND_API.G_FALSE  --> do not initial the message stack                   |
 |      FND_API.G_TUR    --> initial the message stack                          |
 | * p_entity_code in                                                           |
 |     'TRANSACTIONS'                                                           |
 |     'RECEIPTS'                                                               |
 |     'ADJUSTMENTS'                                                            |
 |     'BILLS_RECEIVABLE'                                                       |
 | * p_source_int_id the primary key of each AR entity is                       |
 |     For entity TRANSACTIONS     --> customer_trx_id                          |
 |     For entity RECEIPTS         --> cash_receipt_id                          |
 |     For entity ADJUSTMENTS      --> adjustment_id                            |
 |     For entity BILLS_RECEIVABLE --> customer_trx_id                          |
 | Output arguments                                                             |
 | ----------------                                                             |
 | * x_upgrade_status  :                                                        |
 |     Y if the entire document has been upgraded or is R12                     |
 |     N if the document has been partialy upgraded or not upgraded             |
 | * x_return_status   : fnd api status codification to indicate success or     |
 |                       error                                                  |
 | * x_msg_count       : number of messages generated in the stack              |
 | * x_msg_data        : the error message if only one message is stacked       |
 |                                                                              |
 +------------------------------------------------------------------------------*/
PROCEDURE upgrade_status_per_doc
(p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
 p_entity_code       IN VARCHAR2,
 p_source_int_id     IN NUMBER,
 x_upgrade_status    OUT NOCOPY VARCHAR2,
 x_return_status     OUT NOCOPY  VARCHAR2,
 x_msg_count         OUT NOCOPY  NUMBER,
 x_msg_data          OUT NOCOPY  VARCHAR2);
--}

--{
PROCEDURE r12_adj_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE r12_trx_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_type             IN VARCHAR2,
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE r12_crh_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER   DEFAULT NULL,
 p_type             IN VARCHAR2 DEFAULT 'ALL',
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE r12_app_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER DEFAULT NULL,
 p_type             IN VARCHAR2 DEFAULT 'ALL',
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE r12_th_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);

/*------------------------------------------------------------------------------+
 | Input arguments                                                              |
 | ---------------                                                              |
 | p_start_date       start gl_date                                             |
 | p_end_date         end gl_date                                               |
 | p_xla_post_status  do you want to check for posted data or unposted data     |
 | p_inv_flag         'Y' if you want to check for INV DEP GUAR otherwise 'N'   |
 | p_dm_flag          'Y' if you want to check for DM otherwise 'N'             |
 | p_cb_flag          'Y' if you want to check for CB otherwise 'N'             |
 | p_cm_flag          'Y' if you want to check for CM otherwise 'N'             |
 | p_cmapp_flag       'Y' if you want to check for CMAPP otherwise 'N'          |
 | p_adj_flag         'Y' if you want to check for ADJ otherwise 'N'            |
 | p_recp_flag        'Y' if you want to check for CR of type CASH otherwise 'N'|
 | p_misc_flag        'Y' if you want to check for CR of type MISC otherwise 'N'|
 | p_bill_flag        'Y' if you want to check for BILL otherwise 'N'           |
 | p_org_id           org_id can be left to NULL for multi org                  |
 | Output arguments                                                             |
 | ----------------                                                             |
 | * x_return_status                                                            |
 |         1) fnd_api.g_ret_sts_success                                         |
 |           if all AR unposted distributions have a distribution in XLA        |
 |           if all AR distribution are posted                                  |
 |         2) fnd_api.g_ret_sts_error                                           |
 |           if at least one unposted AR distribution does not have a           |
 |              distribution in XLA                                             |
 |         3) fnd_api.G_RET_STS_UNEXP_ERROR                                     |
 |           if unexpected error are found                                      |
 | * x_msg_count       : number of messages generated in the stack              |
 | * x_msg_data        : return all messages in the stack                       |
 |                                                                              |
 +------------------------------------------------------------------------------*/
PROCEDURE r12_dist_in_xla
(p_init_msg_list    IN VARCHAR2 := fnd_api.g_false,
 p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_xla_post_status  IN VARCHAR2 DEFAULT 'Y',
 p_inv_flag         IN VARCHAR2 DEFAULT 'Y',
 p_dm_flag          IN VARCHAR2 DEFAULT 'Y',
 p_cb_flag          IN VARCHAR2 DEFAULT 'Y',
 p_cm_flag          IN VARCHAR2 DEFAULT 'Y',
 p_cmapp_flag       IN VARCHAR2 DEFAULT 'Y',
 p_adj_flag         IN VARCHAR2 DEFAULT 'Y',
 p_recp_flag        IN VARCHAR2 DEFAULT 'Y',
 p_misc_flag        IN VARCHAR2 DEFAULT 'Y',
 p_bill_flag        IN VARCHAR2 DEFAULT 'Y',
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);
--}

--{BUG#4353362
PROCEDURE update_cr_dist
( p_ledger_id                 IN NUMBER
 ,p_source_id_int_1           IN NUMBER
 ,p_third_party_merge_date    IN DATE
 ,p_original_third_party_id   IN NUMBER
 ,p_original_site_id          IN NUMBER
 ,p_new_third_party_id        IN NUMBER
 ,p_new_site_id               IN NUMBER
 ,p_create_update             IN VARCHAR2 DEFAULT 'U'
 ,p_entity_code               IN VARCHAR2 DEFAULT 'RECEIPTS'
 ,p_type_of_third_party_merge IN VARCHAR2 DEFAULT 'PARTIAL'
 ,p_mapping_flag              IN VARCHAR2 DEFAULT 'N'
 ,p_execution_mode            IN VARCHAR2 DEFAULT 'SYNC'
 ,p_accounting_mode           IN VARCHAR2 DEFAULT 'F'
 ,p_transfer_to_gl_flag       IN VARCHAR2 DEFAULT 'Y'
 ,p_post_in_gl_flag           IN VARCHAR2 DEFAULT 'Y'
 ,p_third_party_type          IN VARCHAR2 DEFAULT 'C'
 ,x_errbuf                    OUT NOCOPY  VARCHAR2
 ,x_retcode                   OUT NOCOPY  VARCHAR2
 ,x_event_ids                 OUT NOCOPY  xla_third_party_merge_pub.t_event_ids
 ,x_request_id                OUT NOCOPY  NUMBER);
--}

PROCEDURE check_period_open
(p_entity_id        IN         NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);


END;

 

/
