--------------------------------------------------------
--  DDL for Package CN_SCA_CREDITS_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_CREDITS_BATCH_PUB" AUTHID CURRENT_USER AS
  -- $Header: cnpscabs.pls 120.3.12010000.10 2009/05/26 09:50:45 gmarwah ship $
  /*#
  * This package is accessed by users of the Sales Credit Allocation Module via
  * the concurrent program. The package takes start and end dates and the
  * Transaction Source as input and processes the transactions available in
  * the Interface tables. After completing the processing it populates the
  * results in the output Interface tables
  * @rep:scope public
  * @rep:product CN
  * @rep:displayname Get Sales Credits Public Application Program Interface
  * @rep:lifecycle active
  * @rep:compatibility S
  * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
  */
  -- +======================================================================+
  -- |                Copyright (c) 1994 Oracle Corporation                 |
  -- |                   Redwood Shores, California, USA                    |
  -- |                        All rights reserved.                          |
  -- +======================================================================+
  --
  -- Package Name
  --   CN_SCA_CREDITS_BATCH_PUB
  -- Purpose
  --   This package is a public API for processing Credit Rules and associated
  --   allocation percentages.
  -- History
  --   06/26/03   Rao.Chenna         Created
  --

  TYPE sub_program_id_type IS TABLE OF NUMBER;
  g_num_workers NUMBER;
  --
  PROCEDURE conc_submit
    (
      x_conc_program         IN            VARCHAR2,
      x_parent_proc_audit_id IN            NUMBER,
      x_physical_batch_id    IN            NUMBER,
      x_start_date           IN            DATE,
      x_end_date             IN            DATE,
      p_transaction_source   IN            VARCHAR2,
      p_org_id               IN            NUMBER,
      x_request_id           IN OUT NOCOPY NUMBER);
  --
  PROCEDURE conc_dispatch
    (
      x_parent_proc_audit_id IN NUMBER,
      x_start_date           IN DATE,
      x_end_date             IN DATE,
      x_logical_batch_id     IN NUMBER,
      x_transaction_source   IN VARCHAR2,
      p_org_id               IN NUMBER);
  --
  PROCEDURE split_batches
    (
      p_logical_batch_id   IN         NUMBER,
      p_start_date         IN         DATE,
      p_end_date           IN         DATE,
      p_transaction_source IN         VARCHAR2,
      p_org_id             IN         NUMBER,
      x_size               OUT NOCOPY NUMBER);
  --
  /*--------------------------------------------------------------------------
  API name      : get_sales_credits
  Type          : Public
  Pre-reqs      :
  Usage         :
  Desc          :
  Parameters
  IN            :
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.G_TRUE,
  p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
  p_commit                IN      VARCHAR2 := CN_API.G_FALSE,
  OUT NOCOPY    :
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  Notes         :
  .
  --------------------------------------------------------------------------*/
  /*#
  * The GET_SALES_CREDITS procedure in CN_SCA_CREDITS_BATCH_PUB is used for
  * determining the distribution of sales credit allocation percentages among the
  * different resources and role combinations who took part in the sales transaction.
  * The transactions are loaded into the CN_SCA_HEADERS_INTERFACE table before calling
  * this procedure. This procedure processes the transactions and identifies the Sales
  * Credit Rules based on the attribute information on the transaction and results
  * are populated into the CN_SCA_OUTPUT_LINES table.
  * @param p_transaction_source The Sales Credit Allocation module supports multiple
  * transaction sources. This parameter is used as a filter to identify the transactions
  * to be processed by the Rules Engine.
  * @param p_start_date Start Date
  * @param p_end_date End Date
  * @param errbuf Standard OUT parameter
  * @param retcode Standard OUT parameter
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Sales Credits (Batch Mode)
  */
  PROCEDURE get_sales_credits
    (
      errbuf               OUT NOCOPY VARCHAR2,
      retcode              OUT NOCOPY NUMBER,
      p_transaction_source IN         VARCHAR2,
      p_start_date         IN         VARCHAR2,
      p_end_date           IN         VARCHAR2);
  --
  PROCEDURE get_assignments
    (
      errbuf       OUT NOCOPY VARCHAR2,
      retcode      OUT NOCOPY VARCHAR2,
      p_org_id     IN         NUMBER,
      p_start_date IN         VARCHAR2,
      p_end_date   IN         VARCHAR2,
      p_run_mode   IN         VARCHAR2,
      p_terr_id    IN         NUMBER DEFAULT NULL);
  --
  PROCEDURE batch_process_txns
    (
      errbuf       OUT NOCOPY VARCHAR2,
      retcode      OUT NOCOPY VARCHAR2,
      p_org_id     IN         NUMBER,
      p_run_mode   IN         VARCHAR2,
      p_worker_id  IN         NUMBER);
  --
  PROCEDURE batch_collect_txns
    (
      errbuf        OUT NOCOPY VARCHAR2,
      retcode       OUT NOCOPY VARCHAR2,
      lp_start_date IN         DATE,
      lp_end_date   IN         DATE,
      p_org_id      IN         NUMBER,
      p_run_mode    IN         VARCHAR2,
      l_num_workers IN         NUMBER,
      p_request_id  IN         NUMBER);
  --
  PROCEDURE batch_process_winners
    (
      errbuf      OUT NOCOPY VARCHAR2,
      retcode     OUT NOCOPY VARCHAR2,
      p_worker_id IN         NUMBER,
      p_oic_mode  IN         VARCHAR2,
      p_terr_id   IN         NUMBER);
  --
  FUNCTION convert_to_table
    RETURN cn_sca_insert_tbl_type ;
  --
END CN_SCA_CREDITS_BATCH_PUB; -- Package spec

/
