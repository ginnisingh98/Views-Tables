--------------------------------------------------------
--  DDL for Package WMA_SPECIAL_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_SPECIAL_LOVS" AUTHID CURRENT_USER AS
/* $Header: wmaslovs.pls 115.4 2002/11/14 23:20:21 jyeung ship $ */

  TYPE LovCurType is REF CURSOR;

  /**
   * This procedure is used by SubinvLovBean as the lov statement. The OUT param
   * is a ref cursor which contains all the subinv that are valid for the given
   * item.
   */
  PROCEDURE getSubinventories(
                subinventories  OUT NOCOPY LovCurType,
                orgID           IN  NUMBER,
                itemID          IN  NUMBER,
	        trxTypeID	IN  NUMBER,
                invName         IN  VARCHAR2);

  /**
   * This function is used by the LocatorLovBean. It returns a interger with 1 being
   * locator controlled and 2 as not. The ideal is to return a boolean instead of
   * number. But it seems that Callable statment can't set the type to TYPE.BIT
   */
  FUNCTION locatorControl(
                orgID     IN  NUMBER,
                subinv    IN  VARCHAR2,
                itemID    IN  NUMBER) RETURN NUMBER;

  /**
   * This procedure is used by the LocatorLovBean as the lov statement. The OUT param
   * is a ref cursor which contains all the valid locators for the given item.
   */
  PROCEDURE getLocators(
                locators  OUT NOCOPY LovCurType,
                orgID     IN  NUMBER,
                subinv    IN  VARCHAR2,
                itemID    IN  NUMBER,
	        trxTypeID IN  NUMBER,
                locName   IN  VARCHAR2);

END wma_special_lovs;

 

/
