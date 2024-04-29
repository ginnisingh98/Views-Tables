--------------------------------------------------------
--  DDL for Package WSH_FOLDER_EXTENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FOLDER_EXTENSIONS_PVT" AUTHID CURRENT_USER as
/* $Header: WSHFDEXS.pls 115.1 2003/08/13 07:25:34 anxsharm noship $ */

TYPE folder_ext_rec_type IS RECORD(
     FOLDER_EXTENSION_ID NUMBER,
     OBJECT              VARCHAR2(30),
     USER_ID             NUMBER,
     FOLDER_ID           NUMBER,
     APPLICATION_ID      NUMBER,
     DISPLAY_DLVY_MAIN   VARCHAR2(1),
     DISPLAY_DLVY_OTHERS VARCHAR2(1),
     DISPLAY_LINE_MAIN   VARCHAR2(1),
     DISPLAY_LINE_OTHERS VARCHAR2(1),
     DISPLAY_TRIP_MAIN   VARCHAR2(1),
     DISPLAY_TRIP_OTHERS VARCHAR2(1),
     DISPLAY_STOP_MAIN   VARCHAR2(1),
     DISPLAY_STOP_OTHERS VARCHAR2(1),
     DISPLAY_QM_LINE_MAIN VARCHAR2(1),
     DISPLAY_QM_LINE_OTHERS VARCHAR2(1),
     DISPLAY_SHIP_CONF_DIALOGUE VARCHAR2(1),
     DISPLAY_TRIP_CONF_DIALOGUE VARCHAR2(1),
     DISPLAY_TRIP_INFO   VARCHAR2(1),
     CREATION_DATE       DATE,
     CREATED_BY          NUMBER,
     LAST_UPDATE_DATE    DATE,
     LAST_UPDATED_BY     NUMBER,
     LAST_UPDATE_LOGIN   NUMBER
);


TYPE folder_cust_rec_type IS RECORD(
     ACTION_ID           NUMBER,
     ACTION_NAME         VARCHAR2(30),
     OBJECT              VARCHAR2(30),
     USER_ENTERED_PROMPT VARCHAR2(30),
     USER_ID             NUMBER,
     FOLDER_ID           NUMBER,
     WIDTH               NUMBER,
     ACCESS_KEY          VARCHAR2(1),
     DISPLAY_AS_BUTTON_FLAG VARCHAR2(1),
     DEFAULT_PROMPT      VARCHAR2(80),
     CREATION_DATE       DATE,
     CREATED_BY          NUMBER,
     LAST_UPDATE_DATE    DATE,
     LAST_UPDATED_BY     NUMBER,
     LAST_UPDATE_LOGIN   NUMBER
);

TYPE folder_cust_tab_type IS TABLE OF folder_cust_rec_type INDEX BY BINARY_INTEGER;

Procedure Insert_Update_Folder_Ext(
          p_folder_ext_rec IN folder_ext_rec_type,
          x_return_status  OUT NOCOPY VARCHAR2);

Procedure Delete_Folder_Ext(
          p_folder_id           IN NUMBER,
          x_return_status       OUT NOCOPY VARCHAR2);


Procedure Insert_Update_Folder_Custom(
          p_folder_cust_tab IN folder_cust_tab_type,
          x_return_status  OUT NOCOPY VARCHAR2);

Procedure Delete_Folder_Custom(
          p_folder_id           IN NUMBER,
          x_return_status       OUT NOCOPY VARCHAR2);

END WSH_FOLDER_EXTENSIONS_PVT;

 

/
