--------------------------------------------------------
--  DDL for Package WIP_AUTOSERIALPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_AUTOSERIALPROC_PRIV" AUTHID CURRENT_USER AS
 /* $Header: wipserps.pls 115.1 2002/11/13 03:02:32 kboonyap noship $ */

/******************************************************************************
 * This package will do serial derivation. It will take an object of items and
 * then derive serials for those items based on the genealogy built for
 * assembly. Serials can be derived as follows:
 *
 * Return           : A quantity tree is built to query the amount of onhand
 *                    serial quantities in the given backflush location.
 *
 * Issues           : Serial cannot be derived for this transaction type
 *                    because no genealogy have been built yet.
 *
 * Negative Return/ : Serial cannot be derived for these transaction types
 * Negative Issue     because no genealogy have been built for these txns
 *
 * parameters:
 * x_compLots        This parameter contains all the items that need to be
 *                   unbackflushed. On output, derived serial/lot are added to
 *                   the object appropriately.
 * p_objectID        Object_id of the parent serial(assembly). Used to derive
 *                   all the child serial number
 * p_orgID           Organization ID
 * p_initMsgList     Initialize the message list?
 * x_returnStatus    fnd_api.g_ret_sts_success if success without any errors.
 *                   Otherwise return fnd_api.g_ret_sts_unexp_error.
 *****************************************************************************/
  PROCEDURE deriveSerial(x_compLots  IN OUT NOCOPY system.wip_lot_serial_obj_t,
                         p_orgID         IN        NUMBER,
                         p_objectID      IN        NUMBER,
                         p_initMsgList   IN        VARCHAR2,
                         x_returnStatus OUT NOCOPY VARCHAR2);

END wip_autoSerialProc_priv;

 

/
