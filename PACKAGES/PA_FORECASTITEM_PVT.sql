--------------------------------------------------------
--  DDL for Package PA_FORECASTITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECASTITEM_PVT" AUTHID CURRENT_USER as
--/* $Header: PARFIGPS.pls 120.1 2005/08/29 20:50:39 sunkalya noship $ */


     PROCEDURE print_message(p_msg IN varchar2);

     PROCEDURE Create_ForeCast_Item(
                   p_assignment_id       IN   NUMBER,
                   p_start_date          IN   DATE DEFAULT NULL,
                   p_end_date            IN   DATE DEFAULT NULL,
                   p_process_mode        IN   VARCHAR2,
                   p_gen_res_fi_flag     IN   VARCHAR2 := 'Y',
                   x_return_status       OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                   x_msg_count           OUT  NOCOPY NUMBER,						--Bug: 4537865
                   x_msg_data            OUT  NOCOPY VARCHAR2);						--Bug: 4537865

      PROCEDURE Create_Forecast_Item(
                   p_resource_id         IN   NUMBER,
                   p_start_date          IN   DATE DEFAULT NULL,
                   p_end_date            IN   DATE DEFAULT NULL,
                   p_process_mode        IN   VARCHAR2,
                   x_return_status       OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                   x_msg_count           OUT  NOCOPY  NUMBER,						--Bug: 4537865
                   x_msg_data            OUT  NOCOPY VARCHAR2);						--Bug: 4537865

      PROCEDURE Create_Forecast_Item (
                p_person_id      IN      NUMBER,
                p_start_date     IN     DATE  DEFAULT NULL,
                p_end_date       IN     DATE  DEFAULT NULL,
                p_process_mode   IN     VARCHAR2,
                x_return_status  OUT    NOCOPY  VARCHAR2,						--Bug: 4537865
                x_msg_count      OUT    NOCOPY   NUMBER,						--Bug: 4537865
                x_msg_data       OUT    NOCOPY  VARCHAR2); 						--Bug: 4537865

      PROCEDURE Create_ForeCast_Item(
                   p_ErrHdrTab           IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                   p_process_mode        IN   VARCHAR2,
                   x_return_status       OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                   x_msg_count           OUT  NOCOPY NUMBER,						--Bug: 4537865
                   x_msg_data            OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE Delete_Forecast_Item (
                   p_assignment_id  IN   NUMBER,
                   p_resource_id    IN   NUMBER,
                   p_start_date     IN   DATE,
                   p_end_date       IN   DATE,
                   x_return_status  OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                   x_msg_count      OUT  NOCOPY NUMBER,							--Bug: 4537865
                   x_msg_data       OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE Get_Assignment_Dtls(
                  p_assignment_id        IN   NUMBER,
                  x_AsgnDtlRec           OUT NOCOPY  PA_FORECAST_GLOB.AsgnDtlRecord, /* 2674619 - Nocopy change */
                  x_return_status        OUT NOCOPY  VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT NOCOPY  NUMBER,						--Bug: 4537865
                  x_msg_data             OUT NOCOPY  VARCHAR2);						--Bug: 4537865

       PROCEDURE Get_Project_Dtls(
                  p_project_id           IN   NUMBER,
                  x_project_org_id       OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_project_orgn_id      OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_work_type_id         OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_project_type_class   OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_project_status_code  OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Generate_Requirement_FI(
                  p_asgndtlrec           IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_process_mode         IN   VARCHAR2,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  p_ErrHdrTab            IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE Initialize_Day_FI(
                  p_ScheduleTab          IN   PA_FORECAST_GLOB.SCHEDULETABTYP,
                  p_process_mode         IN   VARCHAR2,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  x_FIDayTab             OUT  NOCOPY PA_FORECAST_GLOB.FIDaytabtyp, /* 2674619 - Nocopy change */
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE Build_Day_FI(
                  p_ScheduleTab          IN   PA_FORECAST_GLOB.SCHEDULETABTYP,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  p_FIDayTab          IN OUT  NOCOPY PA_FORECAST_GLOB.FIDaytabtyp, /* 2674619 - Nocopy change */
                  p_AsgType              IN   VARCHAR2,
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Reverse_FI_Hdr(
                  p_assignment_id        IN   NUMBER,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  x_old_start_date    IN OUT  NOCOPY DATE,						--Bug: 4537865
                  x_old_end_date      IN OUT  NOCOPY DATE,						--Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Reverse_FI_Dtl(
                  p_assignment_id        IN   NUMBER,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Fetch_FI_Hdr(
                  p_assignment_id        IN   NUMBER,
                  p_resource_id          IN   NUMBER,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  x_dbFIHdrTab           OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Fetch_FI_Dtl(
                  p_assignment_id        IN   NUMBER,
                  p_resource_id          IN   NUMBER,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  x_dbFIDtlTab           OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,   /* 2674619 - Nocopy change */
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Build_FI_Hdr_Req(
                  p_asgndtlrec           IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_DBHdrTab             IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                  p_FIDayTab          IN OUT  NOCOPY PA_FORECAST_GLOB.FIDayTabTyp,   /* 2674619 - Nocopy change */
                  x_FIHdrInsTab          OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp,   /* 2674619 - Nocopy change */
                  x_FIHdrUpdTab          OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp,   /* 2674619 - Nocopy change */
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE Build_FI_Dtl_Req(
                  p_asgndtlrec           IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_DBDtlTab             IN   PA_FORECAST_GLOB.FIDtlTabTyp,
                  p_FIDayTab             IN   PA_FORECAST_GLOB.FIDayTabTyp,
                  x_FIDtlInsTab          OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,   /* 2674619 - Nocopy change */
                  x_FIDtlUpdTab          OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,   /* 2674619 - Nocopy change */
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Generate_Assignment_FI(
                  p_asgndtlrec           IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_process_mode         IN   VARCHAR2,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  p_ErrHdrTab            IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                  x_res_start_date       OUT  NOCOPY DATE,						--Bug: 4537865
                  x_res_end_date         OUT  NOCOPY DATE,						--Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,						--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,						--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);						--Bug: 4537865

       PROCEDURE  Delete_FI(
                  p_assignment_id        IN   NUMBER,
                  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865
       PROCEDURE  Delete_FI_hdr(
                  p_assignment_id        IN   NUMBER,
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
 		  --Bug: 4537865

       PROCEDURE  Delete_FI_dtl(
                  p_assignment_id        IN   NUMBER,
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE  Delete_FI(
                  p_resource_id        IN   NUMBER,
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE  Delete_FI_hdr(
                  p_resource_id        IN   NUMBER,
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE  Delete_FI_dtl(
                  p_resource_id        IN   NUMBER,
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE  Build_FI_Hdr_Asg(
                  p_asgndtlrec           IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_DBHdrTab             IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                  p_FIDayTab          IN OUT  NOCOPY PA_FORECAST_GLOB.FIDayTabTyp,   /* 2674619 - Nocopy change */
                  x_FIHdrInsTab          OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp,   /* 2674619 - Nocopy change */
                  x_FIHdrUpdTab          OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp,   /* 2674619 - Nocopy change */
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE Build_FI_Dtl_Asg(
                  p_asgndtlrec           IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_DBDtlTab             IN   PA_FORECAST_GLOB.FIDtlTabTyp,
                  p_FIDayTab             IN   PA_FORECAST_GLOB.FIDayTabTyp,
                  x_FIDtlInsTab          OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,   /* 2674619 - Nocopy change */
                  x_FIDtlUpdTab          OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,   /* 2674619 - Nocopy change */
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865


       PROCEDURE Regenerate_Res_Unassigned_FI(
                  p_resource_id          IN   NUMBER,
                  p_start_date        IN OUT  NOCOPY DATE,					--Bug: 4537865
                  p_end_date          IN OUT  NOCOPY DATE,					--Bug: 4537865
                  p_process_mode         IN   VARCHAR2,
                  p_ErrHdrTab            IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                  p_date_validation      IN   VARCHAR2 := 'Y',
                  x_return_status        OUT  NOCOPY VARCHAR2,					--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,					--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);					--Bug: 4537865

       PROCEDURE  Fetch_FI_Hdr_Res(
                  p_resource_id          IN   NUMBER,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  x_dbFIHdrTab           OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE  Fetch_FI_Dtl_Res(
                  p_resource_id          IN   NUMBER,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  x_dbFIDtlTab           OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,  /* 2674619 - Nocopy change */
                  x_return_status        OUT  NOCOPY VARCHAR2,					--Bug: 4537865
                  x_msg_count            OUT  NOCOPY NUMBER,					--Bug: 4537865
                  x_msg_data             OUT  NOCOPY VARCHAR2);					--Bug: 4537865

       PROCEDURE  Build_FI_Hdr_Res(
                  p_resource_id          IN   NUMBER,
                  p_start_date           IN   DATE,
                  p_end_date             IN   DATE,
                  p_FIDayTab         IN OUT   NOCOPY PA_FORECAST_GLOB.FIDayTabTyp,  /* 2674619 - Nocopy change */
                  p_DBHdrTab             IN   PA_FORECAST_GLOB.FIHDRTabTyp,
                  x_FIHdrInsTab          OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp,  /* 2674619 - Nocopy change */
                  x_FIHdrUpdTab          OUT  NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp,  /* 2674619 - Nocopy change */
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE Build_FI_Dtl_Res(
                  p_resource_id          IN   NUMBER,
                  p_DBDtlTab             IN   PA_FORECAST_GLOB.FIDtlTabTyp,
                  p_FIDayTab             IN   PA_FORECAST_GLOB.FIDayTabTyp,
                  x_FIDtlInsTab          OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,  /* 2674619 - Nocopy change */
                  x_FIDtlUpdTab          OUT  NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp,  /* 2674619 - Nocopy change */
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE Resource_UnAsg_Error_Process(
                  p_ErrHdrTab            IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                  p_process_mode         IN   VARCHAR2,
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE FI_Error_Process(
                  p_AsgnDtlRec           IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_Process_Mode         IN   VARCHAR2,
                  p_Start_date           IN   DATE,
                  p_End_date             IN   DATE,
		  --Bug: 4537865
                  x_return_status        OUT  NOCOPY VARCHAR2,
                  x_msg_count            OUT  NOCOPY NUMBER,
                  x_msg_data             OUT  NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE regenrate_orgz_forecast(
                  p_orgz_id           IN      NUMBER,
                  p_start_date        IN      DATE,
                  p_end_date          IN      DATE,
                  p_process_mode      IN      VARCHAR2,
		  --Bug: 4537865
                  x_return_status     OUT     NOCOPY VARCHAR2,
                  x_msg_count         OUT     NOCOPY NUMBER,
                  x_msg_data          OUT     NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE Regenrate_Unassigned(
                  p_orgz_id           IN      NUMBER,
                  p_start_date        IN      DATE,
                  p_end_date          IN      DATE,
                  p_process_mode      IN      VARCHAR2,
		  --Bug: 4537865
                  x_return_status     OUT     NOCOPY VARCHAR2,
                  x_msg_count         OUT     NOCOPY NUMBER,
                  x_msg_data          OUT     NOCOPY VARCHAR2);
		  --Bug: 4537865

       PROCEDURE Regenrate_Asgn_Req(
                  p_orgz_id           IN      NUMBER,
                  p_start_date        IN      DATE,
                  p_end_date          IN      DATE,
                  p_process_mode      IN      VARCHAR2,
		  --Bug: 4537865
                  x_return_status     OUT     NOCOPY VARCHAR2,
                  x_msg_count         OUT     NOCOPY NUMBER,
                  x_msg_data          OUT     NOCOPY VARCHAR2);
		  --Bug: 4537865


       FUNCTION  Chk_Requirement_FI_Exist(
                  p_assignment_id        IN   NUMBER) RETURN VARCHAR2;

       Function  Chk_Assignment_FI_Exist(
                  p_assignment_id        IN   NUMBER) RETURN VARCHAR2;

       FUNCTION Is_include_Forecast     (
                  p_project_status_code   IN  VARCHAR2,
                  p_action_code           IN  VARCHAR2) RETURN VARCHAR2;

       FUNCTION Get_AmountTypeID RETURN NUMBER ;

--Bug No:1967832
     Procedure Is_Include_Utilisation (p_person_id     IN  NUMBER,
                                       p_item_date     IN  DATE,
				       --Bug: 4537865
                                       x_Start_Date    OUT NOCOPY DATE,
                                       x_End_Date      OUT NOCOPY DATE,
                                       x_inc_util_flag OUT NOCOPY VARCHAR2,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_msg_count     OUT NOCOPY NUMBER,
                                       x_msg_data      OUT NOCOPY VARCHAR2);
				       --Bug: 4537865


      Procedure Check_Person_Billable(p_person_id     IN  NUMBER,
                                       p_item_date     IN  DATE,
				       --Bug: 4537865
                                       x_Start_Date    OUT NOCOPY DATE,
                                       x_End_Date      OUT NOCOPY Date,
                                       x_billable_flag OUT NOCOPY VARCHAR2,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_msg_count     OUT NOCOPY NUMBER,
                                       x_msg_data      OUT NOCOPY VARCHAR2);
				       --Bug: 4537865


   PROCEDURE copy_requirement_fi (
                 p_requirement_id_tbl      IN   PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
                 p_requirement_source_id   IN   NUMBER,
		 --Bug: 4537865
                 x_return_status          OUT  NOCOPY VARCHAR2,
                 x_msg_count              OUT  NOCOPY NUMBER,
                 x_msg_data               OUT  NOCOPY VARCHAR2);
		 --Bug: 4537865

END PA_FORECASTITEM_PVT;
 

/
