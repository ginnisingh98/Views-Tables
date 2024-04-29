--------------------------------------------------------
--  DDL for Package WMA_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_RESOURCE" AUTHID CURRENT_USER AS
/* $Header: wmapress.pls 115.2 2002/11/13 03:07:29 kboonyap noship $ */

  /**
   * Contains the set of parameters that will be passed from the Mobile Apps
   * Resource Transaction form to the process procedure for processing the
   * transaction. The list contains all displayed fields as well as hidden
   * fields (derived from LOVs on the form)
   * All fields are initialized to FND_API initialization values. Boolean
   * values are initailized to false. Strings lengths are derived from
   * those defined in WIP_CONSTANTS package.
   */
  TYPE ResParams IS RECORD
  (
    environment       wma_common.environment,
    newResource       BOOLEAN,
    wipEntityID       NUMBER,
    wipEntityName     VARCHAR2(241),
    itemID            NUMBER,
    itemName          VARCHAR2(241),
    resourceID        NUMBER,
    resourceName      VARCHAR2(241),
    resourceSeq       NUMBER,
    opSeq             NUMBER,
    transactionQty    NUMBER,
    transactionUOM    VARCHAR2(4)
  );


  /**
   * This is the record type for the record to be populated and inserted into
   * the WIP_COST_TXN_INTERFACE table.
   */
  TYPE ResTxnRec IS RECORD (row wip_cost_txn_interface%ROWTYPE);


  /**
   * This procedure is the entry point into the Resource Transaction
   * processing code for background processing.
   */
  PROCEDURE process(parameters  IN        ResParams,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2);


  /**
   * This function derives and validates the values necessary for executing a
   * resource transaction. Given the form parameters, it populates
   * resRecord preparing it to be inserted into the interface table.
   */
  FUNCTION derive(resRecord  IN OUT NOCOPY ResTxnRec,
                  parameters     IN ResParams,
                  errMessage IN OUT NOCOPY VARCHAR2) return boolean;


  /**
   * Inserts a populated ResTxnRec record into WIP_COST_TXN_INTERFACE
   */
  FUNCTION put(resRecord      IN        ResTxnRec,
               errMessage IN OUT NOCOPY VARCHAR2) return boolean;


END wma_resource;

 

/
