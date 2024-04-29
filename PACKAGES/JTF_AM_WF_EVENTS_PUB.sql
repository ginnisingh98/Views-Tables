--------------------------------------------------------
--  DDL for Package JTF_AM_WF_EVENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AM_WF_EVENTS_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfamwps.pls 120.2 2006/08/18 07:04:21 mpadhiar noship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  PROCEDURE assign_sr_resource
  (P_API_VERSION           IN   NUMBER,
   P_INIT_MSG_LIST         IN   VARCHAR2,
   P_COMMIT                IN   VARCHAR2,
   P_CONTRACT_ID           IN  	NUMBER   ,
   P_CUSTOMER_PRODUCT_ID   IN  	NUMBER   ,
   P_CATEGORY_ID           IN  	NUMBER   ,
   P_INVENTORY_ITEM_ID     IN  	NUMBER   ,
   P_INVENTORY_ORG_ID      IN  	NUMBER   ,
   P_PROBLEM_CODE          IN  	VARCHAR2 ,
   P_SR_REC                IN   JTF_ASSIGN_PUB.JTF_SERV_REQ_REC_TYPE,
   P_SR_TASK_REC           IN   JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE,
   P_BUSINESS_PROCESS_ID   IN  	NUMBER,
   P_BUSINESS_PROCESS_DATE IN  	DATE,
   X_RETURN_STATUS         OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             OUT  NOCOPY NUMBER,
   X_MSG_DATA              OUT  NOCOPY VARCHAR2,
   --Added for Bug # 5386560
   P_INVENTORY_COMPONENT_ID IN  NUMBER   DEFAULT NULL
   --Added for Bug # 5386560 Ends here
   ) ;


  /************** Added by SBARAT on 01/11/2004 for Enh-3919046 ****************/

  PROCEDURE assign_dr_resource
  (P_API_VERSION           IN   NUMBER,
   P_INIT_MSG_LIST         IN   VARCHAR2,
   P_COMMIT                IN   VARCHAR2,
   P_CONTRACT_ID           IN   NUMBER   ,
   P_CUSTOMER_PRODUCT_ID   IN   NUMBER   ,
   P_CATEGORY_ID           IN   NUMBER   ,
   P_INVENTORY_ITEM_ID     IN   NUMBER   ,
   P_INVENTORY_ORG_ID      IN   NUMBER   ,
   P_PROBLEM_CODE          IN   VARCHAR2 ,
   P_DR_REC                IN   JTF_ASSIGN_PUB.JTF_DR_REC_TYPE,
   P_BUSINESS_PROCESS_ID   IN   NUMBER,
   P_BUSINESS_PROCESS_DATE IN   DATE,
   X_RETURN_STATUS         OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             OUT  NOCOPY NUMBER,
   X_MSG_DATA              OUT  NOCOPY VARCHAR2
   ) ;

  /************** End of addition by SBARAT on 01/11/2004 for Enh-3919046 ****************/


  /************** Starting of Addition for Enh. No 3076744 by SBARAT, 13/09/2004 ****************/

  PROCEDURE assign_task_resource
  (P_API_VERSION			IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT               	IN   VARCHAR2,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   P_TASK_ID               	IN   JTF_TASKS_VL.TASK_ID%TYPE,
   P_CONTRACT_ID           	IN   NUMBER,
   P_CUSTOMER_PRODUCT_ID   	IN   NUMBER,
   P_CATEGORY_ID           	IN   NUMBER,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   );


  PROCEDURE assign_esc_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST        	IN   VARCHAR2,
   P_COMMIT               	IN   VARCHAR2,
   P_ESC_REC		   	IN   JTF_ASSIGN_PUB.Escalations_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   );


  PROCEDURE assign_def_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_CONTRACT_ID           	IN   NUMBER,
   P_CUSTOMER_PRODUCT_ID   	IN   NUMBER,
   P_CATEGORY_ID           	IN   NUMBER,
   P_DEF_MGMT_REC			IN   JTF_ASSIGN_PUB.JTF_DEF_MGMT_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   );


  PROCEDURE assign_acc_resource
  (P_API_VERSION			IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_ACCOUNT_REC			IN   JTF_ASSIGN_PUB.JTF_Account_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT            	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   );


  PROCEDURE assign_oppr_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_OPPR_REC         		IN   JTF_ASSIGN_PUB.JTF_Oppor_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   );


  PROCEDURE assign_lead_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_LEAD_REC                	IN   JTF_ASSIGN_PUB.JTF_Lead_rec_type,
   P_LEAD_BULK_REC           	IN   JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   );

  /************** End of Addition for Enh. No 3076744 by SBARAT, 13/09/2004 ****************/

END jtf_am_wf_events_pub;

 

/
