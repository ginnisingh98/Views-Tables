--------------------------------------------------------
--  DDL for Package WSH_WSHRDMBL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WSHRDMBL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHRDMBLS.pls 120.2 2007/12/25 07:24:40 nchinnam noship $ */
  P_TRIP_ID NUMBER;

  P_PRINT_BOLS VARCHAR2(32767);

  P_CONC_REQUEST_ID NUMBER := 0;

  FUNCTION CF_SHIPPER_NAMEFORMULA(STOP_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_ADDRESS_TRIPS_STOPSFORMULA(ADDRESS1 IN VARCHAR2
                                        ,ADDRESS2 IN VARCHAR2
                                        ,ADDRESS3 IN VARCHAR2
                                        ,ADDRESS4 IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_ADDRESS_DELIVERIES_PICKEDUP(ADDRESS1_DP IN VARCHAR2
                                         ,ADDRESS2_DP IN VARCHAR2
                                         ,ADDRESS3_DP IN VARCHAR2
                                         ,ADDRESS4_DP IN VARCHAR2) RETURN CHAR;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_NO_DATA_FOUNDFORMULA RETURN CHAR;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_ITEM_DESCRIPTION_IPFORMULA(ITEM_DESCRIPTION_IP IN VARCHAR2
                                        ,INVENTORY_ITEM_ID_IP IN NUMBER
                                        ,ORGANIZATION_ID_IP IN NUMBER) RETURN CHAR;

  FUNCTION CF_ITEM_DESCRIPTION_DFORMULA(ITEM_DESCRIPTION_D IN VARCHAR2
                                       ,INVENTORY_ITEM_ID_D IN NUMBER
                                       ,ORGANIZATION_ID_D IN NUMBER) RETURN CHAR;

  FUNCTION CF_MODE_MEANFORMULA(MODE_OF_TRANSPORT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_SERVICE_LEVELFORMULA(SERVICE_LEVEL IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_TRIP_STATUSFORMULA(TRIP_STATUS IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_STOP_STATUSFORMULA(STOP_STATUS IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_WEIGHT_UOMFORMULA(WEIGHT_UOM IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_VOLUME_UOMFORMULA(VOLUME_UOM IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_DELIVERY_STATUS_DPFORMULA(DELIVERY_STATUS_DP IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_WEIGHT_UOM_DPFORMULA(WEIGHT_UOM_DP IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_VOLUME_UOM_DPFORMULA(VOLUME_UOM_DP IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_VOLUME_UOM_DDFORMULA(VOLUME_UOM_DD IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_WEIGHT_UOM_DDFORMULA(WEIGHT_UOM_DD IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_DELIVERY_STATUS_DDFORMULA(DELIVERY_STATUS_DD IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_COMMODITY_CLASS_PICKEDFORMU(INVENTORY_ITEM_ID_IP IN NUMBER
                                         ,ORGANIZATION_ID_IP IN NUMBER) RETURN CHAR;

  FUNCTION CF_COMMODITY_CLASS_DROPPEDFORM(INVENTORY_ITEM_ID_D IN NUMBER
                                         ,ORGANIZATION_ID_D IN NUMBER) RETURN CHAR;

  FUNCTION CF_PARENT_DEL_NAME_DPFORMULA(DELIVERY_LEG_ID_DP IN NUMBER) RETURN CHAR;

  FUNCTION CF_PARENT_DEL_NAME_DDFORMULA(DELIVERY_LEG_ID_DD IN NUMBER) RETURN CHAR;

  FUNCTION CF_FREIGHT_TERMS_DPFORMULA(FREIGHT_TERMS_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_FREIGHT_TERMS_DDFORMULA(FREIGHT_TERMS_DD1 IN VARCHAR2) RETURN CHAR;

END WSH_WSHRDMBL_XMLP_PKG;


/
