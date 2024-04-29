--------------------------------------------------------
--  DDL for Package CS_GET_REACTION_TIMES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_GET_REACTION_TIMES_PUB" AUTHID CURRENT_USER AS
/* $Header: csctrtms.pls 115.0 99/07/16 08:54:11 porting ship  $ */

/*******************************************************************************
  --  GLOBAL VARIABLES
*******************************************************************************/

  G_PKG_NAME       CONSTANT   VARCHAR2(200)   := 'CS_GET_REACTION_TIMES_PUB';
  G_APP_NAME       CONSTANT   VARCHAR2(3)     := 'CS';

/*******************************************************************************
  --  Procedures and Functions
*******************************************************************************/

  PROCEDURE Convert_To_Mts (
			 p_hours            IN  NUMBER,
			 p_minutes          IN  NUMBER,
			 x_all_minutes      OUT NUMBER  );

  PROCEDURE Convert_To_GMT(
			 p_time_zone_id     IN  NUMBER,
			 p_time_mts         IN  OUT NUMBER,
			 p_date			IN	OUT DATE,
			 x_return_status    OUT VARCHAR2,
                x_msg_count        OUT NUMBER,
                x_msg_data         OUT VARCHAR2);

  PROCEDURE Convert_FROM_GMT(
			 p_time_zone_id     IN  NUMBER,
			 p_time_mts         IN  OUT NUMBER,
			 p_date			IN	OUT DATE,
			 x_return_status    OUT VARCHAR2,
                x_msg_count        OUT NUMBER,
                x_msg_data         OUT VARCHAR2);

  PROCEDURE Convert_To_Hours_Mts (
			 p_end_time_all_mts    IN  NUMBER,
			 x_end_time_hours      OUT NUMBER,
			 x_end_time_mts        OUT NUMBER  );

  PROCEDURE Get_Next_Days_Coverage_Time(
			 p_coverage_txn_group_id   IN  NUMBER,
			 p_coverage_day		  IN	 OUT NUMBER,
                x_cov_start_time_hours    OUT NUMBER,
                x_cov_start_time_mts      OUT NUMBER,
                x_cov_end_time_hours      OUT NUMBER,
                x_cov_end_time_mts        OUT NUMBER,
		      x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2);

  PROCEDURE Get_Reaction_Times (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
                p_business_process_id     IN  NUMBER,
                p_start_date_time         IN  DATE,
                p_call_time_zone_id       IN  NUMBER,
			 p_incident_severity_id    IN  NUMBER,
                p_exception_coverage_flag IN  VARCHAR2,
		      p_Reaction_time_id        IN OUT NUMBER,
		      x_Reaction_time           OUT VARCHAR2,
                x_Reaction_time_Sunday    OUT NUMBER,
                x_Reaction_time_Monday    OUT NUMBER,
                x_Reaction_time_Tuesday   OUT NUMBER,
                x_Reaction_time_Wednesday OUT NUMBER,
                x_Reaction_time_Thursday  OUT NUMBER,
                x_Reaction_time_Friday    OUT NUMBER,
                x_Reaction_time_Saturday  OUT NUMBER,
                x_Workflow                OUT VARCHAR2,
                x_always_covered          OUT VARCHAR2,
			 x_incident_severity       OUT VARCHAR2,
                x_Expected_End_Date_Time  OUT DATE,
                x_Use_for_SR_Date_Calc    OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

END CS_GET_REACTION_TIMES_PUB;

 

/
