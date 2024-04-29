--------------------------------------------------------
--  DDL for Package WMA_DERIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_DERIVE" AUTHID CURRENT_USER AS
/* $Header: wmacdrvs.pls 115.4 2002/12/12 16:05:28 rmahidha ship $ */

  /**
   * returns mobile txn mode:
   * wip_constants.online or wip_constants.background
   */
  FUNCTION getTxnMode (orgID IN NUMBER) return NUMBER;

  /**
   * returns the next value in a database sequence
   */
  FUNCTION getNextVal (sequence IN VARCHAR2) return NUMBER;

  /**
   * given an itemID, getItem populates the wma_common.Item structure
   * with the item information.
   */
  FUNCTION getItem (
    itemID IN NUMBER,
    orgID  IN NUMBER) return wma_common.Item;

  /**
   * given an itemID and a locatorID, getItem populates the
   * wma_common.Item structure with the item information. Calling this
   * version of getItem fills in the projectID and taskID fields of
   * wma_common.Item
   */
  FUNCTION getItem (
    itemID    IN NUMBER,
    orgID     IN NUMBER,
    locatorID IN NUMBER) return wma_common.Item;

  /**
   * getJob will fill out the structure wma_common.Job given the
   * wipEntityID. Note that the given wipEntityID should be connected
   * to a discrete job instead of a repetitive schedule.
   */
  Function getJob(wipEntityID NUMBER) return wma_common.Job;

  /**
   * deriveEnvironment will take a partially filled  Environment
   * (the ID's must be filled) and derive the rest of the structure
   * as possible depending on the information available to it.
   */
  PROCEDURE deriveEnvironment(environment IN OUT NOCOPY wma_common.Environment);


END wma_derive;

 

/
