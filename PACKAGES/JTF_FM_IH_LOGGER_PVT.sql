--------------------------------------------------------
--  DDL for Package JTF_FM_IH_LOGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_IH_LOGGER_PVT" AUTHID CURRENT_USER AS
/* $Header: jtffmihs.pls 120.2 2006/04/26 11:36 ahattark noship $*/

PROCEDURE Log_Interaction_History(
            P_COMMIT IN VARCHAR2   := FND_API.G_FALSE,
            p_server_id IN NUMBER,
            x_request_id out nocopy NUMBER,
            x_return_status out nocopy varchar2,
            x_msg_count out nocopy number,
            x_msg_data out nocopy varchar2 );

PROCEDURE Remove_from_status(
             P_Request_ID IN NUMBER);

PROCEDURE Update_history(
             P_Request_ID IN NUMBER,
             P_Status IN VARCHAR);

END JTF_FM_IH_LOGGER_PVT;

 

/
