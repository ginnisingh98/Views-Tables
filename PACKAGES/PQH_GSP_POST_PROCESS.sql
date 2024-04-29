--------------------------------------------------------
--  DDL for Package PQH_GSP_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_POST_PROCESS" AUTHID CURRENT_USER as
/* $Header: pqhgsppp.pkh 120.0.12010000.1 2008/07/28 12:59:25 appldev ship $ */

Function DT_Mode
(P_EFFECTIVE_DATE        IN       DATE
,P_BASE_TABLE_NAME       IN       VARCHAR2
,P_BASE_KEY_COLUMN       IN       VARCHAR2
,P_BASE_KEY_VALUE        IN       NUMBER) Return Varchar2;

Procedure Call_PP_From_Assignments
(P_Effective_Date	IN  Date,
 P_Assignment_Id	IN  Number,
 P_Date_track_Mode	IN  Varchar2,
 P_Warning_Mesg         OUT NOCOPY Varchar2);

Procedure Call_PP_From_Benmngle
(P_Effective_Date		IN  Date,
 P_Elig_per_Elctbl_Chc_Id       IN  Number);


Procedure Call_PP_From_AUI
(P_Errbuf                       OUT NOCOPY Varchar2,
 P_Retcode                      OUT NOCOPY Number,
 P_Effective_Date		IN  Varchar2,
 P_Approval_Status_Cd           IN  Varchar2 Default NULL,
 P_Elig_per_Elctbl_Chc_Id       IN  Number   Default NULL);

Procedure Call_PP_For_Batch_Enrl
(P_Errbuf                       OUT NOCOPY Varchar2
,P_Retcode                      OUT NOCOPY Number
,P_Effective_Date		        IN  Varchar2
,P_Grade_Ladder_Id              IN  Number Default NULL
,P_Person_Id                    IN  Number Default NULL
,p_grade_id                     IN Number Default Null
,p_person_selection_rule_id     IN Number Default Null);

/* Create Enrollment procedure creates an Enrollment for the Electable Choice record and
   also Updates the Life Event as processed */

Procedure Override_Eligibility
(P_Effective_Date          IN Date
,P_Assignment_id           IN Number
,P_Called_From             In Varchar2
,P_Date_Track_Mode         IN Varchar2 Default 'UPDATE'
,P_Elig_Per_Elctbl_Chc_Id  OUT NOCOPY Number);

Procedure Create_Enrollment
(P_Elig_Per_Elctbl_Chc_Id	IN     Number
,P_Person_id			IN     Number
,P_Progression_Style		IN     Varchar2
,P_Effective_Date		IN     Date
,P_PRTT_ENRT_RSLT_ID		IN OUT NOCOPY Number
,P_Status                       OUT    NOCOPY Varchar2);

/* Update Salary procedure creates Pay Proposal for the Salary Basis
   attached to the assignment. It Also Links the Pay proposal to Rates */

Procedure Update_Salary_Info
(P_Elig_per_Elctbl_Chc_Id	IN 	Number
,P_Effective_Date	        IN	Date
,P_Dt_Mode                      IN      Varchar2  Default NULL
,P_Called_From                  IN      Varchar2  Default 'PP'
,P_Prv_Sal_Chg_Dt               IN      Date      Default NULL);

/* Updates the Assignment with the New Grade - Step */

Procedure Update_Assgmt_Info
(P_Elig_Per_Elctbl_Chc_Id   IN 	Number,
 P_Effective_Date	    IN 	Date);

Procedure Approve_Reject_AUI
(P_Elig_Per_Elctbl_Chc_id   IN   Number
,P_Prog_Dt                  IN   Date      Default NULL
,P_Sal_Chg_Dt               IN   Date      Default NULL
,P_Comments                 IN   Varchar2  Default NULL
,P_Approve_Rej              IN   Varchar2);

Procedure get_persons_gl_and_grade(p_person_id            in number,
                                   p_business_group_id    in number,
                                   p_effective_date       in date,
                                   p_persons_pgm_id      out nocopy number,
                                   p_persons_plip_id     out nocopy number,
                                   p_prog_style          out nocopy varchar2);

Procedure Call_Concurrent_Req_Aui
(P_Approval_Status_Cd  IN   Varchar2
,P_Req_Id              OUT  NOCOPY Varchar2);
Procedure Update_Rate_Sync_Salary
(P_per_in_ler_Id	IN 	Number
,P_Effective_Date	        IN	Date
);

Procedure gsp_rate_sync
(P_Effective_Date          IN Date
,p_per_in_ler_id           IN NUMBER
,p_person_id                 IN NUMBER
,p_assignment_id            IN NUMBER
);
--
Procedure call_from_webadi
(P_Elig_Per_Elctbl_Chc_id   IN   Number
,P_PROGRESSION_DATE         IN   Date
,P_Sal_Chg_Dt               IN   Date
,p_assignment_id            IN NUMBER
,p_proposed_rank            in number
,p_life_event_dt            in date
,p_grade_ladder_id          in number
,p_pl_id                    in number
,p_oipl_id                   in number
);
--
END pqh_gsp_Post_Process;

/
