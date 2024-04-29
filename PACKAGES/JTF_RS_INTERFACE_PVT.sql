--------------------------------------------------------
--  DDL for Package JTF_RS_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfrsvxs.pls 120.0.12010000.3 2009/06/04 22:20:05 nsinghai noship $ */
/*#
 * Import Resource and SalesRep from Interface API
 * This API contains the procedures to Import (create, update) Resource & SalesRep records.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource and Salesrep Interface API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
 * @rep:businessevent oracle.apps.jtf.jres.resource.create
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.user
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.effectivedate
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.attributes
*/
  /**********************************************************************************************
   This is a private API.
   It provides procedures for Import (create,update) resources and SalesRep from Interface tables.
   Its main procedures are as following:
   Import Resource
   Import Salesreps
   Calls to these procedures will invoke procedures from EBSI
   to do business validations and to do actual creates and updates into tables.
   ******************************************************************************************/

/*#
 * Import Resource API
 * This procedure allows the user to Import a resource record from Interface Table JTF_RS_RESOURCE_EXTNS_INT.
 * @param p_batch_id Batch Identifier.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Import Resource API
*/
  PROCEDURE import_resource
  (P_BATCH_ID                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
   );

/*#
 * Import Salesreps API
 * This procedure allows the user to Import a Sales Rep record from Interface Table JTF_RS_SALESREPS_INT.
 * @param p_batch_id Batch Identifier.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Import Salesreps API
*/
  PROCEDURE import_salesreps
  (P_BATCH_ID                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
   );


END jtf_rs_interface_pvt;

/
