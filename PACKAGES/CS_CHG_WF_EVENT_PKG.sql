--------------------------------------------------------
--  DDL for Package CS_CHG_WF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHG_WF_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: cswfchgs.pls 115.0 2003/08/25 22:17:05 cnemalik noship $ */


  PROCEDURE Raise_SubmitCharges_Event(
        p_api_version            IN    NUMBER,
        p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
        p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
        p_Event_Code             IN    VARCHAR2,
        p_estimate_detail_id     IN    VARCHAR2,
        p_USER_ID                IN    NUMBER  DEFAULT FND_GLOBAL.USER_ID,
        p_RESP_ID                IN    NUMBER,
        p_RESP_APPL_ID           IN    NUMBER,
        p_est_detail_rec         IN    CS_Charge_Details_PUB.Charges_Rec_Type,
        p_wf_process_id          IN    NUMBER,
        p_owner_id               IN    NUMBER,
        p_wf_manual_launch       IN    VARCHAR2 ,
        x_wf_process_id          OUT   NOCOPY NUMBER,
        x_return_status          OUT NOCOPY VARCHAR2,
        x_msg_count              OUT NOCOPY NUMBER,
        x_msg_data               OUT NOCOPY VARCHAR2);

END CS_CHG_WF_EVENT_PKG;

 

/
