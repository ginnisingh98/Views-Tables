--------------------------------------------------------
--  DDL for Package JTF_RS_SRP_TERRITORIES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_SRP_TERRITORIES_VUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsiis.pls 120.0 2005/05/11 08:20:16 appldev ship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Vertical Industry Procedure for pre processing in case of create srp territories */

  PROCEDURE  create_rs_srp_territories_pre (
   P_SALESREP_ID     	IN   	JTF_RS_SRP_TERRITORIES.SALESREP_ID%TYPE,
   P_TERRITORY_ID    	IN   	JTF_RS_SRP_TERRITORIES.TERRITORY_ID%TYPE,
   P_STATUS        	IN   	JTF_RS_SRP_TERRITORIES.STATUS%TYPE,
   P_WH_UPDATE_DATE  	IN   	JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE,
   P_START_DATE_ACTIVE	IN   	JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE  	IN   	JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS	OUT NOCOPY 	VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY     NUMBER,
   X_MSG_DATA           OUT NOCOPY    VARCHAR2
  );


  /* Vertical Industry Procedure for post processing in case of create srp territories */

  PROCEDURE  create_rs_srp_territories_post (
   P_SALESREP_ID           IN      JTF_RS_SRP_TERRITORIES.SALESREP_ID%TYPE,
   P_TERRITORY_ID          IN      JTF_RS_SRP_TERRITORIES.TERRITORY_ID%TYPE,
   P_STATUS                IN      JTF_RS_SRP_TERRITORIES.STATUS%TYPE,
   P_WH_UPDATE_DATE        IN      JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE,
   P_START_DATE_ACTIVE     IN      JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE       IN      JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE,
   P_SALESREP_TERRITORY_ID IN      JTF_RS_SRP_TERRITORIES.SALESREP_TERRITORY_ID%TYPE,
   X_RETURN_STATUS         OUT NOCOPY     VARCHAR2,
   X_MSG_COUNT      	   OUT NOCOPY     NUMBER,
   X_MSG_DATA         	   OUT NOCOPY     VARCHAR2
  );

  /* Vertical Industry Procedure for pre processing in case of update srp territories */

  PROCEDURE  update_rs_srp_territories_pre (
   P_SALESREP_TERRITORY_ID      IN      JTF_RS_SRP_TERRITORIES.SALESREP_TERRITORY_ID%TYPE,
   P_STATUS             	IN      JTF_RS_SRP_TERRITORIES.STATUS%TYPE,
   P_WH_UPDATE_DATE     	IN      JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE,
   P_START_DATE_ACTIVE  	IN      JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE    	IN      JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS      	OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT          	OUT NOCOPY    NUMBER,
   X_MSG_DATA           	OUT NOCOPY    VARCHAR2
  );

  /* Vertical Industry Procedure for post processing in case of update srp territories */

  PROCEDURE  update_rs_srp_territories_post (
   P_SALESREP_TERRITORY_ID      IN      JTF_RS_SRP_TERRITORIES.SALESREP_TERRITORY_ID%TYPE,
   P_STATUS                     IN      JTF_RS_SRP_TERRITORIES.STATUS%TYPE,
   P_WH_UPDATE_DATE             IN      JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE,
   P_START_DATE_ACTIVE          IN      JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE            IN      JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS              OUT NOCOPY     VARCHAR2,
   X_MSG_COUNT                  OUT NOCOPY     NUMBER,
   X_MSG_DATA                   OUT NOCOPY     VARCHAR2
  );


END jtf_rs_srp_territories_vuhk;

 

/
