--------------------------------------------------------
--  DDL for Package WMS_INSERT_WDTH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_INSERT_WDTH_PVT" AUTHID CURRENT_USER AS
  /* $Header: WMSWDTHS.pls 120.0 2005/05/25 09:06:01 appldev noship $ */

  g_pkg_spec_ver  CONSTANT VARCHAR2(100) := '$Header: WMSWDTHS.pls 120.0 2005/05/25 09:06:01 appldev noship $';
  g_pkg_name      CONSTANT VARCHAR2(30)  := 'WMS_INSERT_WDTH_PVT';

  PROCEDURE insert_into_wdth
  ( x_return_status          OUT NOCOPY   VARCHAR2,
    p_txn_header_id          IN           NUMBER,
    p_transaction_temp_id    IN           NUMBER,
    p_transaction_batch_id   IN           NUMBER,
    p_transaction_batch_seq  IN           NUMBER,
    p_transfer_lpn_id        IN           NUMBER);

  PROCEDURE insert_into_wdth
  ( x_return_status          OUT NOCOPY   VARCHAR2,
    p_txn_header_id          IN           NUMBER,
    p_transaction_temp_id    IN           NUMBER,
    p_transaction_batch_id   IN           NUMBER,
    p_transaction_batch_seq  IN           NUMBER,
    p_transfer_lpn_id        IN           NUMBER,
    p_status                 IN           NUMBER);

END wms_insert_wdth_pvt;

 

/
