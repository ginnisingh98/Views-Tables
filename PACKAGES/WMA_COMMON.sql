--------------------------------------------------------
--  DDL for Package WMA_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_COMMON" AUTHID CURRENT_USER AS
/* $Header: wmaccoms.pls 120.0.12000000.2 2007/03/13 21:13:37 kboonyap ship $ */

  /* Constants */

  -- length of our error messages
  ERR_LEN      CONSTANT NUMBER := WIP_CONSTANTS.ERR_LEN;
  SOURCE_CODE  CONSTANT VARCHAR2(11) := 'WMA MOBILE';
  SERIALIZATION_SOURCE_CODE CONSTANT VARCHAR2(29) := 'WMA SERIALIZATION MOBILE TXN';


  -- the number format
  WMA_NUMBER_FORMAT CONSTANT VARCHAR2(29) := '9999999999999999999.999999';


  /**
   * Record Types
   * Notes:
   * String lengths corrospond to constants defined in WIP_CONSTANTS
   */

  /**
   * environment information. Includes user info and organization info
   */
  TYPE Environment IS RECORD
  (
    orgID        NUMBER,
    orgCode      VARCHAR2(4),
    userID       NUMBER,
    userName     VARCHAR2(100)
  );


  /**
   * inventory item structure
   */
  /* ER 4378835: Increased length of lot_number from 31 to 80 to support OPM Lot-model changes */
  TYPE Item IS RECORD
  (
    invItemID               NUMBER,
    itemName                VARCHAR2(241),
    description             VARCHAR2(241),
    orgID                   NUMBER,
    primaryUOMCode          VARCHAR2(4),
    lotControlCode          NUMBER,
    autoLotAlphaPrefix      VARCHAR2(80),
    startAutoLotNumber      VARCHAR2(80),
    serialNumberControlCode NUMBER,
    autoSerialAlfaPrefix    VARCHAR2(31),
    startAutoSerialNumber   VARCHAR2(31),
    locationControlCode     NUMBER,
    revQtyControlCode       NUMBER,
    restrictLocatorsCode    NUMBER,
    restrictSubinvCode      NUMBER,
    shelfLifeCode           NUMBER,
    shelfLifeDays           NUMBER,
    invAssetFlag            VARCHAR2(2),
    allowedUnitsLookupCode  NUMBER,
    mtlTxnsEnabled          VARCHAR2(2),
    projectID               NUMBER,
    taskID                  NUMBER
  );


  /**
    * Discrete Job Structure
    */
  TYPE Job IS RECORD (
    wipEntityID               NUMBER,
    organizationID            NUMBER,
    jobName                   VARCHAR2(240),
    jobType                   NUMBER,
    description               VARCHAR2(240),
    primaryItemID             NUMBER,
    statusType                NUMBER,
    wipSupplyType             NUMBER,
    lineID                    NUMBER,
    lineCode                  VARCHAR2(11),
    scheduledStartDate        DATE,
    scheduledCompletionDate   DATE,
    startQuantity             NUMBER,
    quantityCompleted         NUMBER,
    quantityScrapped          NUMBER,
    completionSubinventory    VARCHAR2(10),
    completionLocatorID       NUMBER,
    projectID                 NUMBER,
    taskID                    NUMBER,
    endItemUnitNumber         VARCHAR2(30)
  );


END wma_common;

 

/
