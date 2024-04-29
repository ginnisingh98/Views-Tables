--------------------------------------------------------
--  DDL for Package Body WMA_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_RESOURCE" AS
/* $Header: wmapresb.pls 115.2 2002/11/13 03:08:09 kboonyap noship $ */

  /**
   * This procedure is the entry point into the Resource Transaction
   * processing code for background processing.
   * Parameters:
   *   parameters  ResParams contains values from the mobile form.
   *   status      Indicates success (0), failure (-1).
   *   errMessage  The error or warning message, if any.
   */
  PROCEDURE process(parameters  IN        ResParams,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2) IS
    error VARCHAR2(241);                        -- error message
    resRecord ResTxnRec;                        -- record to populate and insert
  BEGIN
    status := 0;

    -- derive and validate all necessary fields for insertion
    if (derive(resRecord, parameters, error) = FALSE) then
      -- process error
      status := -1;
      errMessage := error;
      return;
    end if;

    -- insert into the interface table for background processing
    if (put(resRecord, error) = FALSE) then
      -- process error
      status := -1;
      errMessage := error;
      return;
    end if;

  EXCEPTION
    when others then
      status := -1;
      fnd_message.set_name ('WMA', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_resource.process');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;

  END process;


  /**
   * This function derives and validates the values necessary for executing a
   * resource transaction. Given the form parameters, it populates
   * resRecord preparing it to be inserted into the interface table.
   * Parameters:
   *   resRecord  record to be populated. The minimum number of fields to
   *              execute the transaction successfully are populated
   *   parameters resource transaction mobile form parameters
   *   errMessage populated if an error occurrs
   * Return:
   *   boolean    flag indicating the successful derivation of necessary values
   */
  Function derive(resRecord  IN OUT NOCOPY ResTxnRec,
                  parameters     IN ResParams,
                  errMessage IN OUT NOCOPY VARCHAR2)
  return boolean IS

  BEGIN
    /**
     * populate required fields in the resource record. If the fields specify
     * a resource not defined in the operation, the Cost Manager associates
     * this new resource to the operation, then charges the resource
     */
    resRecord.row.created_by_name := parameters.environment.userName;
    resRecord.row.creation_date := sysdate;
    resRecord.row.last_update_date := sysdate;
    resRecord.row.last_updated_by_name := parameters.environment.userName;
    resRecord.row.operation_seq_num := parameters.opSeq;
    resRecord.row.organization_code := parameters.environment.orgCode;
    resRecord.row.organization_id := parameters.environment.orgID;
    resRecord.row.process_phase := WIP_CONSTANTS.RES_VAL;
    resRecord.row.process_status := WIP_CONSTANTS.PENDING;
    resRecord.row.resource_code := parameters.resourceName;
    resRecord.row.resource_seq_num := parameters.resourceSeq;
    resRecord.row.source_code := WMA_COMMON.SOURCE_CODE;
    resRecord.row.transaction_date := sysdate;
    resRecord.row.transaction_quantity := parameters.transactionQty;
    resRecord.row.transaction_type := WIP_CONSTANTS.RES_TXN;
    resRecord.row.transaction_uom := parameters.transactionUOM;
    resRecord.row.entity_type := WIP_CONSTANTS.DISCRETE;
    resRecord.row.wip_entity_id := parameters.wipEntityID;
    resRecord.row.wip_entity_name := parameters.wipEntityName;

    return true;

  EXCEPTION
    when others then
      fnd_message.set_name ('WMA', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_resource.derive');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      return false;
  END derive;


  /**
   * Inserts a populated ResTxnRec record into WIP_COST_TXN_INTERFACE
   * Parameters:
   *   resRecord  The ResTxnRec representing the row to be inserted.
   *   errMessage populated if an error occurrs
   * Return:
   *   boolean    A flag indicating whether table update was successful or not.
   */
  Function put(resRecord      IN        ResTxnRec,
               errMessage IN OUT NOCOPY VARCHAR2) RETURN boolean IS

  BEGIN

    insert into wip_cost_txn_interface
           (created_by_name,
            creation_date,
            last_update_date,
            last_updated_by_name,
            operation_seq_num,
            organization_code,
            organization_id,
            process_phase,
            process_status,
            resource_code,
            resource_seq_num,
            source_code,
            transaction_date,
            transaction_quantity,
            transaction_type,
            transaction_uom,
            entity_type,
            wip_entity_id,
            wip_entity_name)
    values (resRecord.row.created_by_name,
            resRecord.row.creation_date,
            resRecord.row.last_update_date,
            resRecord.row.last_updated_by_name,
            resRecord.row.operation_seq_num,
            resRecord.row.organization_code,
            resRecord.row.organization_id,
            resRecord.row.process_phase,
            resRecord.row.process_status,
            resRecord.row.resource_code,
            resRecord.row.resource_seq_num,
            resRecord.row.source_code,
            resRecord.row.transaction_date,
            resRecord.row.transaction_quantity,
            resRecord.row.transaction_type,
            resRecord.row.transaction_uom,
            resRecord.row.entity_type,
            resRecord.row.wip_entity_id,
            resRecord.row.wip_entity_name);

    return true;

  EXCEPTION
    when others then
      fnd_message.set_name ('WMA', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_resource.put');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      return false;
  END put;


end wma_resource;

/
