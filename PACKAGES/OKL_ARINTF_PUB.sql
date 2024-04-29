--------------------------------------------------------
--  DDL for Package OKL_ARINTF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ARINTF_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPAINS.pls 120.4 2008/02/29 10:49:34 nikshah ship $ */
/*#
 * API for sending billing records to AR
 * @rep:scope internal
 * @rep:product OKL
 * @rep:displayname Receivables Invoice Transfer to AR
 * @rep:category BUSINESS_ENTITY  OKL_COLLECTION
 * @rep:lifecycle active
 * @rep:compatibility S
 */
subtype xsiv_rec_type is okl_ext_sell_invs_pub.xsiv_rec_type;
subtype xsiv_tbl_type is okl_ext_sell_invs_pub.xsiv_tbl_type;

G_ExtHdrRec          OKL_EXT_SELL_INVS_V%ROWTYPE;
G_ExtLineRec         OKL_XTL_SELL_INVS_V%ROWTYPE;
G_ExtDistrRec        OKL_XTD_SELL_INVS_V%ROWTYPE;

G_batch_source       varchar2(50) := 'OKL_CONTRACTS';
G_request_id         number       := FND_GLOBAL.CONC_REQUEST_ID;
G_user_id            number       := FND_global.user_id;
G_sysdate            date         := sysdate;

--x_return_status      VARCHAR2(3);
--x_msg_count          NUMBER;
--x_msg_data           VARCHAR2(2000);

--G_EXCEPTION_HALT_PROCESS    EXCEPTION;
/*#
 * Loads AR Interface table
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Error message data
 * @param p_trx_date_from Transaction from date
 * @param p_trx_date_to Error Transaction to date
 * @param p_assigned_process Assigned process
 * @rep:displayname Load AR Interface table
 * @rep:lifecycle active
 */
PROCEDURE Get_REC_FEEDER
  ( p_api_version                  IN  NUMBER
  , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
  , x_return_status                OUT NOCOPY VARCHAR2
  , x_msg_count                    OUT NOCOPY NUMBER
  , x_msg_data                     OUT NOCOPY VARCHAR2
  , p_trx_date_from                IN  DATE DEFAULT NULL
  , p_trx_date_to                  IN  DATE DEFAULT NULL
  , p_assigned_process             IN  VARCHAR2
  ) ;

PROCEDURE Get_REC_FEEDER_CONC
  ( errbuf             OUT NOCOPY VARCHAR2
  , retcode            OUT NOCOPY NUMBER
  , p_trx_date_from    IN  VARCHAR2
  , p_trx_date_to      IN  VARCHAR2
  , p_assigned_process IN  VARCHAR2
  ) ;

END OKL_ARIntf_PUB;

/
