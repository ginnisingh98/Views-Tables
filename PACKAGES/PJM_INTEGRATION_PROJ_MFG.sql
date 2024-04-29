--------------------------------------------------------
--  DDL for Package PJM_INTEGRATION_PROJ_MFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_INTEGRATION_PROJ_MFG" AUTHID CURRENT_USER as
/* $Header: PJMVLDTS.pls 115.6 2002/10/29 20:14:30 alaw ship $ */

FUNCTION  PJM_VALIDATE_DATE (P_SCHEDULE_DATE     IN  DATE
 		             ,P_TIME_POINT        IN  VARCHAR2
 			     ,P_PROJECT_ID        IN  NUMBER
 			     ,P_TASK_ID           IN  NUMBER
 			     ,P_TOLERANCE_DAYS    IN  NUMBER     DEFAULT 0
                             ,P_ERROR_MSG         OUT NOCOPY VARCHAR2
                             ) return number;

FUNCTION PJM_EXCEPTION_DAYS(pd_schedule_date        IN  date
                       ,pc_time_point           IN  varchar2
                       ,pn_tolerance_days       IN  number
                       ,pd_project_start_date   IN  date
                       ,pd_project_end_date     IN  date
                       ,pd_task_start_date      IN  date
                       ,pd_task_end_date        IN  date
                       ) return number;

FUNCTION PJM_SELECT_PROJECT_MANAGER(pn_project_id IN  number
                                 ) return varchar2;

FUNCTION PJM_SELECT_TASK_MANAGER(pn_task_id IN  number
                              ) return varchar2;

PROCEDURE  SELECT_DOCUMENT_TYPE(ITEMTYPE          IN  VARCHAR2
                               ,ITEMKEY           IN  VARCHAR2
                               ,ACTID             IN  NUMBER
                               ,FUNCMODE          IN  VARCHAR2
                               ,RESULTOUT         OUT NOCOPY VARCHAR2
                               );

PROCEDURE PJM_WF_SEEK_PROJECT_MGR( itemtype  in varchar2,
		                   itemkey   in varchar2,
		                   actid     in number,
		                   funcmode  in varchar2,
		                   resultout out nocopy varchar2
		                   );

PROCEDURE PJM_WF_SEEK_TASK_MGR(  itemtype  in varchar2,
		                 itemkey   in varchar2,
		                 actid     in number,
		                 funcmode  in varchar2,
		                 resultout out nocopy varchar2
		                 );

END PJM_INTEGRATION_PROJ_MFG;

 

/
