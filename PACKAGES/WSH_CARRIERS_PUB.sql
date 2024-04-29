--------------------------------------------------------
--  DDL for Package WSH_CARRIERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CARRIERS_PUB" AUTHID CURRENT_USER as
/* $Header: WSHCAPBS.pls 120.0.12010000.1 2010/04/22 11:29:26 selsubra noship $ */

--===================
-- PUBLIC VARS
--===================
  TYPE Carrier_Service_DFF_Rec_Type IS RECORD (
   CARRIER_SERVICE_ID              NUMBER,
   ATTRIBUTE_CATEGORY              VARCHAR2(150) DEFAULT NULL ,
   ATTRIBUTE1                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE2                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE3                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE4                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE5                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE6                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE7                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE8                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE9                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE10                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE11                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE12                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE13                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE14                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE15                     VARCHAR2(150) DEFAULT NULL);

TYPE Carrier_Ser_DFF_Tab_Type IS Table of Carrier_Service_DFF_Rec_Type  INDEX BY BINARY_INTEGER;

TYPE Org_Info_Rec_Type IS RECORD (
                                  org_id    NUMBER,
                                  org_code  MTL_PARAMETERS.Organization_Code%TYPE
                                 );

TYPE Org_Info_Tab_Type IS TABLE OF Org_Info_Rec_Type INDEX BY BINARY_INTEGER;

--===================
-- CONSTANTS
--===================

--===================
-- PROCEDURES
--===================

   --========================================================================
   -- PROCEDURE : Assign_Org_Carrier_Service         PUBLIC
   --
   -- PARAMETERS: p_api_version_number    known api version error number
   --             p_init_msg_list         FND_API.G_TRUE to reset list
   --             p_commit                FND_API.G_TRUE  to commit.
   --             p_action_code            Valid action codes are
   --                                     'ASSIGN','UNASSIGN'
   --             p_org_info_tab          Input table variable containing org_id and org_code for which needs to be assigned/unassigned
   --             p_carrier_id            Carrier Id of the carrier
   --             p_freight_code          Freight code
   --             p_carrier_service_id    Carrier service Id to be assigned/unassigned to Organization
   --             p_ship_method_code      Ship Method code
   --             p_ship_method           Ship Method meaning
   --             x_car_out_rec_tab       Out table variable containing carrier_service_id and org_carrier_service_id updated/inserted
   --             x_return_status         return status
   --             x_msg_count             number of messages in the list
   --             x_msg_data              text of messages
   --
   -- VERSION   : current version         1.0
   --             initial version         1.0
   -- COMMENT   : This procedure is used to perform an action specified in p_action_code on the carrier service
   --
   --             If p_action_code is 'ASSIGN' then new record will be inserted in WCSM ,WOCS and org_fieight_tl,
   --                                  if records are already existing then existing records will be updated
   --             If p_action_code is 'UNASSIGN' then existing record in WCSM and WOCS will be disabled .
   --                                  if records are not existing then records will be inserted in disabled status
   --                                  in WCSM ,WOCS and org_fieight_tl
   --
   --             If org_id and org_code are both passed in p_org_info_tab then only org_id is considered than org_code.
   --
   --             If p_carrier_service_id is passed then p_carrier_id , p_freight_code , p_ship_method_code and p_ship_method parameters are ignored
   --
   --             If p_ship_method_code or p_ship_method is passed then on associated carrier service action will be performed.
   --             If p_ship_method_code and p_ship_method both are passed then only p_ship_method_code is used.
   --             If p_ship_method_code or p_ship_method is passed then p_carrier_id/p_freight_code are ignored

   --             If p_carrier_id or p_freight_code is passed then action will be performed on all associated carrier services.
   --             If p_carrier_id and p_freight_code  both are passed then only p_carrier_id is considered.
  --
   --DESCRIPTION: Organization Assignment/Unassignment for a carrier / carrier service / ship method is possible from Application .
   --             This Public API is created to fulfill the same requirement.
   --========================================================================


    PROCEDURE Assign_Org_Carrier_Service
        ( p_api_version_number     IN   NUMBER,
          p_init_msg_list          IN   VARCHAR2,
          p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_action_code            IN   VARCHAR2,
          p_org_info_tab           IN   WSH_CARRIERS_PUB.Org_Info_Tab_Type,
          p_carrier_id             IN   NUMBER DEFAULT NULL,
          p_freight_code           IN   VARCHAR2 DEFAULT NULL,
          p_carrier_service_id     IN   NUMBER DEFAULT NULL,
          p_ship_method_code       IN   VARCHAR2 DEFAULT NULL,
          p_ship_method            IN   VARCHAR2 DEFAULT NULL,
          x_car_out_rec_tab        OUT NOCOPY wsh_carriers_grp.Org_Carrier_Ser_Out_Tab_Type,
          x_return_status          OUT NOCOPY VARCHAR2,
          x_msg_count              OUT NOCOPY NUMBER,
          x_msg_data               OUT NOCOPY VARCHAR2);



END WSH_CARRIERS_PUB;

/
