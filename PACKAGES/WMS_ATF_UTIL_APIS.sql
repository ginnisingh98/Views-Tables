--------------------------------------------------------
--  DDL for Package WMS_ATF_UTIL_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ATF_UTIL_APIS" AUTHID CURRENT_USER AS
/* $Header: WMSOPUTS.pls 115.2 2003/09/18 23:08:00 lezhang noship $ */

PROCEDURE assign_operation_plan
  (
   p_api_version                  IN   NUMBER,
   p_init_msg_list                IN   VARCHAR2 DEFAULT 'F',
   p_commit                       IN   VARCHAR2 DEFAULT 'F',
   p_validation_level             IN   NUMBER   DEFAULT 100,
   x_return_status                OUT  NOCOPY VARCHAR2,
   x_msg_count                    OUT  NOCOPY NUMBER,
   x_msg_data                     OUT  NOCOPY VARCHAR2,
   p_task_id                      IN   NUMBER,
   p_activity_type_id             IN   NUMBER   DEFAULT NULL,
   p_organization_id              IN   NUMBER   DEFAULT NULL
   );


  /**
  *   complete_tm_processing
  *
  *   <p>This API conlcudes the exeuction of an operation plan.</P>
  *
  *   <p>Inventory transaction manager should call this API:
  *      1. After processing a transaction;
  *      2. Before deleting the MMTT record;
  *      3. WHen MMTT.operation_plan_ID IS NOT NULL. </P>
  *
  *
  *  @param x_return_status          -Return Status
  *  @param x_msg_data               -Returns the Error message Data
  *  @param x_msg_count              -Returns the message count
  *  @param p_organization_id        -Organization ID
  *  @param p_txn_header_id          -MMTT.transaction_header_id (passed when TM fails to process one MMTT within a batch)
  *  @param p_txn_batch_id           -MMTT.transaction_batch_id (passed when TM fails to process one MMTT within a batch)
  *  @param p_transaction_temp_id    -MMTT.transaction_temp_id (passed when TM successfully processed one MMTT)
  *  @param p_tm_complete_status     -Return status of TM processing: 0 - success, else failure
  *  @param p_txn_processing_mode    -Mode in which TM was called: 1 - online, 2 - background, 3 - concurrent

  **/


    PROCEDURE complete_tm_processing
    (
     x_return_status                OUT  NOCOPY VARCHAR2,
     x_msg_count                    OUT  NOCOPY NUMBER,
     x_msg_data                     OUT  NOCOPY VARCHAR2,
     p_organization_id              IN   NUMBER,
     p_txn_header_id                IN   NUMBER DEFAULT NULL,
     p_txn_batch_id                 IN   NUMBER DEFAULT NULL,
     p_transaction_temp_id          IN   NUMBER DEFAULT NULL,
     p_tm_complete_status           IN   NUMBER,
     p_txn_processing_mode          IN   NUMBER
     );


END WMS_ATF_Util_APIs;

 

/
