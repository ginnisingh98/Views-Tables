--------------------------------------------------------
--  DDL for Package WMS_LMS_EXPECTED_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_LMS_EXPECTED_RES" AUTHID CURRENT_USER AS
/* $Header: WMSLMERS.pls 120.0 2005/06/16 03:58 viberry noship $ */


/**
  *   This is a Package that has procedures/functions that
  *   assists in estimating time/resource for various activities like
  *   inbound, outbound, Warehousing Activities
**/


G_PKG_NAME  VARCHAR2(30) := 'WMS_LMS_EXPECTED_RES';


/** This program populates the WMS_ELS_EXP_RESOURCE table, which is the base requirement <br>
*   for Expected Resource Requirements Analysis . WMS_ELS_EXP_RESOURCE table essentially <br>
*   has all the information for all future work that is expected in a Warehouse whether <br>
*   it is an Inbound, Outbound, Warehousing or Manufacturing activity. Based on this <br>
*   information the expected resource requirement will be calculated. <br>
*   The following is list if the inputs for populating this table. <br>
*  1. Receiving Inbound
*    o  Expected Purchase Order Receipts to be received in the given time frame <br>
*    o  Expected ASN material to be received in the given time frame <br>
*    o  Expected Internal Transfers to be received in the given time frame <br>
*    o  Expected RMAs to be received in the given time frame <br>
*  2.  Receiving Inbound <br>
*     o Material that is received, but needs to be putaway <br>
*  3. Inventory Accuracy <br>
*   Cycle count tasks outstanding <br>
* 4. Outbound Shipping / Manufacturing <br>
*    o  Unreleased / pending / queued / dispatched tasks for Sales orders,<br>
*       manufacturing component picks, and internal orders <br>
* 5. Manufacturing Putaways <br>
* 6. Pending and outstanding replenishment tasks <br>

* @param x_return_status                   return_status(OUT Parameter)
* @param x_msg_count                       Count of the recent message(OUT Parameter)
* @param x_msg_data                        Data of the message(OUT Parameter)
* @param p_org_id                         The organization Id
*/


PROCEDURE POPULATE_EXPECTED_WORK
                           (  x_return_status     OUT NOCOPY VARCHAR2
                            , x_msg_count         OUT NOCOPY VARCHAR2
                            , x_msg_data          OUT NOCOPY VARCHAR2
                            , p_org_id            IN         NUMBER
                           );



/* We would do the following in this procedure <br>

* Delete all the rows that are already populated in the WMS_ELS_EXP_RESOURCE for <br>
* that organization. This is done so that no old rows are left in the table and the <br>
* table can be freshly populated with expected work. This also ensures that all the <br>
* tasks and expected work that is already done is flushed out and is not accounted any more.<br>
*
* Populate the WMS_ELS_EXP_RESOURCE table with the fresh set of expected work for <br>
* the given data period(populated in the global setup).This will be done by calling <br>
* the program WMS_ELS_EXPECTED_RES. Populate_Expecetd_Work.<br>
*
* Do the matching of the rows in WMS_ELS_EXP_RESOURCE table with the setup rows <br>
* in WMS_ELS_INDIVIDUAL_TASKS_B using the where clause for that setup row(dynamic SQL), <br>
* starting with the setup row having the least sequence number. Once a match is found <br>
* stamp the Estimated_time column in WMS_ELS_EXP_RESOURCE  table with the time required <br>
* to complete the transaction. Also stamp the Expecetd_Resource column based on the global <br>
* setup.<br>
*
* The parameters p_data_period_unit, p_data_period_value,<br>
* p_Num_work_hrs_day ,p_Utilization_rate will not be directly used in this <br>
* program. They are being passed in to retain the link that at the time of <br>
* running the concurrent what was the value of these global parameters <br>
*
* @param p_org_id                     The organization Id
* @param errbuf                       This is the out message having the buffer of the return message
* @param retcode                      This variable is a out variable having the return code of <br)
*                                     the is program. Whether this program is a success,<br>
*                                     warning or a failure  <br>
* @parame p_data_period_unit         This parameter signifies what is the unit of measure <br>
*                                     of data period(days,weeks etc) <br>
* @param p_data_period_value         This gives the value of data period example 2(days).<br>
*                                     here 2 is data period value <br>
* @param p_Num_work_hrs_day          Number of working hrs per day
* @param p_Utilization_rate          What is the utilzation rate of the employees
*/

PROCEDURE MATCH_RATE_EXP_RESOURCE (
                                     errbuf             OUT    NOCOPY VARCHAR2
                                   , retcode            OUT    NOCOPY NUMBER
                                   , p_org_id           IN            NUMBER
                                   , p_data_period_unit IN            NUMBER
                                   , p_data_period_value IN           NUMBER
                                   , p_Num_work_hrs_day IN            NUMBER
                                   , p_Utilization_rate IN            NUMBER
                                     );

END WMS_LMS_EXPECTED_RES;


 

/
