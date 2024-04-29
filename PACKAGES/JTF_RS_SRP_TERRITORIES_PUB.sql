--------------------------------------------------------
--  DDL for Package JTF_RS_SRP_TERRITORIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_SRP_TERRITORIES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspis.pls 120.0 2005/05/11 08:21:12 appldev ship $ */
/*#
 * Salesrep Territories API
 * This API contains the procedures for managing resource salesrep territories
 * like create and update resource salesrep territories.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Salesrep Territories API
 * @rep:category BUSINESS_ENTITY JTF_RS_SRP_TERRITORY
*/
  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource salesrep territories, like
   create and update resource salesrep territories, from other modules.
   Its main procedures are as following:
   Create Resource Salesrep Territories
   Update Resource Salesrep Territories
   Calls to these procedures will invoke procedures from jtf_rs_srp_territories_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource salesrep territories
	based on input values passed by calling routines. */
/*#
 * Create Salesrep Territories API
 * This procedure allows the user to create resource salesrep territories record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_salesrep_id Salesperson Identifier
 * @param p_territory_id Territory Identifier
 * @param p_status The status of the salesperson.
 * @param p_wh_update_date This date is sent to the data warehouse
 * @param p_start_date_active Date on which the salesrep territories becomes active.
 * @param p_end_date_active Date on which the salesrep territories is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_salesrep_territory_id Out parameter for salesrep territory Identifier
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Salesrep Territories API
*/
  PROCEDURE  create_rs_srp_territories
  (P_API_VERSION          	IN   NUMBER,
   P_INIT_MSG_LIST        	IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               	IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SALESREP_ID		IN   JTF_RS_SRP_TERRITORIES.SALESREP_ID%TYPE,
   P_TERRITORY_ID		IN   JTF_RS_SRP_TERRITORIES.TERRITORY_ID%TYPE,
   P_STATUS         		IN   JTF_RS_SRP_TERRITORIES.STATUS%TYPE 		DEFAULT NULL,
   P_WH_UPDATE_DATE      	IN   JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE		DEFAULT NULL,
   P_START_DATE_ACTIVE    	IN   JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      	IN   JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE   	DEFAULT NULL,
   X_RETURN_STATUS        	OUT NOCOPY VARCHAR2,
   X_MSG_COUNT            	OUT NOCOPY NUMBER,
   X_MSG_DATA             	OUT NOCOPY VARCHAR2,
   X_SALESREP_TERRITORY_ID      OUT NOCOPY JTF_RS_SRP_TERRITORIES.SALESREP_TERRITORY_ID%TYPE
  );

  /* Procedure to update the resource salesrep territories
	based on input values passed by calling routines. */
/*#
 * Update Salesrep Territories API
 * This procedure allows the user to update resource salesrep territories record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_salesrep_id Salesperson Identifier
 * @param p_territory_id Territory Identifier
 * @param p_status The status of the salesperson.
 * @param p_wh_update_date This date is sent to the data warehouse
 * @param p_start_date_active Date on which the salesrep territories becomes active.
 * @param p_end_date_active Date on which the salesrep territories is no longer active.
 * @param p_object_version_number The object version number of the salesrep territory derives from the jtf_rs_srp_territories table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Salesrep Territories API
*/
  PROCEDURE  update_rs_srp_territories
  (P_API_VERSION          	IN   	NUMBER,
   P_INIT_MSG_LIST        	IN   	VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               	IN   	VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SALESREP_ID                IN   	JTF_RS_SRP_TERRITORIES.SALESREP_ID%TYPE,
   P_TERRITORY_ID               IN   	JTF_RS_SRP_TERRITORIES.TERRITORY_ID%TYPE,
   P_STATUS                     IN   	JTF_RS_SRP_TERRITORIES.STATUS%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_WH_UPDATE_DATE             IN   	JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE DEFAULT FND_API.G_MISS_DATE,
   P_START_DATE_ACTIVE          IN   	JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE DEFAULT FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE            IN   	JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE DEFAULT FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUMBER	IN OUT NOCOPY	JTF_RS_SRP_TERRITORIES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        	OUT NOCOPY 	VARCHAR2,
   X_MSG_COUNT            	OUT NOCOPY 	NUMBER,
   X_MSG_DATA             	OUT NOCOPY 	VARCHAR2
  );

END jtf_rs_srp_territories_pub;

 

/
