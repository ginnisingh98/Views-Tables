--------------------------------------------------------
--  DDL for Package Body CS_ALW_STS_TRANSITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_ALW_STS_TRANSITIONS_PVT" AS
/* $Header: csvalstb.pls 120.0.12010000.2 2009/04/29 10:17:50 bkanimoz ship $ */

Procedure Copy_Status_Group(p_statusGroupId  IN VARCHAR2,
                            x_statusGroupId OUT NOCOPY VARCHAR2,
                            x_errorCode     OUT NOCOPY NUMBER,
                            x_errorMessage  OUT NOCOPY VARCHAR2)

IS

CURSOR c_statusGroups(p_statusGroupId VARCHAR2) IS
   SELECT csgb.created_by
         ,csgb.creation_date
         ,csgb.start_date
         ,csgb.end_date
         ,csgb.last_update_date
         ,csgb.last_update_login
         ,csgb.last_updated_by
         ,csgb.default_incident_status_id
	 ,csgb.transition_ind --bug 8225437
         ,csgb.security_group_id
         ,csgb.group_name
         ,csgb.description
         ,csgb.language
         ,csgb.source_lang
     FROM CS_SR_STATUS_GROUPS_VL  csgb
    WHERE csgb.status_group_id = p_statusGroupId ;


CURSOR c_allowedStatuses(p_statusGroupId VARCHAR2) IS
   SELECT *
     FROM CS_SR_ALLOWED_STATUSES
    WHERE status_group_id = p_statusGroupId;


CURSOR c_StatusTransitions(p_statusGroupId VARCHAR2) IS
   SELECT *
     FROM CS_SR_STATUS_TRANSITIONS
    WHERE status_group_id = p_statusGroupId;

lv_new_statusgroupID         NUMBER:=NULL;
--lv_new_allowstatusID       NUMBER:=NULL;
--lv_new_statustransitionsID NUMBER:NULL;
lv_copy_of_group_name        VARCHAR2(240);
l_copy_of                    VARCHAR2(20);
l_from_allowed_status_id     NUMBER;
l_to_allowed_status_id       NUMBER;
l_row_id                     VARCHAR2(1000);
BEGIN

   SELECT CS_SR_STATUS_GROUPS_B_S.nextval INTO lv_new_statusgroupID FROM DUAL;

   FND_MESSAGE.SET_NAME('CS','CS_SR_COPY_OF');
--   l_copy_of :=FND_MESSAGE.GET || fnd_global.local_CHR(10);
   l_copy_of :=FND_MESSAGE.GET;

   FOR c_statusGroups_rec in c_statusGroups(p_statusGroupId) LOOP
       lv_copy_of_group_name := l_copy_of||' '||c_statusGroups_rec.group_name||'-'||lv_new_statusgroupID;

    -- Create a Status group record in cs_sr_status_groups_b and cs_sr_status_groups_tl table

    -- bug 3625236 - Reverse the parameters passed to start and end date
    BEGIN
      CS_SR_STATUS_GROUPS_PKG.INSERT_ROW
       ( X_ROWID                      => l_row_id ,
         X_STATUS_GROUP_ID            => lv_new_statusgroupID ,
         X_SECURITY_GROUP_ID          => null ,
         X_TRANSITION_IND             => c_statusGroups_rec.transition_ind ,--bug 8225437
         X_OBJECT_VERSION_NUMBER      => 1 ,
         X_ORIG_SYSTEM_REFERENCE_ID   => null ,
         X_END_DATE                   => c_statusGroups_rec.end_date,
         X_START_DATE                 => c_statusGroups_rec.start_date,
         X_DEFAULT_INCIDENT_STATUS_ID => c_statusGroups_rec.default_incident_status_id,
         X_GROUP_NAME                 => lv_copy_of_group_name ,
         X_DESCRIPTION                => c_statusGroups_rec.description,
         X_LANGUAGE                   => c_statusGroups_rec.language ,
         X_SOURCE_LANG                => c_statusGroups_rec.source_lang ,
         X_CREATION_DATE              => sysdate,
         X_CREATED_BY                 => FND_GLOBAL.USER_ID ,
         X_LAST_UPDATE_DATE           => sysdate ,
         X_LAST_UPDATED_BY            => FND_GLOBAL.USER_ID,
         X_LAST_UPDATE_LOGIN          => null) ;
   EXCEPTION
        WHEN others THEN
             x_errorCode := 1;
             x_errorMessage :=  SQLERRM;
             EXIT ;

   END ;


/***  Commented since the insert into cs_sr_status_groups_b and cs_sr_status_groups_tl will be
      done using table handlers as above

       --Insert a new record into CS_SR_STATUS_GROUPS_B

       INSERT INTO CS_SR_STATUS_GROUPS_B(
              status_group_id,
              created_by,
              creation_date,
              start_date,
              end_date,
              last_update_date,
              last_update_login,
              last_updated_by,
              default_incident_status_id,
              security_group_id,
              object_version_number)
       VALUES (
              lv_new_statusgroupID,
              FND_GLOBAL.USER_ID,
              sysdate,
              c_statusGroups_rec.start_date,
              c_statusGroups_rec.end_date,
              sysdate,
              FND_GLOBAL.LOGIN_ID,
              FND_GLOBAL.USER_ID,
              c_statusGroups_rec.default_incident_status_id,
              c_statusGroups_rec.security_group_id,
              0);

       --Insert a new record into CS_SR_STATUS_GROUPS_TL

       INSERT INTO CS_SR_STATUS_GROUPS_TL(
              status_group_id,
              created_by,
              creation_date,
              last_update_date,
              last_update_login,
              last_updated_by,
              group_name,
              description,
              language,
              source_lang )
       VALUES (
              lv_new_statusgroupID,
              FND_GLOBAL.USER_ID,
              sysdate,
              sysdate,
              FND_GLOBAL.LOGIN_ID,
              FND_GLOBAL.USER_ID,
              lv_copy_of_group_name,
              c_statusGroups_rec.description,
              c_statusGroups_rec.language,
              c_statusGroups_rec.source_lang );
***/

       END LOOP;

    FOR c_allowedStatuses_rec in c_allowedStatuses(p_statusGroupId) LOOP

       --Insert a new record into CS_SR_ALLOWED_STATUSES

       INSERT INTO CS_SR_ALLOWED_STATUSES(
              status_group_id,
              created_by,
              creation_date,
              start_date,
              end_date,
              last_update_date,
              last_update_login,
              last_updated_by,
              allowed_status_id,
              incident_status_id,
              object_version_number)
       VALUES (
              lv_new_statusgroupID,
              FND_GLOBAL.USER_ID,
              sysdate,
              c_allowedStatuses_rec.start_date,
              c_allowedStatuses_rec.end_date,
              sysdate,
              FND_GLOBAL.LOGIN_ID,
              FND_GLOBAL.USER_ID,
              CS_SR_ALLOWED_STATUSES_S.nextval,
              c_allowedStatuses_rec.incident_status_id,
              0);
       END LOOP;


       FOR c_StatusTransitions_rec in c_StatusTransitions(p_statusGroupId) LOOP

           l_from_allowed_status_id := null;
           l_to_allowed_status_id   := null;

       --Insert a new record into CS_SR_STATUS_TRANSITIONS

       -- get from_allowed_status_id from the allowed statuses for the new status group

      BEGIN

       SELECT allowed_status_id
         INTO l_from_allowed_status_id
         FROM cs_sr_allowed_statuses
        WHERE status_group_id = lv_new_statusgroupID
          AND incident_status_id = c_StatusTransitions_rec.from_incident_status_id ;

      EXCEPTION
           WHEN others THEN
                x_errorCode := 1;
                x_errorMessage :=  SUBSTR(SQLERRM,1,280);
                EXIT ;
      END ;

      BEGIN

       SELECT allowed_status_id
         INTO l_to_allowed_status_id
         FROM cs_sr_allowed_statuses
        WHERE status_group_id = lv_new_statusgroupID
          AND incident_status_id = c_StatusTransitions_rec.to_incident_status_id ;

      EXCEPTION
           WHEN others THEN
                x_errorCode := 1;
                x_errorMessage :=  SUBSTR(SQLERRM,1,280);
                EXIT ;
      END ;

       INSERT INTO CS_SR_STATUS_TRANSITIONS(
              status_group_id,
              created_by,
              creation_date,
              start_date,
              end_date,
              last_update_date,
              last_update_login,
              last_updated_by,
              status_transition_id,
              from_allowed_status_id,
              to_allowed_status_id,
              from_incident_status_id,
              to_incident_status_id,
              object_version_number)
       VALUES (
              lv_new_statusgroupID,
              FND_GLOBAL.USER_ID,
              sysdate,
              c_statusTransitions_rec.start_date,
              c_statusTransitions_rec.end_date,
              sysdate,
              FND_GLOBAL.LOGIN_ID,
              FND_GLOBAL.USER_ID,
              CS_SR_STATUS_TRANSITIONS_S.nextval,
              l_from_allowed_status_id,
              l_to_allowed_status_id,
              c_StatusTransitions_rec.from_incident_status_id,
              c_StatusTransitions_rec.to_incident_status_id,
              0);
       END LOOP;

x_statusGroupId := lv_new_statusgroupID;


EXCEPTION
   WHEN OTHERS THEN
     x_errorCode := 1;
     x_errorMessage :=  SUBSTR(SQLERRM,1,280);
END Copy_Status_Group;


Procedure AllowedStatus_StartDate_Valid(p_statusGroupId     IN number,
                                        p_allowed_status_id IN number,
                                        p_new_start_date    IN date,
                                        x_errorCode        OUT NOCOPY number,
                                        x_errorMessage     OUT NOCOPY varchar2,
                                        x_return_code      OUT NOCOPY varchar2)
IS

CURSOR c_Findstatus(p_allowed_status_id number,p_statusGroupId number) IS
   SELECT start_date
     FROM cs_sr_status_transitions
    WHERE (from_allowed_status_id = p_allowed_status_id
      OR   to_allowed_status_id = p_allowed_status_id)
      AND status_group_id = p_statusGroupId;

BEGIN

   x_return_code := 'S';

   FOR c_Findstatus_rec in C_Findstatus(p_allowed_status_id,p_statusGroupId) LOOP
      IF (p_new_start_date > c_Findstatus_rec.start_date) OR
         (c_Findstatus_rec.start_date IS NULL)  THEN
         x_return_code := 'E';
         exit;
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
     x_errorCode := 1;
     x_errorMessage :=  SUBSTR(SQLERRM,1,280);

END AllowedStatus_StartDate_Valid;

Procedure AllowedStatus_EndDate_Valid(p_statusGroupId     IN number,
                                      p_allowed_status_id IN number,
                                      p_new_end_date      IN date,
                                      p_incident_status_id IN NUMBER,
                                      x_errorCode        OUT NOCOPY number,
                                      x_errorMessage     OUT NOCOPY varchar2,
                                      x_return_code      OUT NOCOPY varchar2)
IS

CURSOR c_FindEndDate(p_allowed_status_id number,p_statusGroupId number) IS
   SELECT end_date,status_group_id
     FROM cs_sr_status_transitions
    WHERE (from_allowed_status_id = p_allowed_status_id
      OR   to_allowed_status_id = p_allowed_status_id)
      AND status_group_id = p_statusGroupId;

CURSOR c_def_active (p_statusgroupid number) IS
       SELECT default_incident_status_id
         FROM cs_sr_status_groups_b
        WHERE status_group_id  = p_statusgroupid ;

BEGIN

   x_return_code := 'S';

   FOR c_FindEndDate_rec in C_FindEndDate(p_allowed_status_id,p_statusGroupId) LOOP
      --IF (to_char(c_FindEndDate_rec.end_date,'DD-MON-RRRR') = '01-JAN-1000') THEN
      IF (c_FindEndDate_rec.end_date is null) THEN
         x_return_code := 'N';
         exit;
      ELSIF (to_char(c_FindEndDate_rec.end_date,'DD-MON-RRRR') > to_char(p_new_end_date,'DD-MON-RRRR')) THEN
         x_return_code := 'E';
         exit;
      END IF;
   END LOOP;

   FOR c_def_active_rec IN c_def_active(p_statusGroupId)
       LOOP
          IF c_def_active_rec.default_incident_status_id = p_incident_status_id THEN
             x_return_code := 'D' ;
             exit ;
          END IF ;
       END LOOP ;

EXCEPTION
   WHEN OTHERS THEN
     x_errorCode := 1;
     x_errorMessage :=  SUBSTR(SQLERRM,1,280);

END AllowedStatus_EndDate_Valid;


Function returnStartDate(p_allowed_status_id NUMBER) RETURN DATE IS

l_returnStartDate DATE;

BEGIN
   SELECT start_date
     INTO l_returnStartDate
     FROM cs_sr_allowed_statuses
    WHERE allowed_status_id = p_allowed_status_id
      AND ROWNUM < 2;

   return l_returnStartDate;

END;


Function returnEndDate(p_allowed_status_id NUMBER) RETURN DATE IS


l_returnEndDate DATE;

BEGIN
   SELECT end_date
     INTO l_returnEndDate
     FROM cs_sr_allowed_statuses
    WHERE allowed_status_id = p_allowed_status_id
      AND ROWNUM < 2;

   return l_returnEndDate;

END;

Procedure StatusTrans_StartDate_Valid(p_statusGroupId          IN number,
                                      p_from_allowed_status_id IN number,
                                      p_to_allowed_status_id   IN number,
                                      p_new_start_date         IN date,
                                      x_errorCode             OUT NOCOPY number,
                                      x_errorMessage          OUT NOCOPY varchar2,
                                      x_return_code           OUT NOCOPY varchar2)
IS

l_FromDate DATE;
l_ToDate   DATE;

BEGIN
   l_FromDate := TRUNC(NVL(returnStartDate(p_from_allowed_status_id),sysdate));
   l_ToDate   := TRUNC(NVL(returnStartDate(p_to_allowed_status_id),sysdate));

   x_return_code := 'S';
   IF ( (TRUNC(NVL(p_new_start_date,sysdate)) < l_FromDate) OR (TRUNC(NVL(p_new_start_date,sysdate)) < l_ToDate) ) THEN
      x_return_code := 'E';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_errorCode := 1;
     x_errorMessage :=  SUBSTR(SQLERRM,1,280);

END StatusTrans_StartDate_Valid;


Procedure StatusTrans_EndDate_Valid(p_statusGroupId          IN number,
                                    p_from_allowed_status_id IN number,
                                    p_to_allowed_status_id   IN number,
                                    p_new_end_date           IN date,
                                    x_errorCode             OUT NOCOPY number,
                                    x_errorMessage          OUT NOCOPY varchar2,
                                    x_return_code           OUT NOCOPY varchar2)

IS

l_FromDate DATE;
l_ToDate   DATE;
BEGIN
   l_FromDate := returnEndDate(p_from_allowed_status_id);
   l_ToDate   := returnEndDate(p_to_allowed_status_id);


   x_return_code := 'S';


   IF (p_new_end_date is null) THEN
      UPDATE cs_sr_allowed_statuses
         SET end_date = null
       WHERE allowed_status_id in (p_to_allowed_status_id,p_from_allowed_status_id)
         AND status_group_id = p_statusGroupId;
   ELSE

      IF (l_FromDate is null) THEN
         l_FromDate := p_new_end_date + 1;
      END IF;

      IF (l_ToDate is null) THEN
         l_ToDate := p_new_end_date + 1;
      END IF;

      IF ((to_char(p_new_end_date,'DD-MON-RRRR') > to_char(l_FromDate,'DD-MON-RRRR'))
       OR (to_char(p_new_end_date,'DD-MON-RRRR') > to_char(l_ToDate,'DD-MON-RRRR'))) THEN
         x_return_code := 'E';
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_errorCode := 1;
     x_errorMessage :=  SUBSTR(SQLERRM,1,280);



END StatusTrans_EndDate_Valid;


Procedure Set_Transition_Ind(p_statusGroupId IN number)
IS
Status_Transition_Counter NUMBER:=0;
Indicator varchar2(1):=null;

BEGIN
   SELECT count(0)
     INTO Status_Transition_Counter
     FROM cs_sr_status_transitions
    WHERE status_group_id = p_statusGroupId;

   IF (Status_Transition_Counter > 0) THEN
      Indicator := 'Y';
   ELSE
      Indicator := null;
   END IF;

   UPDATE cs_sr_status_groups_b
      SET transition_ind = Indicator
    WHERE status_group_id = p_statusGroupId;

END Set_Transition_Ind;


END CS_ALW_STS_TRANSITIONS_PVT;

/
