--------------------------------------------------------
--  DDL for Package CS_CHG_AUTO_SUB_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHG_AUTO_SUB_CON_PKG" AUTHID CURRENT_USER as
/* $Header: csxvasus.pls 120.0.12010000.1 2008/07/24 18:46:33 appldev ship $ */
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name:  Auto_Submit_Chg_Lines
--   Type    :  Private
--   Purpose :  This procedure is for identifying lines for Autosubmission.
--              It is intended for use by the owning module only.
--   Pre-Req :
--   Parameters:
--       p_api_version           IN      NUMBER     Required
--       p_init_msg_list         IN      VARCHAR2   Optional
--       p_commit                IN      VARCHAR2   Optional
--       p_validation_level      IN      NUMBER     Optional
--       x_return_status         OUT    VARCHAR2
--       x_msg_count             OUT    NUMBER
--       x_msg_data              OUT    VARCHAR2
--
    PROCEDURE Auto_Submit_Chg_Lines (
       p_api_version     IN   NUMBER,
       p_init_msg_list   IN   VARCHAR2,
       p_commit          IN   VARCHAR2,
       x_return_status   OUT  NOCOPY VARCHAR2,
       x_msg_count       OUT  NOCOPY NUMBER,
       x_msg_data        OUT  NOCOPY VARCHAR2);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name: MAIN_PROCEDURE
--   Type    :  Private
--   Purpose :  This is the main procedure to the concurrent program.
--   Parameters:
--   ERRBUF         	 OUT    VARCHAR2
--   RETCODE             OUT    NUMBER
--
	PROCEDURE Main_Procedure(ERRBUF       OUT    NOCOPY VARCHAR2,
       		                 RETCODE      OUT    NOCOPY NUMBER);
--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name:  Update_Charge_Lines
--   Type    :  Private
--   Purpose :  This procedure is for updating charge lines with appropriate
--              restriction message.
--   Pre-Req :
--   Parameters:
--   IN
--       p_incident_id           IN      NUMBER
--       p_estimate_detail_id    IN      NUMBER
--       p_currency_code         IN      VARCHAR2
--       p_submit_restriction_message   IN      VARCHAR2
--       p_line_submitted               IN      VARCHAR2
--       p_restriction_type             IN      VARCHAR2
--       x_return_status                OUT     VARCHAR2
--	 x_msg_data			OUT	VARCHAR2


   PROCEDURE  Update_Charge_Lines(p_incident_id      NUMBER,
                                  p_incident_number  VARCHAR2,
                                  p_estimate_detail_id NUMBER,
                                  p_currency_code      VARCHAR2,
                                  p_submit_restriction_message VARCHAR2,
                                  p_line_submitted   VARCHAR2,
                                  p_restriction_type VARCHAR2,
                                  x_return_status  OUT NOCOPY VARCHAR2,
				  x_msg_data       OUT NOCOPY VARCHAR2);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name:  Submit_Charge_Lines
--   Type    :  Private
--   Purpose :  This procedure is a wrapper on top of submit order API.
--   Pre-Req :
--   Parameters:
--       p_incident_id           IN      NUMBER     Required
--       p_submit_source         IN      VARCHAR2   Optional
--       p_submit_from_system    IN      VARCHAR2   Optional
--   OUT:
--       x_return_status         OUT    NOCOPY     VARCHAR2
--       x_msg_count             OUT    NOCOPY     NUMBER
--       x_msg_data              OUT    NOCOPY     VARCHAR2


PROCEDURE  Submit_Charge_Lines(p_incident_id      IN  NUMBER,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2);




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name: Check_Debrief_Status
--   Type    :  Private
--   Purpose :  This procedure is to validate debreif status before submitting to OM.
--   Pre-Req :
--   Parameters:
--   IN
--       p_incident_id           IN      NUMBER
--       p_estimate_detail_id    IN      NUMBER
--       p_currency_code         IN      VARCHAR2
--       p_incident_number       IN      VARCHAR2
--         x_restriction_qualify_flag OUT NOCOPY VARCHAR2
--       x_return_status                OUT     VARCHAR2
--       x_msg_data                     OUT     VARCHAR2


PROCEDURE  Check_Debrief_Status(p_incident_id          NUMBER,
                                p_incident_number      VARCHAR2,
                                p_estimate_detail_id   NUMBER,
                                p_currency_code        VARCHAR2,
                                x_restriction_qualify_flag OUT NOCOPY VARCHAR2,
                                x_return_status    OUT NOCOPY VARCHAR2,
                                x_msg_data         OUT NOCOPY VARCHAR2);

End CS_Chg_Auto_Sub_CON_PKG;

/
