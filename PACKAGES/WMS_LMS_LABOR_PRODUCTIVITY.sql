--------------------------------------------------------
--  DDL for Package WMS_LMS_LABOR_PRODUCTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_LMS_LABOR_PRODUCTIVITY" AUTHID CURRENT_USER AS
/* $Header: WMSLMLPS.pls 120.1 2005/06/17 03:52 viberry noship $ */

--WMS_ELS_LABOR_PRODUCTIVITY  Package
-- File        : INV/WMS...B/S.pls
-- Content     :
-- Description :
/**
  *   This is a Package that has procedures/functions that
  *   assists in estimating labor productivity
**/
-- Notes       :
-- Modified    : Fri Jul 30 13:28:37 GMT+05:30 2004

G_PKG_NAME  VARCHAR2(30) := 'WMS_LMS_LABOR_PRODUCTIVITY';



/**  This procedure will match all the transaction records in wms_els_trx_src <br>
*    table with the setup rows in wms_els_individual_tasks_b and wms_els_grouped_tasks_b <br>
*    It will DO the following <br>
*
* 1) do the matching of transaction data with els data. Start with the setup row <br>
*    with least sequnce.Update the els_data_id column of WMS_ELS_TRX_SRC table <br>
*    with the eld_data_id of the setup line with which the matching was found  <br>
*    update the zone and item category columns with zone_id's and item_category_id of the <br>
*    els data row with which the match was found.<br>
* 2). Update the travel and the idle time in the for the transaction row by <br>
*     considering the threshold value.<br>
*  3) update the ratings and the score <br>
*  4) Do the matching for groups based on grouped task identifier <br>

* @param p_org_id                     The organization Id
* @param errbuf                       This is the out message having the buffer of the return message
* @param retcode                      This variable is a out variable having the return code of the is program.
                                      Whether this program is a success, warning or a failure
*/

PROCEDURE MATCH_RATE_TRX_RECORDS  (
                                     errbuf   OUT    NOCOPY VARCHAR2
                                   , retcode  OUT    NOCOPY NUMBER
                                   , p_org_id IN            NUMBER
                                  );






END WMS_LMS_LABOR_PRODUCTIVITY;



 

/
