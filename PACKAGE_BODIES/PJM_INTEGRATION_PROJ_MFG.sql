--------------------------------------------------------
--  DDL for Package Body PJM_INTEGRATION_PROJ_MFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_INTEGRATION_PROJ_MFG" as
/* $Header: PJMVLDTB.pls 115.8 2002/10/29 20:15:51 alaw ship $ */

FUNCTION PJM_VALIDATE_DATE  (P_SCHEDULE_DATE     IN  DATE
  		            ,P_TIME_POINT        IN  VARCHAR2
 			    ,P_PROJECT_ID        IN  NUMBER
 			    ,P_TASK_ID           IN  NUMBER
 			    ,P_TOLERANCE_DAYS    IN  NUMBER
                            ,P_ERROR_MSG         OUT NOCOPY VARCHAR2
                            ) return number
IS
   d_proj_start_date      date;
   d_proj_end_date        date;
   d_task_start_date      date;
   d_task_end_date        date;
   c_x                    varchar2(1);
   n_valid                number :=1;
   n_invalid              number :=0;

BEGIN

  IF p_schedule_date IS NULL OR p_project_id IS NULL THEN
     RETURN n_valid;
  END IF;

  BEGIN
     IF p_task_id IS NULL THEN
        select ppa.start_date
              ,ppa.completion_date
          into d_proj_start_date
              ,d_proj_end_date
          from pa_projects_all                ppa
         where ppa.project_id                =p_project_id
           ;
        d_task_start_date  :=Null;
        d_task_end_date    :=Null;
     ELSE
        select ppa.start_date
              ,ppa.completion_date
              ,pt.start_date
              ,pt.completion_date
          into d_proj_start_date
              ,d_proj_end_date
              ,d_task_start_date
              ,d_task_end_date
          from pa_projects_all                ppa
              ,pa_tasks                       pt
         where ppa.project_id                =p_project_id
           and pt.project_id                 =ppa.project_id
           and pt.task_id                    =p_task_id
           ;
     END IF;
  EXCEPTION
     when no_data_found then
        p_error_msg := sqlerrm;
        RETURN n_invalid;
     when too_many_rows then
        p_error_msg := sqlerrm;
        RETURN n_invalid;
  END;

  IF p_time_point='BEFORE_START' then
     IF p_schedule_date-p_tolerance_days > nvl(d_task_start_date,nvl(d_proj_start_date,p_schedule_date-p_tolerance_days+1)) THEN
        FND_MESSAGE.SET_NAME('PJM','SCHED-DATE BEFORE');
        FND_MESSAGE.SET_TOKEN('DATE', FND_DATE.DATE_TO_DISPLAYDATE(
                          nvl(d_task_start_date,d_proj_start_date)));
        p_error_msg := FND_MESSAGE.GET;
        RETURN n_invalid;
     END IF;
  END IF;

  IF upper(p_time_point)='BEFORE_END' then
     IF p_schedule_date-p_tolerance_days > nvl(d_task_end_date,nvl(d_proj_end_date,p_schedule_date-p_tolerance_days+1)) THEN
        FND_MESSAGE.SET_NAME('PJM','SCHED-DATE BEFORE');
        FND_MESSAGE.SET_TOKEN('DATE', FND_DATE.DATE_TO_DISPLAYDATE(
                          nvl(d_task_end_date, d_proj_end_date)));
        p_error_msg := FND_MESSAGE.GET;
        RETURN n_invalid;
     END IF;
  END IF;

  IF upper(p_time_point)='AFTER_START' then
     IF p_schedule_date+p_tolerance_days < nvl(d_task_start_date,nvl(d_proj_start_date,p_schedule_date+p_tolerance_days-1)) THEN
        FND_MESSAGE.SET_NAME('PJM','SCHED-DATE AFTER');
        FND_MESSAGE.SET_TOKEN('DATE', FND_DATE.DATE_TO_DISPLAYDATE(
                          nvl(d_task_start_date,d_proj_start_date)));
        p_error_msg := FND_MESSAGE.GET;
        RETURN n_invalid;
     END IF;
  END IF;

  IF upper(p_time_point)='AFTER_END' then
     IF p_schedule_date+p_tolerance_days < nvl(d_task_end_date,nvl(d_proj_end_date,p_schedule_date+p_tolerance_days-1)) THEN
        FND_MESSAGE.SET_NAME('PJM','SCHED-DATE AFTER');
        FND_MESSAGE.SET_TOKEN('DATE', FND_DATE.DATE_TO_DISPLAYDATE(
                          nvl(d_task_end_date, d_proj_end_date)));
        p_error_msg := FND_MESSAGE.GET;
        RETURN n_invalid;
     END IF;
  END IF;

  IF upper(p_time_point)='BETWEEN' then
     IF (p_schedule_date+p_tolerance_days < nvl(d_task_start_date,nvl(d_proj_start_date,p_schedule_date+p_tolerance_days-1)) OR
         p_schedule_date-p_tolerance_days > nvl(d_task_end_date,nvl(d_proj_end_date,p_schedule_date-p_tolerance_days+1))) THEN
        FND_MESSAGE.SET_NAME('PJM','SCHED-DATE BETWEEN');
        FND_MESSAGE.SET_TOKEN('START_DATE', FND_DATE.DATE_TO_DISPLAYDATE(
                          nvl(d_task_start_date,d_proj_start_date)));
        FND_MESSAGE.SET_TOKEN('END_DATE', FND_DATE.DATE_TO_DISPLAYDATE(
                          nvl(d_task_end_date, d_proj_end_date)));
        p_error_msg := FND_MESSAGE.GET;
        RETURN n_invalid;
     END IF;
  END IF;

  RETURN n_valid;

END PJM_VALIDATE_DATE;


FUNCTION PJM_EXCEPTION_DAYS(pd_schedule_date        IN  date
                       ,pc_time_point           IN  varchar2
                       ,pn_tolerance_days       IN  number
                       ,pd_project_start_date   IN  date
                       ,pd_project_end_date     IN  date
                       ,pd_task_start_date      IN  date
                       ,pd_task_end_date        IN  date
                       ) return number
IS
   n_exception_days number:=0;
BEGIN
   IF pd_schedule_date IS NULL THEN
      RETURN n_exception_days;
   END IF;

   IF pc_time_point='BEFORE_START' then
      IF trunc(pd_schedule_date)-pn_tolerance_days > trunc(nvl(pd_task_start_date,nvl(pd_project_start_date,pd_schedule_date-pn_tolerance_days+1))) THEN
         n_exception_days:=(trunc(pd_schedule_date)-pn_tolerance_days) - trunc(nvl(pd_task_start_date,pd_project_start_date));
      END IF;
   END IF;

   IF upper(pc_time_point)='BEFORE_END' then
      IF trunc(pd_schedule_date)-pn_tolerance_days > trunc(nvl(pd_task_end_date,nvl(pd_project_end_date,pd_schedule_date-pn_tolerance_days+1))) THEN
         n_exception_days:=(trunc(pd_schedule_date)-pn_tolerance_days) - trunc(nvl(pd_task_end_date,pd_project_end_date));
      END IF;
   END IF;

   IF upper(pc_time_point)='AFTER_START' then
      IF trunc(pd_schedule_date)+pn_tolerance_days < trunc(nvl(pd_task_start_date,nvl(pd_project_start_date,pd_schedule_date+pn_tolerance_days-1))) THEN
         n_exception_days:=trunc(nvl(pd_task_start_date,pd_project_start_date))-(trunc(pd_schedule_date)+pn_tolerance_days);
      END IF;
   END IF;

   IF upper(pc_time_point)='AFTER_END' then
      IF trunc(pd_schedule_date)+pn_tolerance_days < trunc(nvl(pd_task_end_date,nvl(pd_project_end_date,pd_schedule_date+pn_tolerance_days-1))) THEN
         n_exception_days:=trunc(nvl(pd_task_end_date,pd_project_end_date))-(trunc(pd_schedule_date)+pn_tolerance_days);
      END IF;
   END IF;

   IF upper(pc_time_point)='BETWEEN' then
      -- positive --> too early
      -- negative --> too late
      IF trunc(pd_schedule_date)+pn_tolerance_days < trunc(nvl(pd_task_start_date,nvl(pd_project_start_date,pd_schedule_date+pn_tolerance_days-1))) THEN
         n_exception_days:=trunc(nvl(pd_task_start_date,pd_project_start_date))-(trunc(pd_schedule_date)+pn_tolerance_days);
      END IF;
      IF trunc(pd_schedule_date)-pn_tolerance_days > trunc(nvl(pd_task_end_date,nvl(pd_project_end_date,pd_schedule_date-pn_tolerance_days+1))) THEN
         n_exception_days:=trunc(nvl(pd_task_end_date,pd_project_end_date)) - (trunc(pd_schedule_date)-pn_tolerance_days);
      END IF;
   END IF;

   RETURN n_exception_days;

END PJM_EXCEPTION_DAYS;


FUNCTION PJM_SELECT_PROJECT_MANAGER(pn_project_id IN  number
                                 ) return varchar2
IS
   c_project_manager varchar2(240):='';

   cursor cu_project_manager is
      select fu.user_name              project_manager
        from fnd_user                  fu
            ,pa_project_players        ppp
            ,pa_projects_all           ppa
       where fu.employee_id            =ppp.person_id
         and nvl(fu.end_date,sysdate)  >=sysdate
         and ppp.project_role_type     = 'PROJECT MANAGER'
         and ppp.project_id            = ppa.project_id
         and nvl(ppp.end_date_active,sysdate) >= sysdate
         and ppa.project_id            = pn_project_id
       order by fu.user_name
       ;
BEGIN
   open cu_project_manager;
      FETCH cu_project_manager INTO c_project_manager;
   close cu_project_manager;

   return c_project_manager;

END PJM_SELECT_PROJECT_MANAGER;

FUNCTION PJM_SELECT_TASK_MANAGER(pn_task_id IN  number
                              ) return varchar2
IS
   c_task_manager varchar2(240):='';

   cursor cu_task_manager is
      select fu.user_name              task_manager
        from fnd_user                  fu
            ,pa_tasks                  pt
       where fu.employee_id            =pt.task_manager_person_id
         and nvl(fu.end_date,sysdate)  >=sysdate
         and pt.task_id                = pn_task_id
       order by fu.user_name
         ;
BEGIN
   open cu_task_manager;
      FETCH cu_task_manager INTO c_task_manager;
   close cu_task_manager;

   return c_task_manager;
END PJM_SELECT_TASK_MANAGER;

PROCEDURE  SELECT_DOCUMENT_TYPE(ITEMTYPE          IN  VARCHAR2
                               ,ITEMKEY           IN  VARCHAR2
                               ,ACTID             IN  NUMBER
                               ,FUNCMODE          IN  VARCHAR2
                               ,RESULTOUT         OUT NOCOPY VARCHAR2
                               ) IS
BEGIN
   if (funcmode='RUN') then
      resultout:=wf_engine.getitemattrtext(itemtype => itemtype
                                          ,itemkey  => itemkey
                                          ,aname    => 'DOCUMENT_TYPE'
                                          );
      return;
   end if;
   if (funcmode='CANCEL') then
      resultout:='COMPLETE:';
      return;
   end if;
   if (funcmode='TIMEOUT') then
      resultout:='COMPLETE:';
      return;
   end if;
END SELECT_DOCUMENT_TYPE;

PROCEDURE PJM_WF_SEEK_PROJECT_MGR( itemtype  in varchar2,
		                   itemkey   in varchar2,
		                   actid     in number,
		                   funcmode  in varchar2,
		                   resultout out nocopy varchar2)
IS
   xc_project_manager	  varchar2(80) :=
   wf_engine.GetItemAttrText( itemtype => itemtype,
		              itemkey  => itemkey,
			      aname    => 'PROJECT_MANAGER');

BEGIN
   if (funcmode = 'RUN') then
      if (xc_project_manager is not null) then
         resultout := 'COMPLETE:FOUND';
      else
         resultout := 'COMPLETE:NOT_FOUND';
      end if;
      return;
   end if;
   if (funcmode = 'CANCEL') then
      resultout := 'COMPLETE:';
      return;
   end if;
   if (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:';
      return;
   end if;
EXCEPTION
   when others then
      wf_core.context('PJM_INTEGRATION_PROJ_MFG', 'PJM_WF_SEEK_PROJECT_MGR',itemtype, itemkey, actid,funcmode,resultout);
      raise;

END PJM_WF_SEEK_PROJECT_MGR;

PROCEDURE PJM_WF_SEEK_TASK_MGR(  itemtype  in varchar2,
		                 itemkey   in varchar2,
		                 actid     in number,
		                 funcmode  in varchar2,
		                 resultout out nocopy varchar2)
IS
   xc_task_manager   	  varchar2(80) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'TASK_MANAGER');

BEGIN
   if (funcmode = 'RUN') then
      if (xc_task_manager is not null) then
         resultout := 'COMPLETE:FOUND';
      else
         resultout := 'COMPLETE:NOT_FOUND';
      end if;
      return;
   end if;
   if (funcmode = 'CANCEL') then
      resultout := 'COMPLETE:';
      return;
   end if;
   if (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:';
      return;
   end if;
EXCEPTION
   when others then
      wf_core.context('PJM_INTEGRATION_PROJ_MFG', 'PJM_WF_SEEK_TASK_MGR',itemtype, itemkey, actid,funcmode,resultout);
      raise;
END PJM_WF_SEEK_TASK_MGR;


END PJM_INTEGRATION_PROJ_MFG;

/
