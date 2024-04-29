--------------------------------------------------------
--  DDL for Package WMS_RCV_PUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RCV_PUP_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSRCVPS.pls 120.0.12010000.1 2008/07/28 18:36:22 appldev ship $*/

G_RET_STS_ERROR	       CONSTANT	VARCHAR2(1) := fnd_api.g_ret_sts_error;
G_RET_STS_UNEXP_ERR    CONSTANT	VARCHAR2(1) := fnd_api.g_ret_sts_unexp_error;
G_RET_STS_SUCCESS      CONSTANT	VARCHAR2(1) := fnd_api.g_ret_sts_success;

g_default_txn_mode CONSTANT VARCHAR2(25) := 'ONLINE';

TYPE number_tb_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

PROCEDURE pack_unpack_split
  (p_transaction_temp_id IN NUMBER DEFAULT NULL
   ,p_header_id           IN NUMBER DEFAULT NULL
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   );

PROCEDURE pack_unpack_split
  (p_transaction_temp_id IN NUMBER DEFAULT NULL
   ,p_header_id           IN NUMBER DEFAULT NULL
   ,p_call_rcv_tm         IN  VARCHAR2 DEFAULT fnd_api.g_true
   ,p_txn_mode_code       IN  VARCHAR2 DEFAULT g_default_txn_mode
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   ,x_mo_lines_tb         OUT nocopy inv_rcv_integration_apis.mo_in_tb_tp
   );

END wms_rcv_pup_pvt;

/
