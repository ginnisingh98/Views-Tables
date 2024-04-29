--------------------------------------------------------
--  DDL for Package WMA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_UTIL" AUTHID CURRENT_USER AS
/* $Header: wmacutls.pls 115.6 2003/10/23 23:02:22 kmreddy ship $ */

  /**
   * This function returns the scrap account id for the specified orgnization.
   * The scrap account id is used as the default scrap account for scrap trx.
   */
  FUNCTION getScrapAcctID(orgID        IN     NUMBER,
                          scrapAcctID  OUT NOCOPY NUMBER,
                          errMsg       OUT NOCOPY VARCHAR2) return boolean;

  PROCEDURE getNegBalanceParams(p_org_id IN NUMBER,
                                x_neg_inv_allowed OUT NOCOPY NUMBER,
                                x_neg_bkflsh_allowed OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_err_msg OUT NOCOPY VARCHAR2);

  procedure getOverMovOrCplPickingWarning(p_wipEntityID number,
                                          p_orgID number,
                                          x_warningMsg out nocopy varchar2,
                                          x_displayWarning out nocopy varchar2);
END wma_util;

 

/
