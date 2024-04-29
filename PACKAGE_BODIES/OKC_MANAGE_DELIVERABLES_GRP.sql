--------------------------------------------------------
--  DDL for Package Body OKC_MANAGE_DELIVERABLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_MANAGE_DELIVERABLES_GRP" AS
/* $Header: OKCGMDLB.pls 120.1.12010000.7 2012/08/06 11:52:47 harchand ship $ */

  ---------------------------------------------------------------------------
  -- TYPE Definitions
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Global VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_MANAGE_DELIVERABLES_GRP';
    G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
    g_module CONSTANT VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
    G_ENTITY_NAME             CONSTANT VARCHAR2(40)   :=  'OKC_DELIVERABLES';

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
 ------------------------------------------------------------------------------
    G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
    G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
    G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
    G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
    G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  ---------------------------------------------------------------------------
  -- START: Helper Procedures and Functions
  ---------------------------------------------------------------------------

   /**
   * This helper procedure check for status history record already in
   * okc_del_status_history table, if not, creates a new status history
   * record for given Status.
   */
   PROCEDURE checkAndCreateStatusHistory (
   p_deliverable_id            IN NUMBER,
   p_deliverable_status        IN VARCHAR2,
   x_msg_data                  OUT NOCOPY  VARCHAR2,
   x_msg_count                 OUT NOCOPY  NUMBER,
   x_return_status             OUT NOCOPY  VARCHAR2)
   IS
       l_api_version                CONSTANT NUMBER := 1;
       l_api_name                   CONSTANT VARCHAR2(30) := 'checkAndCreateStatusHistory';
       l_del_row_count PLS_INTEGER;
    BEGIN

       l_del_row_count := 0;

       -- check for existing status history record
       SELECT count(*) into l_del_row_count
       FROM okc_del_status_history
       WHERE deliverable_id = p_deliverable_id
       AND   deliverable_status = p_deliverable_status;

       IF l_del_row_count = 0 THEN

           -- create status history record
           OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history(
                p_api_version => l_api_version,
                p_init_msg_list => G_FALSE,
                p_del_id        => p_deliverable_id,
                p_deliverable_status  =>  p_deliverable_status,
                x_msg_data      => x_msg_data,
                x_msg_count     => x_msg_count,
                x_return_status => x_return_status);

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'701a: Finished OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history'||x_return_status);
            END IF;
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR ;
            END IF;
       END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving with G_EXC_ERROR');
          END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving with G_EXC_UNEXPECTED_ERROR');
          END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving with G_EXC_UNEXPECTED_ERROR');
          END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END; -- checkAndCreateStatusHistory

   /**
    * Helper method to return proper number value for the day of month.
    * the stored code returns like DOFMXX
    */
   FUNCTION getDayOfMonth(p_code IN VARCHAR2)
   return NUMBER
   IS
        l_day_of_month number;
   BEGIN
     -- initialize
     l_day_of_month := -1;

       -- if input code is not null
       IF p_code is not null THEN
        IF p_code = 'LDOFM' THEN
         return 99;
        ELSE
         l_day_of_month := substr(p_code, 5);
         return (l_day_of_month);
        END IF;
       END IF;
       return NULL;
   END;

   /**
    * Helper method to return correct status of new deliverable instances
    * This method checks, if status of any deliverable intance is 'INACTIVE', the case
    * where Instances remain INACTIVE, hence new generated instances should be of
    * same status.
    */
   FUNCTION checkStatusOfExistingInstances(p_bus_doc_id IN NUMBER,
                                           p_bus_doc_type IN VARCHAR2,
                                           p_bus_doc_version IN NUMBER,
                                           p_del_id IN NUMBER)
   return VARCHAR2
   IS
     l_api_name CONSTANT VARCHAR2(50) := 'checkStatusOfExistingInstances';
     l_del_status OKC_DELIVERABLES.deliverable_status%TYPE;
   BEGIN

    -- initialize
    l_del_status := null;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: INTO '||G_PKG_NAME ||'.'||l_api_name);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: doc id '||p_bus_doc_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: doc type '||p_bus_doc_type);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'103: doc version '||p_bus_doc_version);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: del id '||p_del_id);
        END IF;

       SELECT deliverable_status into l_del_status
       FROM okc_deliverables
       WHERE business_document_id = p_bus_doc_id
       AND   business_document_type = p_bus_doc_type
       AND   business_document_version = p_bus_doc_version
       AND   recurring_del_parent_id = p_del_id
       AND   rownum = 1;

       IF l_del_status is not null THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105: Status returning '||l_del_status);
            END IF;

         IF l_del_status = 'INACTIVE' THEN
            return 'INACTIVE';
         ELSE
           return 'OPEN';
         END IF;
       END IF;
       return NULL;

    EXCEPTION
        WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
        END IF;
      Okc_Api.Set_Message(G_APP_NAME,
                        'OKC_DEL_ERR_CHK_INSTS_STS');
        RAISE FND_API.G_EXC_ERROR;
   END;

   /**
    * Helper method to return 'Y' if recurring deliverable definition already
    * has instances in place for given bus doc version.
    */
   FUNCTION hasInstances(p_bus_doc_id IN NUMBER,
                         p_bus_doc_type IN VARCHAR2,
                         p_bus_doc_version IN NUMBER,
                         p_del_id IN NUMBER)
   return VARCHAR2
   IS
     l_del_row_count number;
   BEGIN
       -- initialize
       l_del_row_count := 0;
       SELECT count(*) into l_del_row_count
       FROM okc_deliverables
       WHERE business_document_id = p_bus_doc_id
       AND   business_document_type = p_bus_doc_type
       AND   business_document_version = p_bus_doc_version
       AND   recurring_del_parent_id = p_del_id;

       IF l_del_row_count > 0 THEN
        return 'Y';
       ELSE
        return 'N';
       END IF;
       return NULL;
   END;

   /**
    * Helper method to generate recurring deliverable instances and return
    * table of records containing deliverable details
    */
   PROCEDURE generate_del_instances(
                                   p_recurr_start_date IN DATE,
                                   p_recurr_end_date IN DATE,
                                   p_repeat_duration IN NUMBER,
                                   p_repeat_day_of_month IN NUMBER,
                                   p_repeat_day_of_week IN NUMBER,
                                   delRecord okc_deliverables%ROWTYPE,
                                   p_change_status_to IN VARCHAR2)
   IS

   --- for recurring dates
   l_recurring_dates OKC_DELIVERABLE_PROCESS_PVT.recurring_dates_tab_type;
   delInstanceRecTab OKC_DELIVERABLE_PROCESS_PVT.delRecTabType;

   l_api_version     CONSTANT VARCHAR2(30) := 1;
   l_api_name        CONSTANT VARCHAR2(30) := 'generate_del_instances';

   l_msg_data VARCHAR2(30);
   l_msg_count NUMBER;
   l_return_status VARCHAR2(1);
   l_manage_yn VARCHAR2(1);

   j PLS_INTEGER;
   st_hist_count PLS_INTEGER;
   st_hist_count1 PLS_INTEGER;
   del_count PLS_INTEGER;

   TYPE DelIdList IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
   deliverableIds DelIdList;

   delStsTab OKC_DELIVERABLE_PROCESS_PVT.delHistTabType;
   delStsTab1 OKC_DELIVERABLE_PROCESS_PVT.delHistTabType;
      /* Bug 10048345 */
    CURSOR find_if_deliverable_exists(ACTUAL_DUE_DATE_passed IN DATE , RECURRING_DEL_PARENT_ID_passed IN NUMBER) IS
    SELECT  deliverable_id,ACTUAL_DUE_DATE,RECURRING_DEL_PARENT_ID FROM OKC_DELIVERABLES DEL
    WHERE DEL.RECURRING_DEL_PARENT_ID= RECURRING_DEL_PARENT_ID_passed
    AND DEL.ACTUAL_DUE_DATE = ACTUAL_DUE_DATE_passed ;
    del_find_rec find_if_deliverable_exists%ROWTYPE;
      /* Bug 10048345 */
   BEGIN

    -- initialize
    l_manage_yn := 'N';
    j := 0;
    del_count := 0;
    st_hist_count := 0;
    st_hist_count1 := 0;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Recurr start date'||p_recurr_start_date);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: p_recurr_end_date'||p_recurr_end_date);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'400: p_repeat_day_of_month'||p_repeat_day_of_month);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'500: p_change_status_to'||p_change_status_to);
    END IF;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'501: Calling getRecurringDates');
       END IF;
        --- Calculate recurring instances
        OKC_DELIVERABLE_PROCESS_PVT.get_recurring_dates(
                      p_api_version => l_api_version,
                      p_init_msg_list => G_FALSE,
                      p_start_date => p_recurr_start_date,
                      p_end_date => p_recurr_end_date,
                      p_frequency => p_repeat_duration,
                      p_recurr_day_of_month => p_repeat_day_of_month,
                      p_recurr_day_of_week => p_repeat_day_of_week,
                      x_recurr_dates => l_recurring_dates,
                      x_msg_data => l_msg_data,
                      x_msg_count => l_msg_count,
                      x_return_status => l_return_status);
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished recurring dates api'||l_return_status);
       END IF;

       -- check status
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
       END IF;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'601: Recurr Dates Count'||l_recurring_dates.count);
       END IF;

      IF l_recurring_dates.count > 0 THEN
        --- loop through returned dates
        FOR m IN l_recurring_dates.FIRST..l_recurring_dates.LAST LOOP

                 ---- Here decide which instances to create
             /* Bug 10048345 */
              OPEN find_if_deliverable_exists(l_recurring_dates(m) , delRecord.recurring_del_parent_id);
              FETCH find_if_deliverable_exists INTO del_find_rec;
              IF find_if_deliverable_exists%NOTFOUND THEN

              /* Bug 10048345 */


            j := j+1;
            --- Set the deliverable definition to the new instance
            delInstanceRecTab(j) := delRecord;

            --- set the deliverable id
            select okc_deliverable_id_s.nextval
            INTO delInstanceRecTab(j).deliverable_id from dual;

            --- set the actual due date to the new instance
            delInstanceRecTab(j).actual_due_date :=
                                l_recurring_dates(m);

            --- set/reset other deliverable attributes
            delInstanceRecTab(j).recurring_yn := 'N';

            -- NULL out definition columns
            delInstanceRecTab(j).amendment_operation := NULL;
            delInstanceRecTab(j).amendment_notes := NULL;
            delInstanceRecTab(j).summary_amend_operation_code := NULL;
            delInstanceRecTab(j).last_amendment_date := NULL;
            delInstanceRecTab(j).start_event_date := NULL;
            delInstanceRecTab(j).end_event_date := NULL;

            -- set the original deliverable id as the original deliverable id
            -- on recurring deliverable definition
            delInstanceRecTab(j).original_deliverable_id :=
                               delRecord.original_deliverable_id;

            -- set the recurring del parent id as the deliverable id
            -- of recurring deliverable definition
            delInstanceRecTab(j).recurring_del_parent_id :=
                                          delRecord.deliverable_id;

            -- copy attachments from the definition, if any
            -- check if attachments exists
            IF OKC_DELIVERABLE_PROCESS_PVT.attachment_exists(
                                        p_entity_name => G_ENTITY_NAME,
                                        p_pk1_value   =>  delRecord.deliverable_id ) THEN

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'6011: Call Copy Attachments ');
              END IF;

               -- copy attachments
               -- bug#3667712 added X_CREATED_BY,X_LAST_UPDATE_LOGIN params
               fnd_attached_documents2_pkg.copy_attachments(
                     X_from_entity_name =>  G_ENTITY_NAME,
                     X_from_pk1_value   =>  delRecord.deliverable_id,
                     X_to_entity_name   =>  G_ENTITY_NAME,
                     X_to_pk1_value     =>  to_char(delInstanceRecTab(j).deliverable_id),
                     X_CREATED_BY       =>  FND_GLOBAL.User_id,
                     X_LAST_UPDATE_LOGIN => Fnd_Global.Login_Id);
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'6012: Done Copy Attachments ');
              END IF;

            END IF;

            -- set status history record for INACTIVE status
            st_hist_count := st_hist_count+1;
            delStsTab(st_hist_count).deliverable_id := delInstanceRecTab(j).deliverable_id;
            delStsTab(st_hist_count).deliverable_status:= 'INACTIVE';
            delStsTab(st_hist_count).status_change_date:= sysdate;
            delStsTab(st_hist_count).status_change_notes:= null;
            delStsTab(st_hist_count).object_version_number:= 1;
            delStsTab(st_hist_count).created_by:= Fnd_Global.User_Id;
            delStsTab(st_hist_count).creation_date := sysdate;
            delStsTab(st_hist_count).last_updated_by:= Fnd_Global.User_Id;
            delStsTab(st_hist_count).last_update_date := sysdate;
            delStsTab(st_hist_count).last_update_login := Fnd_Global.Login_Id;

            --- set the status, if required from updateDeliverables
            IF (p_change_status_to is not null) AND (p_change_status_to = 'OPEN') THEN

              --- change status of this new deliverable and add new status history
              --- record
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'602: Change status of this new deliverable '||delInstanceRecTab(j).deliverable_id);
              END IF;

              delInstanceRecTab(j).deliverable_status := p_change_status_to;
              delInstanceRecTab(j).manage_yn := 'Y';

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'607: Set Deliverable status history record to OPEN ');
              END IF;

              -- set status history record for OPEN status
              st_hist_count1 := st_hist_count1+1;
              delStsTab1(st_hist_count1).deliverable_id := delInstanceRecTab(j).deliverable_id;
              delStsTab1(st_hist_count1).deliverable_status:= p_change_status_to;
              delStsTab1(st_hist_count1).status_change_date:= sysdate;
              delStsTab1(st_hist_count1).status_change_notes:= null;
              delStsTab1(st_hist_count1).object_version_number:= 1;
              delStsTab1(st_hist_count1).created_by:= Fnd_Global.User_Id;
              delStsTab1(st_hist_count1).creation_date := sysdate;
              delStsTab1(st_hist_count1).last_updated_by:= Fnd_Global.User_Id;
              delStsTab1(st_hist_count1).last_update_date := sysdate;
              delStsTab1(st_hist_count1).last_update_login := Fnd_Global.Login_Id;

             END IF;
            --- set object version number
            delInstanceRecTab(j).object_version_number:= 1;

            --- set who columns
            delInstanceRecTab(j).created_by:= Fnd_Global.User_Id;
            delInstanceRecTab(j).creation_date := sysdate;
            delInstanceRecTab(j).last_updated_by:= Fnd_Global.User_Id;
            delInstanceRecTab(j).last_update_date := sysdate;
            delInstanceRecTab(j).last_update_login := Fnd_Global.Login_Id;
            /* Bug 10048345*/
                       ELSE
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'####1'||del_find_rec.deliverable_id||'##2'||del_find_rec.ACTUAL_DUE_DATE||'#3'||del_find_rec.RECURRING_DEL_PARENT_ID);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'##1'||l_recurring_dates(m)||'#2'|| delRecord.recurring_del_parent_id);
       END IF;


       END IF;
          IF find_if_deliverable_exists%ISOPEN THEN
                     CLOSE find_if_deliverable_exists ;
          END IF;
          /* Bug 10048345*/


       END LOOP;
       END IF;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'603: END of Loop, creating Instances -- count '||delInstanceRecTab.count);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'604: Bulk Inserting Instances Records ');
       END IF;
        --- bulk insert for deliverable's recurring instances and
      --- actual due date
         IF find_if_deliverable_exists%ISOPEN THEN
                     CLOSE find_if_deliverable_exists ;
          END IF;


          IF delInstanceRecTab.count > 0 THEN

         FOR i IN delInstanceRecTab.FIRST..delInstanceRecTab.LAST LOOP
         INSERT INTO okc_deliverables
         (DELIVERABLE_ID,
          BUSINESS_DOCUMENT_TYPE      ,
          BUSINESS_DOCUMENT_ID        ,
          BUSINESS_DOCUMENT_NUMBER    ,
          DELIVERABLE_TYPE            ,
          RESPONSIBLE_PARTY           ,
          INTERNAL_PARTY_CONTACT_ID   ,
          EXTERNAL_PARTY_CONTACT_ID   ,
          DELIVERABLE_NAME            ,
          DESCRIPTION                 ,
          COMMENTS                    ,
          DISPLAY_SEQUENCE            ,
          FIXED_DUE_DATE_YN           ,
          ACTUAL_DUE_DATE             ,
          PRINT_DUE_DATE_MSG_NAME     ,
          RECURRING_YN                ,
          NOTIFY_PRIOR_DUE_DATE_VALUE ,
          NOTIFY_PRIOR_DUE_DATE_UOM   ,
          NOTIFY_PRIOR_DUE_DATE_YN    ,
          NOTIFY_COMPLETED_YN         ,
          NOTIFY_OVERDUE_YN           ,
          NOTIFY_ESCALATION_YN        ,
          NOTIFY_ESCALATION_VALUE     ,
          NOTIFY_ESCALATION_UOM       ,
          ESCALATION_ASSIGNEE         ,
          AMENDMENT_OPERATION         ,
          PRIOR_NOTIFICATION_ID       ,
          AMENDMENT_NOTES             ,
          COMPLETED_NOTIFICATION_ID   ,
          OVERDUE_NOTIFICATION_ID     ,
          ESCALATION_NOTIFICATION_ID  ,
          LANGUAGE                    ,
          ORIGINAL_DELIVERABLE_ID     ,
          REQUESTER_ID                ,
          EXTERNAL_PARTY_ID           ,
          EXTERNAL_PARTY_ROLE         ,
          RECURRING_DEL_PARENT_ID      ,
          BUSINESS_DOCUMENT_VERSION   ,
          RELATIVE_ST_DATE_DURATION   ,
          RELATIVE_ST_DATE_UOM        ,
          RELATIVE_ST_DATE_EVENT_ID   ,
          RELATIVE_END_DATE_DURATION  ,
          RELATIVE_END_DATE_UOM       ,
          RELATIVE_END_DATE_EVENT_ID  ,
          REPEATING_DAY_OF_MONTH      ,
          REPEATING_DAY_OF_WEEK       ,
          REPEATING_FREQUENCY_UOM     ,
          REPEATING_DURATION          ,
          FIXED_START_DATE            ,
          FIXED_END_DATE              ,
          MANAGE_YN                   ,
          INTERNAL_PARTY_ID           ,
          DELIVERABLE_STATUS          ,
          STATUS_CHANGE_NOTES         ,
          CREATED_BY                  ,
          CREATION_DATE               ,
          LAST_UPDATED_BY             ,
          LAST_UPDATE_DATE            ,
          LAST_UPDATE_LOGIN           ,
          OBJECT_VERSION_NUMBER       ,
          ATTRIBUTE_CATEGORY          ,
          ATTRIBUTE1                  ,
          ATTRIBUTE2                  ,
          ATTRIBUTE3                  ,
          ATTRIBUTE4                  ,
          ATTRIBUTE5                  ,
          ATTRIBUTE6                  ,
          ATTRIBUTE7                  ,
          ATTRIBUTE8                  ,
          ATTRIBUTE9                  ,
          ATTRIBUTE10                 ,
          ATTRIBUTE11                 ,
          ATTRIBUTE12                 ,
          ATTRIBUTE13                 ,
          ATTRIBUTE14                 ,
          ATTRIBUTE15                 ,
          DISABLE_NOTIFICATIONS_YN    ,
          LAST_AMENDMENT_DATE         ,
          BUSINESS_DOCUMENT_LINE_ID   ,
          EXTERNAL_PARTY_SITE_ID      ,
          START_EVENT_DATE            ,
          END_EVENT_DATE              ,
          SUMMARY_AMEND_OPERATION_CODE,
          PAY_HOLD_PRIOR_DUE_DATE_VALUE,
          PAY_HOLD_PRIOR_DUE_DATE_UOM,
          PAY_HOLD_PRIOR_DUE_DATE_YN,
          PAY_HOLD_OVERDUE_YN
          )
         VALUES (
                delInstanceRecTab(i).DELIVERABLE_ID,
                delInstanceRecTab(i).BUSINESS_DOCUMENT_TYPE      ,
                delInstanceRecTab(i).BUSINESS_DOCUMENT_ID        ,
                delInstanceRecTab(i).BUSINESS_DOCUMENT_NUMBER    ,
                delInstanceRecTab(i).DELIVERABLE_TYPE            ,
                delInstanceRecTab(i).RESPONSIBLE_PARTY           ,
                delInstanceRecTab(i).INTERNAL_PARTY_CONTACT_ID   ,
                delInstanceRecTab(i).EXTERNAL_PARTY_CONTACT_ID   ,
                delInstanceRecTab(i).DELIVERABLE_NAME            ,
                delInstanceRecTab(i).DESCRIPTION                 ,
                delInstanceRecTab(i).COMMENTS                    ,
                delInstanceRecTab(i).DISPLAY_SEQUENCE            ,
                delInstanceRecTab(i).FIXED_DUE_DATE_YN           ,
                delInstanceRecTab(i).ACTUAL_DUE_DATE             ,
                delInstanceRecTab(i).PRINT_DUE_DATE_MSG_NAME     ,
                delInstanceRecTab(i).RECURRING_YN                ,
                delInstanceRecTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE ,
                delInstanceRecTab(i).NOTIFY_PRIOR_DUE_DATE_UOM   ,
                delInstanceRecTab(i).NOTIFY_PRIOR_DUE_DATE_YN    ,
                delInstanceRecTab(i).NOTIFY_COMPLETED_YN         ,
                delInstanceRecTab(i).NOTIFY_OVERDUE_YN           ,
                delInstanceRecTab(i).NOTIFY_ESCALATION_YN        ,
                delInstanceRecTab(i).NOTIFY_ESCALATION_VALUE     ,
                delInstanceRecTab(i).NOTIFY_ESCALATION_UOM       ,
                delInstanceRecTab(i).ESCALATION_ASSIGNEE         ,
                delInstanceRecTab(i).AMENDMENT_OPERATION         ,
                delInstanceRecTab(i).PRIOR_NOTIFICATION_ID       ,
                delInstanceRecTab(i).AMENDMENT_NOTES             ,
                delInstanceRecTab(i).COMPLETED_NOTIFICATION_ID   ,
                delInstanceRecTab(i).OVERDUE_NOTIFICATION_ID     ,
                delInstanceRecTab(i).ESCALATION_NOTIFICATION_ID  ,
                delInstanceRecTab(i).LANGUAGE                    ,
                delInstanceRecTab(i).ORIGINAL_DELIVERABLE_ID     ,
                delInstanceRecTab(i).REQUESTER_ID                ,
                delInstanceRecTab(i).EXTERNAL_PARTY_ID           ,
                delInstanceRecTab(i).EXTERNAL_PARTY_ROLE         ,
                delInstanceRecTab(i).RECURRING_DEL_PARENT_ID     ,
                delInstanceRecTab(i).BUSINESS_DOCUMENT_VERSION   ,
                delInstanceRecTab(i).RELATIVE_ST_DATE_DURATION   ,
                delInstanceRecTab(i).RELATIVE_ST_DATE_UOM        ,
                delInstanceRecTab(i).RELATIVE_ST_DATE_EVENT_ID   ,
                delInstanceRecTab(i).RELATIVE_END_DATE_DURATION  ,
                delInstanceRecTab(i).RELATIVE_END_DATE_UOM       ,
                delInstanceRecTab(i).RELATIVE_END_DATE_EVENT_ID  ,
                delInstanceRecTab(i).REPEATING_DAY_OF_MONTH      ,
                delInstanceRecTab(i).REPEATING_DAY_OF_WEEK       ,
                delInstanceRecTab(i).REPEATING_FREQUENCY_UOM     ,
                delInstanceRecTab(i).REPEATING_DURATION          ,
                delInstanceRecTab(i).FIXED_START_DATE            ,
                delInstanceRecTab(i).FIXED_END_DATE              ,
                delInstanceRecTab(i).MANAGE_YN                   ,
                delInstanceRecTab(i).INTERNAL_PARTY_ID           ,
                delInstanceRecTab(i).DELIVERABLE_STATUS          ,
                delInstanceRecTab(i).STATUS_CHANGE_NOTES         ,
                delInstanceRecTab(i).CREATED_BY                  ,
                delInstanceRecTab(i).CREATION_DATE               ,
                delInstanceRecTab(i).LAST_UPDATED_BY             ,
                delInstanceRecTab(i).LAST_UPDATE_DATE            ,
                delInstanceRecTab(i).LAST_UPDATE_LOGIN           ,
                delInstanceRecTab(i).OBJECT_VERSION_NUMBER       ,
                delInstanceRecTab(i).ATTRIBUTE_CATEGORY          ,
                delInstanceRecTab(i).ATTRIBUTE1                  ,
                delInstanceRecTab(i).ATTRIBUTE2                  ,
                delInstanceRecTab(i).ATTRIBUTE3                  ,
                delInstanceRecTab(i).ATTRIBUTE4                  ,
                delInstanceRecTab(i).ATTRIBUTE5                  ,
                delInstanceRecTab(i).ATTRIBUTE6                  ,
                delInstanceRecTab(i).ATTRIBUTE7                  ,
                delInstanceRecTab(i).ATTRIBUTE8                  ,
                delInstanceRecTab(i).ATTRIBUTE9                  ,
                delInstanceRecTab(i).ATTRIBUTE10                 ,
                delInstanceRecTab(i).ATTRIBUTE11                 ,
                delInstanceRecTab(i).ATTRIBUTE12                 ,
                delInstanceRecTab(i).ATTRIBUTE13                 ,
                delInstanceRecTab(i).ATTRIBUTE14                 ,
                delInstanceRecTab(i).ATTRIBUTE15                 ,
                delInstanceRecTab(i).DISABLE_NOTIFICATIONS_YN    ,
                delInstanceRecTab(i).LAST_AMENDMENT_DATE         ,
                delInstanceRecTab(i).BUSINESS_DOCUMENT_LINE_ID   ,
                delInstanceRecTab(i).EXTERNAL_PARTY_SITE_ID      ,
                delInstanceRecTab(i).START_EVENT_DATE            ,
                delInstanceRecTab(i).END_EVENT_DATE              ,
                delInstanceRecTab(i).SUMMARY_AMEND_OPERATION_CODE,
                delInstanceRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                delInstanceRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM,
                delInstanceRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN,
                delInstanceRecTab(i).PAY_HOLD_OVERDUE_YN
                );
                END LOOP;

------------------------------------------------------------------------

           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'604a: Done Insterting DEL Records');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'604b: Now inserting Status history records for INACTIVE');
           END IF;

           IF  delStsTab.count > 0 THEN
                --- set status history record to INACTIVE for each deliverable instance
                OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_del_st_hist_tab => delStsTab,
                                x_msg_data => l_msg_data,
                                x_msg_count => l_msg_count,
                                x_return_status => l_return_status);

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'701a: Finished OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history'||l_return_status);
                END IF;

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                     RAISE FND_API.G_EXC_ERROR ;
                END IF;
            END IF;

           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'604b: Now inserting Status history records for OPEN');
           END IF;

           -- insert status histiry records for OPEN status
           IF  delStsTab1.count > 0 THEN
                --- set status history record to OPEN for each deliverable instance
                OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_del_st_hist_tab => delStsTab1,
                                x_msg_data => l_msg_data,
                                x_msg_count => l_msg_count,
                                x_return_status => l_return_status);

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'701a: Finished OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history'||l_return_status);
                END IF;

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                     RAISE FND_API.G_EXC_ERROR ;
                END IF;
            END IF;

           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'605: Done Insterting Records');
           END IF;

           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'606: Do Status Change, if not NULL '||p_change_status_to);
           END IF;

          END IF;

    EXCEPTION
        WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
        END IF;
      Okc_Api.Set_Message(G_APP_NAME,
                        'OKC_DEL_ERR_GEN_INSTS');
        RAISE FND_API.G_EXC_ERROR;
   END; -- generate_del_instances

   /**
    * Helper method to return proper number value for the day of week.
    * the stored code is as varchar value
    */
   FUNCTION getDayOfWeek(p_code IN VARCHAR2)
   return NUMBER
   IS
   BEGIN
       if p_code is not null then
        return(to_number(p_code));
       end if;
       return NULL;
   END;

   /**
    * Helper method to return Event Code and Before After value for given
    * event id, stored in OKC_DELIVERABLES
    */
   PROCEDURE getDelEventDetails(
    p_event_id IN NUMBER,
    p_end_event_yn IN varchar2,
    x_event_name OUT NOCOPY VARCHAR2,
    x_before_after OUT NOCOPY VARCHAR2)
    IS
    l_api_name        CONSTANT VARCHAR2(30) := 'getDelEventDetails';

    BEGIN
--       IF p_end_event_yn = 'Y' THEN

           SELECT business_event_code, before_after into x_event_name, x_before_after
           FROM OKC_BUS_DOC_EVENTS_B
           WHERE bus_doc_event_id = p_event_id;

/*           AND   (start_end_qualifier = 'BOTH' or start_end_qualifier = 'END');
        ELSE
           SELECT business_event_code, before_after into x_event_name, x_before_after
           FROM OKC_BUS_DOC_EVENTS_B
           WHERE bus_doc_event_id = p_event_id
           AND   (start_end_qualifier = 'BOTH' or start_end_qualifier = 'START');
       END IF; */

    EXCEPTION
        WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
        END IF;
      Okc_Api.Set_Message(G_APP_NAME,
                        'OKC_DEL_ERR_EVT_DTLS');
        RAISE FND_API.G_EXC_ERROR;

  END;

  ---------------------------------------------------------------------------
  -- END: Helper Procedures and Functions
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- START: Public Procedures and Functions
  ---------------------------------------------------------------------------

 /**
  *  Called by business document teams, to resolve and activate deliverables
  */
 PROCEDURE activateDeliverables (
    p_api_version                 IN NUMBER,
    p_init_msg_list               IN VARCHAR2,
    p_commit                    IN Varchar2,
    p_bus_doc_id                  IN NUMBER,
    p_bus_doc_type                IN VARCHAR2,
    p_bus_doc_version             IN NUMBER,
    p_event_code                  IN VARCHAR2,
    p_event_date                  IN DATE,
    p_sync_flag                   IN VARCHAR2,
    p_bus_doc_date_events_tbl   IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                    OUT NOCOPY  VARCHAR2,
    x_msg_count                   OUT NOCOPY  NUMBER,
    x_return_status               OUT NOCOPY  VARCHAR2)
    IS
       l_api_version                CONSTANT NUMBER := 1;
       l_api_name                   CONSTANT VARCHAR2(30) := 'activateDeliverables';
    BEGIN

    -- start procedure
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Bus dod id'||p_bus_doc_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Bus dod type'||p_bus_doc_type);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'400: Bus dod version'||p_bus_doc_version);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'500: Bus dod event code'||p_event_code);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Bus dod event date'||p_event_date);
    END IF;

    IF p_bus_doc_id = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_bus_doc_type = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_bus_doc_version = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_event_code = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_event_date = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_activate_del_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --- check if sync flag is TRUE
    IF FND_API.To_Boolean( p_sync_flag ) THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'700: Calling '||'syncDeliverables');
        END IF;
          --- call deliverables process PVT to sync the deliverables for given version
          OKC_DELIVERABLE_PROCESS_PVT.sync_deliverables(
                            p_api_version => l_api_version,
                            p_init_msg_list => G_FALSE,
                            p_current_docid => p_bus_doc_id,
                            p_current_doctype => p_bus_doc_type,
                            p_current_doc_version => p_bus_doc_version,
                            x_msg_data => x_msg_data,
                            x_msg_count => x_msg_count,
                            x_return_status => x_return_status);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'701: Finished resolveDeliverables'||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
       END IF;

    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'702: Calling '||'resolveDeliverables');
    END IF;

    --- resolve deliverables
    resolveDeliverables(
                        p_api_version => l_api_version,
                        p_init_msg_list => G_FALSE,
                        p_commit => G_FALSE,
                        p_bus_doc_id => p_bus_doc_id,
                        p_bus_doc_type => p_bus_doc_type,
                        p_bus_doc_version => p_bus_doc_version,
                        p_event_code => p_event_code,
                        p_event_date => p_event_date,
                        p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                        x_msg_data => x_msg_data,
                        x_msg_count => x_msg_count,
                        x_return_status => x_return_status,
                        p_sync_flag => p_sync_flag,
                        p_sync_recurr_instances_flag => FND_API.G_TRUE);

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'800: Finished resolveDeliverables'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'900: Calling '||'OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status');
    END IF;

    --- call change_deliverable_status, to change deliverable status from
    --- INACTIVE to 'OPEN'
        OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_doc_id => p_bus_doc_id,
                                p_doc_version => p_bus_doc_version,
                                p_doc_type => p_bus_doc_type,
                                p_cancel_yn => 'N',
                                p_cancel_event_code => NULL,
                                p_current_status => 'INACTIVE',
                                p_new_status => 'OPEN',
                                p_manage_yn => 'Y',
                                x_msg_data => x_msg_data,
                                x_msg_count => x_msg_count,
                                x_return_status => x_return_status);

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Finished OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100: Leaving activateDeliverables');
   END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1200: Leaving activateDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_activate_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1300: Leaving activateDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_activate_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1400: Leaving activateDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_activate_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 END; -- activateDeliverables


    FUNCTION resolveRelativeDueEvents(
                            p_bus_doc_date_events_tbl   IN BUSDOCDATES_TBL_TYPE,
                            p_event_code IN VARCHAR2,
                            p_event_date IN DATE,
                            p_event_id IN NUMBER,
                            p_event_UOM IN VARCHAR2,
                            p_event_duration IN NUMBER,
                            p_end_event_yn IN VARCHAR2)
    return DATE
    IS
         l_api_name CONSTANT VARCHAR2(30) := 'resolveRelativeDueEvents';
         l_del_event_name OKC_BUS_DOC_EVENTS_B.business_event_code%TYPE;
         l_del_before_after OKC_BUS_DOC_EVENTS_B.before_after%TYPE;
         l_actual_date DATE;

    BEGIN

    -- initialize
    l_actual_date := null;

      -- start procedure
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      IF p_event_id is NULL OR p_event_UOM is NULL OR p_event_duration is NULL THEN

           Okc_Api.Set_Message(G_APP_NAME,
                          'OKC_DEL_NOT_RSLV_EVTS');
           RAISE FND_API.G_EXC_ERROR;

      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Calling getDelEventDetails');
      END IF;

      --- get current deliverable's end event details
      getDelEventDetails(
           p_event_id => p_event_id,
           p_end_event_yn => p_end_event_yn,
           x_event_name => l_del_event_name,
           x_before_after => l_del_before_after);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Finished getDelEventDetails - Event Name'||l_del_event_name);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: Finished getDelEventDetails - Before After'||l_del_before_after);
      END IF;

      IF (p_event_code is not NULL AND p_event_code = l_del_event_name) THEN
          --- Calculate actual date
          l_actual_date :=
               OKC_DELIVERABLE_PROCESS_PVT.get_actual_date(
               p_start_date => p_event_date,
               p_timeunit => p_event_UOM,
               p_duration => p_event_duration,
               p_before_after => l_del_before_after);

           IF l_actual_date is NULL THEN
               Okc_Api.Set_Message(G_APP_NAME,
                                'OKC_DEL_DT_NOT_RSLVD');
               RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;

      --- if relative, check for event name with the given event names
      --- in table of records.
      IF p_bus_doc_date_events_tbl.count > 0 THEN
         FOR k IN
             p_bus_doc_date_events_tbl.FIRST..p_bus_doc_date_events_tbl.LAST LOOP
             IF p_bus_doc_date_events_tbl(k).event_code = l_del_event_name THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'103: Event Matched '||l_del_event_name);
                END IF;

                --- Calculate actual date
                l_actual_date :=
                OKC_DELIVERABLE_PROCESS_PVT.get_actual_date(
                                  p_start_date => p_bus_doc_date_events_tbl(k).event_date,
                                  p_timeunit => p_event_UOM,
                                  p_duration => p_event_duration,
                                  p_before_after => l_del_before_after);
/*                IF l_actual_date is NULL THEN
                   Okc_Api.Set_Message(G_APP_NAME,
                                    'OKC_DEL_DT_NOT_RSLVD');
                   RAISE FND_API.G_EXC_ERROR;
                END IF; */

              END IF;
         END LOOP;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Returning Resolved Date as '||l_actual_date);
      END IF;
    return l_actual_date;
    END;

    /**
     * Resolve deliverable due date, recurring instances to OKC_DELIVERABLES
     */
    PROCEDURE resolveDeliverables (
        p_api_version                 IN NUMBER,
        p_init_msg_list               IN VARCHAR2,
        p_commit                    IN  Varchar2,
        p_bus_doc_id                  IN NUMBER,
        p_bus_doc_type                IN VARCHAR2,
        p_bus_doc_version             IN NUMBER,
        p_event_code                  IN VARCHAR2,
        p_event_date                  IN DATE,
        p_bus_doc_date_events_tbl   IN BUSDOCDATES_TBL_TYPE,
        x_msg_data                    OUT NOCOPY  VARCHAR2,
        x_msg_count                   OUT NOCOPY  NUMBER,
        x_return_status               OUT NOCOPY  VARCHAR2,
        p_sync_flag                   IN VARCHAR2,
        p_sync_recurr_instances_flag  IN VARCHAR2,
        p_cancel_flag                 IN VARCHAR2)
        IS
         l_api_version                CONSTANT NUMBER := 1;
         l_api_name      CONSTANT VARCHAR2(30) := 'resolveDeliverables';
         start_date_for_del date;
    -- update cursor for bug#4069955
     CURSOR del_cur IS
            SELECT *
                FROM  okc_deliverables del
                WHERE del.business_document_id = p_bus_doc_id
                AND   del.business_document_version = p_bus_doc_version
                AND   del.business_document_type = p_bus_doc_type
                AND   del.deliverable_status = 'INACTIVE'
                AND   del.actual_due_date is NULL
                AND   del.recurring_del_parent_id is NULL
                AND   (del.amendment_operation is NULL OR del.amendment_operation <> 'DELETED')
                AND   (del.summary_amend_operation_code is NULL OR del.summary_amend_operation_code <> 'DELETED')
                AND    del.deliverable_type in (select delTypes.deliverable_type_code from
                                                okc_bus_doc_types_b busDocTypes,
                                                okc_del_bus_doc_combxns delTypes
                                                WHERE busDocTypes.document_type = del.business_document_type
                                                AND   delTypes.document_type_class = busDocTypes.document_type_class
                                                AND   del.deliverable_type = delTypes.deliverable_type_code)
                AND (G_FALSE = p_cancel_flag OR ( del.RELATIVE_ST_DATE_EVENT_ID in
                                            (select docEvents.BUS_DOC_EVENT_ID
                                             from okc_bus_doc_events_b docEvents
                                             where docEvents.BUSINESS_EVENT_CODE = p_event_code
                                            ))
                     );
      del_rec  del_cur%ROWTYPE;

      CURSOR get_del_ids_cur (p_del_id IN NUMBER, p_actual_date IN DATE) IS
       SELECT deliverable_id FROM OKC_DELIVERABLES
         WHERE business_document_id = p_bus_doc_id
       AND   business_document_type = p_bus_doc_type
         AND   business_document_version = p_bus_doc_version
       AND   recurring_del_parent_id = p_del_id
       AND   TRUNC(actual_due_date) > TRUNC(p_actual_date);

      -- this cursor has been introduced to fix bug 3574466. The cursor
      -- collectes deliverable_id's of all the instances for given recurring
      -- deliverable
      CURSOR get_del_ids_cur2 (p_del_id IN NUMBER) IS
       SELECT deliverable_id FROM OKC_DELIVERABLES
         WHERE business_document_id = p_bus_doc_id
       AND   business_document_type = p_bus_doc_type
         AND   business_document_version = p_bus_doc_version
       AND   recurring_del_parent_id = p_del_id;

         -- for storage of bulk Fetch
         delRecTab OKC_DELIVERABLE_PROCESS_PVT.delRecTabType;

         -- for storage recurrign instances
         delInstanceRecTab OKC_DELIVERABLE_PROCESS_PVT.delRecTabType;

         TYPE DelIdList IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;
         deliverableIds DelIdList;
         TYPE DelDueDatetList IS TABLE OF DATE
         INDEX BY BINARY_INTEGER;
         deliverableDueDates DelDueDatetList;
         TYPE DelStartEventDateList IS TABLE OF DATE
         INDEX BY BINARY_INTEGER;
         deliverableStartEventDates DelStartEventDateList;
         TYPE DelEndEventDateList IS TABLE OF DATE
         INDEX BY BINARY_INTEGER;
         deliverableEndEventDates DelEndEventDateList;

         del_count PLS_INTEGER;
         j PLS_INTEGER;
         k PLS_INTEGER;
         l_actual_date DATE;
         l_recurr_start_date DATE;
         l_recurr_end_date DATE;

         l_repeat_day_of_month number;
         l_repeat_day_of_week number;

         l_has_instances_yn VARCHAR2(1);

         l_new_status OKC_DELIVERABLES.deliverable_status%TYPE;

         --- for deliverable ids
         delIds OKC_DELIVERABLE_PROCESS_PVT.delIdTabType;

         generate_new_instances_yn VARCHAR2(1);
         l_sync_flag VARCHAR2(1);
        BEGIN

      -- initialize
      del_count := 0;
      j := 0;
      k := 0;
      l_sync_flag := FND_API.G_FALSE;

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_resolve_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF FND_API.To_Boolean (p_sync_recurr_instances_flag) THEN
            l_sync_flag := FND_API.G_TRUE;
        ELSE
            l_sync_flag := p_sync_flag;
        END IF;


        --- open deliverables cursor and populate records of table
                FOR del_rec IN del_cur LOOP
                        k := k+1;
                        delRecTab(k).deliverable_id := del_rec.deliverable_id;
                        delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
                        delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
                        delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
                        delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
                        delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
                        delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
                        delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
                        delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
                        delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
                        delRecTab(k).COMMENTS:= del_rec.COMMENTS;
                        delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
                        delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
                        delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
                        delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
                        delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
                        delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
                        delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
                        delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
                        delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
                        delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
                        delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
                        delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
                        delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
                        delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
                        delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
                        delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
                        delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
                        delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
                        delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
                        delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
                        delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
                        delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
                        delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
                        delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
                        delRecTab(k).EXTERNAL_PARTY_ROLE:= del_rec.EXTERNAL_PARTY_ROLE;
                        delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
                        delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
                        delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
                        delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
                        delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
                        delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
                        delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
                        delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
                        delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
                        delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
                        delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
                        delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
                        delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
                        delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
                        delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
                        delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
                        delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
                        delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
                        delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
                        delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
                        delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
                        delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
                        delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
                        delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
                        delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
                        delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
                        delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
                        delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
                        delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
                        delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
                        delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
                        delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
                        delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
                        delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
                        delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
                        delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
                        delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
                        delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
                        delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
                        delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
                        delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
                        delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
                        delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
                        delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
                        delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
                        delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
                        delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
                        delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
                        delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
                        delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
                        delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;

                END LOOP;

            -- commented as this is not supported by 8i PL/SQL Bug#3307941
            /*OPEN del_cur;
            FETCH del_cur BULK COLLECT INTO delRecTab;*/

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Got Deliverables -- Count '||delRecTab.count);
        END IF;

              IF delRecTab.count > 0 THEN
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP

                    --- if deliverable is not recurring and start due date is FIXED
                    IF delRecTab(i).FIXED_DUE_DATE_YN = 'Y' THEN

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: Fixed Due Date Deliverable = '||delRecTab(i).deliverable_id);
                        END IF;

                        --- increment the count
                        del_count := del_count+1;

                        -- record the deliverable id to be updated at the end
                        deliverableIds(del_count) := delRecTab(i).deliverable_id;

                        -- set actual due date
                        deliverableDueDates(del_count) := delRecTab(i).fixed_start_date;

                        -- populate start event date as static date
                        deliverableStartEventDates(del_count) := delRecTab(i).fixed_start_date;
                        deliverableEndEventDates(del_count) := NULL;

                        -- check and create status history record for INACTIVE status
                        checkAndCreateStatusHistory(p_deliverable_id => delRecTab(i).deliverable_id,
                                                    p_deliverable_status => 'INACTIVE',
                                                    x_msg_data => x_msg_data,
                                                    x_msg_count => x_msg_count,
                                                    x_return_status => x_return_status);
                        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                            RAISE FND_API.G_EXC_ERROR ;
                        END IF;

                    END IF;  -- fixed due date is 'Yes'

                    -- if deliverable is recurring
                    IF delRecTab(i).recurring_yn = 'Y' THEN

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'103: Recurring Deliverable = '||delRecTab(i).deliverable_id);
                        END IF;

                        --- check if deliverable has recurring instances already in place
                        --- for given version of the document
                        l_has_instances_yn := hasInstances(
                                              p_bus_doc_id => p_bus_doc_id,
                                              p_bus_doc_type => p_bus_doc_type,
                                              p_bus_doc_version => p_bus_doc_version,
                                              p_del_id => delRecTab(i).deliverable_id);

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Recurring Deliverable, Has Instances = '||l_has_instances_yn);
                        END IF;

                        -- unexpected error
                        IF l_has_instances_yn is null THEN
                         Okc_Api.Set_Message(G_APP_NAME,
                                           'OKC_DEL_ERR_GET_INSTS');
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        -- by default this is N
                        generate_new_instances_yn := 'N';

                        --- if deliverable has recurring instances
                        IF l_has_instances_yn = 'Y' THEN

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105: Checking already exploded Recurring Deliverable = '||delRecTab(i).deliverable_id);
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105a: Check if deliverable is Amended = '||delRecTab(i).deliverable_id);
                            END IF;

                            --- check if amendment operation is (R)evised
/*                            IF ((delRecTab(i).amendment_operation is not null AND
                                delRecTab(i).amendment_operation = 'UPDATED') OR
                                (delRecTab(i).summary_amend_operation_code is not null AND
                                delRecTab(i).summary_amend_operation_code = 'UPDATED')) THEN */

                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'106: Recurring Definition = '||delRecTab(i).deliverable_id||' with Amendment Operation as '||delRecTab(i).amendment_operation);
                                END IF;

                                -- fix Bug 3574466: If sync flag is true, generate only the
                                -- delta instances.
                                IF FND_API.To_Boolean( l_sync_flag ) THEN

                                --- ASSUMPTION: In this case only end date can change
                                --- get old start date
                                l_recurr_start_date := delRecTab(i).start_event_date;

                                --- check if end date is not FIXED, it is relative
                                IF delRecTab(i).fixed_end_date is null THEN

                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'107: Recurring Definition = '||delRecTab(i).deliverable_id||' End Date is not Fixed ');
                                   END IF;

                                   --- initialize recurr end date
                                   l_recurr_end_date := null;

                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'107: Recurring Definition = '||delRecTab(i).deliverable_id||' Get Event Details ');
                                   END IF;

                                   -- to resolve relative end date check if due dates table is
                                   -- not empty
              /*--Commenting out as part of fix for bug 4030982--
                                   IF p_bus_doc_date_events_tbl.count = 0 THEN
                                     Okc_Api.Set_Message(G_APP_NAME,
                                                      'OKC_DEL_ERR_DTS_EMPY');
                                       RAISE FND_API.G_EXC_ERROR;
                                   END IF;
              */

                                   --- resolve relative end date
                                   l_recurr_end_date := resolveRelativeDueEvents(
                                       p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                       p_event_code => p_event_code,
                                       p_event_date => p_event_date,
                                       p_event_id => delRecTab(i).relative_end_date_event_id,
                                       p_event_UOM => delRecTab(i).relative_end_date_uom,
                                       p_event_duration => delRecTab(i).relative_end_date_duration,
                                       p_end_event_yn => 'Y');

                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Recurring end date '||l_recurr_end_date);
                                   END IF;

                                ELSE --- get the fixed end date, provided

                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' End Date is Fixed '||l_recurr_end_date);
                                    END IF;

                                    l_recurr_end_date := delRecTab(i).fixed_end_date;

                                END IF; --- End Date is Evaluated

                                -- By this time l_recurr_end_date should not be NULL
                                IF l_recurr_end_date is NULL  THEN
                                   Okc_Api.Set_Message(G_APP_NAME,
                                                    'OKC_DEL_END_DT_NOT_FOUND');
                                    RAISE FND_API.G_EXC_ERROR;
                                END IF;

                                --- check if new date is less then old date
                                --- delete instances where actual date is equal to or
                                --- greater then new date

                                IF TRUNC(l_recurr_end_date) < TRUNC(delRecTab(i).end_event_date) THEN

                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' New end Date is LESS then OLD End Date '||l_recurr_end_date);
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Hence Delete Remaining Instances '||l_recurr_end_date);
                                   END IF;

                                   --- hard Delete old instances from current version
                                   OPEN get_del_ids_cur(delRecTab(i).deliverable_id, l_recurr_end_date);
                                   FETCH get_del_ids_cur BULK COLLECT INTO delIds;
                                   CLOSE get_del_ids_cur;

                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Calling OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances for count '||delIds.count);
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Calling OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances '||x_return_status);
                                   END IF;

                                   -- if there are any deliverable instances to be deleted
                                   IF delIds.count > 0 THEN
                                       --- call delete_del_instances or OKC_DELIVERABLE_PROCESS_PVT
                                       OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances(
                                               p_api_version  => l_api_version,
                                               p_init_msg_list => G_FALSE,
                                               p_doc_id    => p_bus_doc_id,
                                               p_doc_type  => p_bus_doc_type,
                                               p_doc_version => p_bus_doc_version,
                    p_Conditional_Delete_Flag => 'Y',
                                               p_delid_tab => delIds,
                                               x_msg_data   => x_msg_data,
                                               x_msg_count  => x_msg_count,
                                               x_return_status  => x_return_status);

                                         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                             ,'108: Recurring Definition = '||delRecTab(i).deliverable_id||
                                             ' Finished delete_del_instances for count '||delIds.count);
                                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                             ,'108: Recurring Definition = '||delRecTab(i).deliverable_id||
                                             ' Finished OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances '
                                             ||x_return_status);
                                         END IF;

                                         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                                         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                                            RAISE FND_API.G_EXC_ERROR ;
                                         END IF;

                                         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                            ,'108: Recurring Definition = '||delRecTab(i).deliverable_id||
                                            ' Updating Definition ');
                                         END IF;
                                     END IF; -- delIds count  > 0
                                     --- increment the count
                                     del_count := del_count+1;

                                 -- record deliverable id to be updated at the end
                                     deliverableIds(del_count) := delRecTab(i).deliverable_id;

                         -- record actual date, start event date and end event date
                                     deliverableDueDates(del_count) := NULL;
                                     deliverableStartEventDates(del_count) := delRecTab(i).start_event_date;
                                     deliverableEndEventDates(del_count) := l_recurr_end_date;

                                END IF; -- New end date is LESS

                                --- check if new date is greater then old date
                                --- generate new instances with start date as old end date
                                --- and end date as new end date, us the same repeat frequency on
                                --- the given deliverable and resolve it.
                                IF TRUNC(l_recurr_end_date) > TRUNC(delRecTab(i).end_event_date) THEN

                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' New end Date is GREATER then OLD End Date '||l_recurr_end_date);
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Hence create new Instances '||l_recurr_end_date);
                                     END IF;

                                    --- get the repeat frequency and create new instances
                                    l_repeat_day_of_month := getDayOfMonth(
                                                             delRecTab(i).repeating_day_of_month);
                                    l_repeat_day_of_week  := getDayOfWeek(
                                                              delRecTab(i).repeating_day_of_week);

                                    --- check the status of exiting instances
                                    l_new_status :=
                                               checkStatusOfExistingInstances(
                                                   p_bus_doc_id => p_bus_doc_id,
                                                   p_bus_doc_type => p_bus_doc_type,
                                                   p_bus_doc_version => p_bus_doc_version,
                                                   p_del_id => delRecTab(i).deliverable_id);
                                     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Got new Status '||l_new_status);
                                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Calling generate_del_instances ');
                                     END IF;

                                     -- generate recurring instances for
                                     -- given deliverable definition id
                                                                        ---


                                ---Calculate the correct DATE here


                                SELECT Add_Months(delRecTab(i).FIXED_START_DATE,Trunc( Months_Between(delRecTab(i).end_event_date,delRecTab(i).FIXED_START_DATE)/12)*12 ) INTO start_date_for_del FROM dual;



                                     generate_del_instances(
                                                 p_recurr_start_date => (start_date_for_del),
                                                 p_recurr_end_date => l_recurr_end_date,
                                                 p_repeat_duration => delRecTab(i).repeating_duration,
                                                 p_repeat_day_of_month => l_repeat_day_of_month,
                                                 p_repeat_day_of_week => l_repeat_day_of_week,
                                                 delRecord => delRecTab(i),
                                                 p_change_status_to => l_new_status);

                                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Finished generate_del_instances ');
                                      END IF;
                                      ----- Done Creating new deliverable instances ---

                                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Updating Definition ');
                                      END IF;

                                      --- increment the count
                                      del_count := del_count+1;

                                  -- record deliverable id to be updated at the end
                                      deliverableIds(del_count) := delRecTab(i).deliverable_id;

                         -- record actual date, start event date and end event date
                                      deliverableDueDates(del_count) := NULL;
                                      deliverableEndEventDates(del_count) := l_recurr_end_date;
                                      deliverableStartEventDates(del_count) := delRecTab(i).start_event_date;

                                END IF; --- New End date is GREATER
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Finished generate_del_instances ');
                                END IF;

                                ELSE -- if sync flag is NOT true
                                    -- delete existing instances and re-generate new
                                    -- instances

                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1080: Recurring Definition = '||delRecTab(i).deliverable_id||' As Sync Flag is N, Deleting existing instances ');
                                   END IF;

                                   --- hard Delete old instances from current version
                                   OPEN get_del_ids_cur2(delRecTab(i).deliverable_id);
                                   FETCH get_del_ids_cur2 BULK COLLECT INTO delIds;
                                   CLOSE get_del_ids_cur2;

                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                       ,'1081: Recurring Definition = '||delRecTab(i).deliverable_id||
                                       ' Calling OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances for count '
                                       ||delIds.count);
                                   END IF;

                                   -- if there are any deliverable instances to be deleted
                                   IF delIds.count > 0 THEN
                                       --- call delete_del_instances or OKC_DELIVERABLE_PROCESS_PVT
                                       OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances(
                                               p_api_version  => l_api_version,
                                               p_init_msg_list => G_FALSE,
                                               p_doc_id    => p_bus_doc_id,
                                               p_doc_type  => p_bus_doc_type,
                                               p_doc_version => p_bus_doc_version,
                    p_Conditional_Delete_Flag => 'N',
                                               p_delid_tab => delIds,
                                               x_msg_data   => x_msg_data,
                                               x_msg_count  => x_msg_count,
                                               x_return_status  => x_return_status);

                                         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                                         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                                            RAISE FND_API.G_EXC_ERROR ;
                                         END IF;

                                         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                             ,'108: Recurring Definition = '||delRecTab(i).deliverable_id||
                                             ' Finished OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances for count '||delIds.count);
                                         END IF;
                                    END IF;
                                    -- set the flag to generate new instances
                                    generate_new_instances_yn := 'Y';
                                END IF;
--                            END IF; --- check if amendment operation is (R)evised
                        END IF; -- hasInstances

                        --- recurring deliverable is newly created or instances are deleted
                        IF l_has_instances_yn ='N' OR generate_new_instances_yn = 'Y' THEN

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' New Recurring Definition ');
                            END IF;

                             --- get start date, if relative to an event, evaluate it
                            --- check if start event id is populated, if yes evaluate the start
                            --- date or actual date.
                            IF delRecTab(i).RELATIVE_ST_DATE_EVENT_ID is not null THEN

                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Start date is Relative ');
                                END IF;

                                l_recurr_start_date := NULL;

                                --- resolve relative end date
                                l_recurr_start_date := resolveRelativeDueEvents(
                                       p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                       p_event_code => p_event_code,
                                       p_event_date => p_event_date,
                                       p_event_id => delRecTab(i).relative_st_date_event_id,
                                       p_event_UOM => delRecTab(i).relative_st_date_uom,
                                       p_event_duration => delRecTab(i).relative_st_date_duration,
                                       p_end_event_yn => 'N');

                            ELSE --- start date is Fixed

                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Start date is fixed '||delRecTab(i).fixed_start_date);
                                END IF;

                                -- start date is FIXED
                                l_recurr_start_date := delRecTab(i).fixed_start_date;

                                -- By this time l_recurr_start_date should not be NULL
                                IF l_recurr_start_date is NULL  THEN
                                   Okc_Api.Set_Message(G_APP_NAME,
                                                    'OKC_DEL_ST_DT_NOT_FOUND');
                                    RAISE FND_API.G_EXC_ERROR;
                                END IF;
                            END IF; --- Start date resolved

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Start date is resolved  Now resolve End Date');
                            END IF;

                         --- if recurring start date is resolved, only in that case
                         --- go further, resolve end date and generate instances
                         IF l_recurr_start_date is not NULL THEN

                            --- get the end date
                            --- check if end date is fixed
                            IF delRecTab(i).fixed_end_date is not null THEN

                               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' End Date is Fixed'||delRecTab(i).fixed_end_date);
                               END IF;

                               -- recurring end date is FIXED
                               l_recurr_end_date := delRecTab(i).fixed_end_date;

                             ELSE --- is not fixed, resolve if relative

                                  --- initialize
                                  l_recurr_end_date := NULL;

                                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' End Date is Relative');
                                  END IF;

                                  --- resolve relative end date
                                  l_recurr_end_date := resolveRelativeDueEvents(
                                       p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                       p_event_code => p_event_code,
                                       p_event_date => p_event_date,
                                       p_event_id => delRecTab(i).relative_end_date_event_id,
                                       p_event_UOM => delRecTab(i).relative_end_date_uom,
                                       p_event_duration => delRecTab(i).relative_end_date_duration,
                                       p_end_event_yn => 'Y');

                            END IF; --- get the end date

                            IF l_recurr_end_date is NULL THEN
                               Okc_Api.Set_Message(G_APP_NAME,
                                            'OKC_DEL_END_DT_NOT_FOUND');
                                RAISE FND_API.G_EXC_ERROR;
                             END IF;

                             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Get Recurring Frequency ');
                             END IF;

                             l_repeat_day_of_month := getDayOfMonth(
                                                  delRecTab(i).REPEATING_DAY_OF_MONTH);
                             l_repeat_day_of_week  := getDayOfWeek(
                                                  delRecTab(i).REPEATING_DAY_OF_WEEK);

                             -- if both frequency values ar null
                             IF (l_repeat_day_of_month is NULL AND l_repeat_day_of_week is NULL) THEN
                                 Okc_Api.Set_Message(G_APP_NAME,
                                      'OKC_DEL_RECUR_FRQ_NOT_FOUND');
                                    RAISE FND_API.G_EXC_ERROR;
                             END IF;

                             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Generate Instances ');
                             END IF;

                             -- generate recurring instances
                             generate_del_instances(
                                                  p_recurr_start_date => l_recurr_start_date,
                                                  p_recurr_end_date => l_recurr_end_date,
                                                  p_repeat_duration => delRecTab(i).repeating_duration,
                                                  p_repeat_day_of_month => l_repeat_day_of_month,
                                                  p_repeat_day_of_week => l_repeat_day_of_week,
                                                  delRecord => delRecTab(i),
                                                  p_change_status_to => NULL);

                              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Recurring Definition = '||delRecTab(i).deliverable_id||' Updating definition ');
                              END IF;

                              --- increment the count
                              del_count := del_count+1;

                            -- record deliverable id to be updated at the end
                              deliverableIds(del_count) := delRecTab(i).deliverable_id;

                  -- record actual date, start event date and end event date
                              deliverableDueDates(del_count) := NULL;
                              deliverableStartEventDates(del_count) := l_recurr_start_date;
                              deliverableEndEventDates(del_count) := l_recurr_end_date;

                         END IF; --- if recurring start date is resolved

                       END IF; --- recurring deliverable is newly created or instances are deleted

                     ELSE -- if not Recurring, deliverable is one time with relative start event

                        --- check if start event id is populated, if yes evaluate the start
                        --- date or actual date.
                  l_actual_date := NULL;
                        IF delRecTab(i).RELATIVE_ST_DATE_EVENT_ID is not null THEN

                           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'110:Deliverable is One Time ');
                           END IF;

              -- check and create status history record for INACTIVE status
              checkAndCreateStatusHistory(p_deliverable_id => delRecTab(i).deliverable_id,
                            p_deliverable_status => 'INACTIVE',
                            x_msg_data => x_msg_data,
                            x_msg_count => x_msg_count,
                            x_return_status => x_return_status);
              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
              END IF;


                           --- resolve relative end date
                           l_actual_date := resolveRelativeDueEvents(
                                       p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                       p_event_code => p_event_code,
                                       p_event_date => p_event_date,
                                       p_event_id => delRecTab(i).relative_st_date_event_id,
                                       p_event_UOM => delRecTab(i).relative_st_date_uom,
                                       p_event_duration => delRecTab(i).relative_st_date_duration,
                                       p_end_event_yn => 'N');
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'113: Updating Definition');
                            END IF;

                            --- if actual date is resolved
                            IF l_actual_date is not NULL THEN

                                --- increment the count
                                del_count := del_count+1;

                                -- record deliverable id to be updated at the end
                                deliverableIds(del_count) := delRecTab(i).deliverable_id;

                  -- record actual date, start event date and end event date
                                deliverableDueDates(del_count) :=l_actual_date;
                                deliverableStartEventDates(del_count) := l_actual_date;
                                deliverableEndEventDates(del_count) := NULL;
                            END IF;
                        END IF; --- deliverable with Start due date event
                    END IF;
                END LOOP;
              END IF;

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'113: Buld update started');
              END IF;


              --- bulk update for deliverables actual due date
              IF deliverableIds.count > 0 THEN
         FORALL i IN deliverableIds.FIRST..deliverableIds.LAST
          UPDATE okc_deliverables
          SET
          actual_due_date = deliverableDueDates(i),
          start_event_date = deliverableStartEventDates(i),
          end_event_date = deliverableEndEventDates(i),
          last_updated_by= Fnd_Global.User_Id,
          last_update_date = sysdate,
          last_update_login = Fnd_Global.Login_Id
          WHERE deliverable_id = deliverableIds(i);
               END IF;
                  IF del_cur %ISOPEN THEN
                     CLOSE del_cur ;
                  END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving resolveDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving resolveDeliverables Unexpected ERROR');
     END IF;
     IF del_cur %ISOPEN THEN
        CLOSE del_cur ;
     END IF;
     IF get_del_ids_cur %ISOPEN THEN
        CLOSE get_del_ids_cur;
     END IF;

     ROLLBACK TO g_resolve_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving resolveDeliverables Unexpected ERROR');
     END IF;
     IF del_cur %ISOPEN THEN
        CLOSE del_cur ;
     END IF;
     IF get_del_ids_cur %ISOPEN THEN
        CLOSE get_del_ids_cur;
     END IF;

     ROLLBACK TO g_resolve_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving resolveDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    IF del_cur %ISOPEN THEN
       CLOSE del_cur ;
    END IF;
     IF get_del_ids_cur %ISOPEN THEN
        CLOSE get_del_ids_cur;
     END IF;

    ROLLBACK TO g_resolve_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- resolveDeliverables

   /**
    * Update deliverables, re-resolve deliverables for the dates passed by
    * bus doc api, assumed to be changed.
    */
   PROCEDURE updateDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_bus_doc_date_events_tbl IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
    IS

       --- Define cursor to fetch already resolved deliverables
    -- update cursor for bug#4069955
    -- Updated the cusror bug 5018624
       CURSOR del_cur IS
        SELECT  *
        FROM    okc_deliverables del
        WHERE business_document_id = p_bus_doc_id
        AND   business_document_type = p_bus_doc_type
        AND   business_document_version = p_bus_doc_version
        AND   (
              (fixed_due_date_yn = 'N'
        AND    (amendment_operation is NULL OR amendment_operation <> 'DELETED')
	AND    (summary_amend_operation_code is NULL OR summary_amend_operation_code <> 'DELETED')
        AND    recurring_YN ='N'
        AND    actual_due_date is not null
        AND    recurring_del_parent_id is null)
              OR
              (recurring_YN = 'Y'
        AND    recurring_del_parent_id is null
        AND    del.deliverable_type in ( select d.deliverable_type_code
                                         from okc_bus_doc_types_b bd,
                                              okc_del_bus_doc_combxns d
                                         WHERE bd.document_type = del.business_document_type
                                         AND d.document_type_class = bd.document_type_class
                                         AND del.deliverable_type = d.deliverable_type_code ))
              );
       del_rec   del_cur%ROWTYPE;
       k   PLS_INTEGER;
      CURSOR get_del_ids_cur1 (p_del_id IN NUMBER) IS
       SELECT deliverable_id FROM OKC_DELIVERABLES
         WHERE business_document_id = p_bus_doc_id
       AND   business_document_type = p_bus_doc_type
         AND   business_document_version = p_bus_doc_version
       AND   recurring_del_parent_id = p_del_id;

      CURSOR get_del_ids_cur2 (p_del_id IN NUMBER, p_actual_date IN DATE) IS
       SELECT deliverable_id FROM OKC_DELIVERABLES
         WHERE business_document_id = p_bus_doc_id
       AND   business_document_type = p_bus_doc_type
         AND   business_document_version = p_bus_doc_version
       AND   recurring_del_parent_id = p_del_id
       AND   TRUNC(actual_due_date) > TRUNC(p_actual_date);

       --- for deliverable ids
       delIds OKC_DELIVERABLE_PROCESS_PVT.delIdTabType;

       TYPE DelIdList IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
       deliverableIds DelIdList;
       TYPE DelDueDatetList IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;
       deliverableDueDates DelDueDatetList;
       TYPE DelStartEventDateList IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;
       deliverableStartEventDates DelStartEventDateList;
       TYPE DelEndEventDateList IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;
       deliverableEndEventDates DelEndEventDateList;

       del_count PLS_INTEGER;

       l_api_name      CONSTANT VARCHAR2(30) := 'updateDeliverables';
       l_api_version     CONSTANT VARCHAR2(30) := 1;

       -- for storage of bulk Fetch
       delRecTab OKC_DELIVERABLE_PROCESS_PVT.delRecTabType;

       -- for storage recurrign instances
       delInstanceRecTab OKC_DELIVERABLE_PROCESS_PVT.delRecTabType;

       l_del_event_name OKC_BUS_DOC_EVENTS_B.business_event_code%TYPE;
       l_del_before_after OKC_BUS_DOC_EVENTS_B.before_after%TYPE;
       l_actual_date DATE;
       l_recurr_end_date DATE;

       l_repeat_day_of_month number;
       l_repeat_day_of_week number;

       l_new_status OKC_DELIVERABLES.deliverable_status%TYPE;
       l_has_instances_yn VARCHAR2(1);

    BEGIN
      -- initialize
      k := 0;
      del_count := 0;
      l_actual_date := null;
      l_recurr_end_date := null;

      --- if any dates have been changed on given business document, and
      --- selected deliverables are effected, re-resolve due dates and
      --- and carry forward statuses

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;
        -- Standard Start of API savepoint
        SAVEPOINT g_update_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --- open deliverables cursor and populate records of table
                FOR del_rec IN del_cur LOOP
                        k := k+1;
                        delRecTab(k).deliverable_id := del_rec.deliverable_id;
                        delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
                        delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
                        delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
                        delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
                        delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
                        delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
                        delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
                        delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
                        delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
                        delRecTab(k).COMMENTS:= del_rec.COMMENTS;
                        delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
                        delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
                        delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
                        delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
                        delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
                        delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
                        delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
                        delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
                        delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
                        delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
                        delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
                        delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
                        delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
                        delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
                        delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
                        delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
                        delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
                        delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
                        delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
                        delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
                        delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
                        delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
                        delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
                        delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
                        delRecTab(k).EXTERNAL_PARTY_ROLE:= del_rec.EXTERNAL_PARTY_ROLE;
                        delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
                        delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
                        delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
                        delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
                        delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
                        delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
                        delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
                        delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
                        delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
                        delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
                        delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
                        delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
                        delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
                        delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
                        delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
                        delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
                        delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
                        delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
                        delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
                        delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
                        delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
                        delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
                        delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
                        delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
                        delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
                        delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
                        delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
                        delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
                        delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
                        delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
                        delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
                        delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
                        delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
                        delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
                        delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
                        delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
                        delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
                        delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
                        delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
                        delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
                        delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
                        delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
                        delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
                        delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
                        delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
                        delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
                        delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
                        delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
                        delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
                        delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
                        delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;

                END LOOP;

            -- commented as this is not supported by 8i PL/SQL Bug#3307941
            /*OPEN del_cur;
            FETCH del_cur BULK COLLECT INTO delRecTab;*/


        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Got Deliverables records --- Count'||delRecTab.count);
        END IF;

        IF delRecTab.count > 0 THEN

            FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP

              -- if there's no fixed start date, evaluate relative start date
              IF delRecTab(i).fixed_start_date is null THEN

                  -- start procedure
                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: Deliverable = '||delRecTab(i).deliverable_id||' is Not Fixed');
                  END IF;

                  --- initialize start date as NULL
                  l_actual_date := NULL;

                  --- if start date is relative, resolve the actual date
                  IF delRecTab(i).RELATIVE_ST_DATE_EVENT_ID is not NULL THEN

                      -- start procedure
                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: Deliverable = '||delRecTab(i).deliverable_id||' is Relative ');
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'103: Deliverable = '||delRecTab(i).deliverable_id||' Resolve Due Date Event ');
                      END IF;

                      --- resolve relative end date
                      l_actual_date := resolveRelativeDueEvents(
                                   p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                   p_event_code => NULL,
                                   p_event_date => NULL,
                                   p_event_id => delRecTab(i).relative_st_date_event_id,
                                   p_event_UOM => delRecTab(i).relative_st_date_uom,
                                   p_event_duration => delRecTab(i).relative_st_date_duration,
                                   p_end_event_yn => 'N');
                       -- start procedure
                       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Deliverable = '||delRecTab(i).deliverable_id||' Got actual date as '||l_actual_date);
                       END IF;

                       --- here if start date is not resolved, means there's not change
                       --- in start event date, so take the old start event date
                       IF l_actual_date is NULL THEN

               -- start procedure
                         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Deliverable = '||delRecTab(i).deliverable_id||' Get Start Event Date '||delRecTab(i).start_event_date);
                           END IF;

                 --- if Fixed start date
                           l_actual_date := delRecTab(i).start_event_date;

                       END IF;
          END IF; -- if start date is relative

                ELSE -- if start date is fixed

                  --- initialize start date as NULL
                  l_actual_date := NULL;

                    -- start procedure
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Deliverable = '||delRecTab(i).deliverable_id||' Setting as START event Date ');
                    END IF;

                    --- if Fixed start date
                    l_actual_date := delRecTab(i).fixed_start_date;

                END IF;

          --- If deliverable is One Time
            IF delRecTab(i).recurring_yn = 'N' THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105: Deliverable = '||delRecTab(i).deliverable_id||' IS one time ');
                END IF;

                --- if resolved start date is not null, check if it is different
                ---  from old start date
        IF l_actual_date is not NULL THEN

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105: Deliverable = '||delRecTab(i).deliverable_id||' Actual date is not NULL '||l_actual_date);
                  END IF;
                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105a: Deliverable = '||delRecTab(i).deliverable_id||' Event date is  '||delRecTab(i).start_event_date);
                  END IF;

                  IF TRUNC(l_actual_date) <> TRUNC(delRecTab(i).start_event_date) THEN

                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'106: Deliverable = '||delRecTab(i).deliverable_id||' Actual date DOES not match existing start event date '||l_actual_date);
                      END IF;

                      --- increment the count
                      del_count := del_count+1;

                -- record deliverable id to be updated at the end
              deliverableIds(del_count) := delRecTab(i).deliverable_id;

              -- record actual date, start event date and end event date
              deliverableDueDates(del_count) := l_actual_date;
              deliverableStartEventDates(del_count) := l_actual_date;
              deliverableEndEventDates(del_count) := NULL;
                   END IF; -- if resolved date is different then old resolved date

                 END IF; -- if resolved date is not null

            ELSE --- if deliverable is recurring

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Deliverable = '||delRecTab(i).deliverable_id||' is Recurring ');
                    END IF;

                    --- check if deliverable has recurring instances already in place
                    --- for given version of the document
                    l_has_instances_yn := hasInstances(
                                              p_bus_doc_id => p_bus_doc_id,
                                              p_bus_doc_type => p_bus_doc_type,
                                              p_bus_doc_version => p_bus_doc_version,
                                              p_del_id => delRecTab(i).deliverable_id);

                     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Recurring Deliverable, Has Instances = '||l_has_instances_yn);
                     END IF;

                IF l_has_instances_yn = 'Y' THEN

                   --- check the status of exiting instances
                   l_new_status :=
                                checkStatusOfExistingInstances(
                                    p_bus_doc_id => p_bus_doc_id,
                                    p_bus_doc_type => p_bus_doc_type,
                                    p_bus_doc_version => p_bus_doc_version,
                                    p_del_id => delRecTab(i).deliverable_id);

            --- Start date is changed, Re-resolve the deliverable completely.
            IF (l_actual_date is not NULL) AND (TRUNC(l_actual_date) <> TRUNC(delRecTab(i).start_event_date)) THEN

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'109: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Start date is changed -- new '||l_actual_date);
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'110: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Start date is changed -- OLD '||delRecTab(i).start_event_date);
                        END IF;

                        OPEN get_del_ids_cur1(delRecTab(i).deliverable_id);
                        FETCH get_del_ids_cur1 BULK COLLECT INTO delIds;
                        CLOSE get_del_ids_cur1;

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'111: Recurring Deliverable = '||delRecTab(i).deliverable_id||' instances to be Deleted Calling OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances');
                        END IF;

                        IF delIds.count > 0 THEN
                            --- call delete_del_instances or OKC_DELIVERABLE_PROCESS_PVT
                  OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances(
                     p_api_version  => l_api_version,
                   p_init_msg_list => G_FALSE,
                   p_doc_id    => p_bus_doc_id,
                   p_doc_type  => p_bus_doc_type,
                   p_doc_version => p_bus_doc_version,
                   p_Conditional_Delete_Flag => 'Y',
                   p_delid_tab => delIds,
                   x_msg_data   => x_msg_data,
                   x_msg_count  => x_msg_count,
                   x_return_status  => x_return_status);

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'112: Recurring Deliverable = '||delRecTab(i).deliverable_id||' FINISHED OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances'||x_return_status);
                            END IF;
                            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                                 RAISE FND_API.G_EXC_ERROR ;
                            END IF;
                         END IF; -- end delIds > 0
               --- re-resolve the deliverable
               --- you have the start date.
               --- get end date, either fixed or relative
                         l_recurr_end_date := null;
               IF delRecTab(i).fixed_end_date is not null THEN

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'112: Recurring Deliverable = '||delRecTab(i).deliverable_id||' End date is Fixed'||delRecTab(i).fixed_end_date);
                            END IF;

                            --- set the end date as fixed end date
                l_recurr_end_date := delRecTab(i).fixed_end_date;

                   ELSE -- end date is relative

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'113: Recurring Deliverable = '||delRecTab(i).deliverable_id||' End date is Relative, Resolve end data');
                            END IF;

                             --- resolve relative end date
                             l_recurr_end_date := resolveRelativeDueEvents(
                                   p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                   p_event_code => NULL,
                                   p_event_date => NULL,
                                   p_event_id => delRecTab(i).relative_end_date_event_id,
                                   p_event_UOM => delRecTab(i).relative_end_date_uom,
                                   p_event_duration => delRecTab(i).relative_end_date_duration,
                                   p_end_event_yn => 'Y');

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'114: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Resolved End date '||l_recurr_end_date);
                            END IF;

                 END IF;

                         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'115: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Resolved End date '||l_recurr_end_date);
                         END IF;

                         --- if resolved end date comes out to be NULL, take the
                         --- old end event date
                        IF l_recurr_end_date is NULL THEN

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'115: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Getting End Event Date '||delRecTab(i).end_event_date);
                            END IF;

                            --- set the end date as fixed end date
                l_recurr_end_date := delRecTab(i).end_event_date;

                        END IF;

                         --- raise exception if END is NULL
                         IF l_recurr_end_date is NULL THEN
                                   Okc_Api.Set_Message(G_APP_NAME,
                                    'OKC_DEL_END_DT_NOT_FOUND');
                                   RAISE FND_API.G_EXC_ERROR;
                         END IF;


               --- get the repeat frequency and create new instances
               l_repeat_day_of_month := getDayOfMonth(
                      delRecTab(i).REPEATING_DAY_OF_MONTH);
               l_repeat_day_of_week  := getDayOfWeek(
                      delRecTab(i).REPEATING_DAY_OF_WEEK);

                         -- if both frequency values ar null
                         IF (l_repeat_day_of_month is NULL AND l_repeat_day_of_week is NULL) THEN
                                 Okc_Api.Set_Message(G_APP_NAME,
                                      'OKC_DEL_RECUR_FRQ_NOT_FOUND');
                                    RAISE FND_API.G_EXC_ERROR;
                         END IF;

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'116: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Calling generated instances');
                        END IF;

                         -- generate recurring instances
                         generate_del_instances(
                                             p_recurr_start_date => l_actual_date,
                                             p_recurr_end_date => l_recurr_end_date,
                                             p_repeat_duration => delRecTab(i).repeating_duration,
                                             p_repeat_day_of_month => l_repeat_day_of_month,
                                             p_repeat_day_of_week => l_repeat_day_of_week,
                                             delRecord => delRecTab(i),
                                             p_change_status_to => l_new_status);

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'117: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Done generating instances');
                        END IF;

                         --- increment the count
                         del_count := del_count+1;

               -- record deliverable id to be updated at the end
               deliverableIds(del_count) := delRecTab(i).deliverable_id;

               -- record actual date, start event date and end event date
               deliverableDueDates(del_count) := NULL;
               deliverableStartEventDates(del_count) := l_actual_date;
               deliverableEndEventDates(del_count) := l_recurr_end_date;

           ELSE --- if start date is not changed

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'118: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Start date is not changed');
                    END IF;

                    -- initialize recurring end date
              l_recurr_end_date := null;

              --- check if end date is not FIXED, if it is Fixed, no more
            --- further operation.
            IF delRecTab(i).fixed_end_date is null THEN

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'119: Recurring Deliverable = '||delRecTab(i).deliverable_id||' End date is relative, resolve end date');
                        END IF;

                        --- resolve relative end date
                        l_recurr_end_date := resolveRelativeDueEvents(
                                   p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                   p_event_code => NULL,
                                   p_event_date => NULL,
                                   p_event_id => delRecTab(i).relative_end_date_event_id,
                                   p_event_UOM => delRecTab(i).relative_end_date_uom,
                                   p_event_duration => delRecTab(i).relative_end_date_duration,
                                   p_end_event_yn => 'Y');

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'120: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Resolved end date '||l_recurr_end_date);
                        END IF;

               ELSE --- get the fixed end date, provided

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'121: Recurring Deliverable = '||delRecTab(i).deliverable_id||' Take Fixed End date  '||delRecTab(i).fixed_end_date);
                        END IF;

                        -- set the fixed end date
                l_recurr_end_date := delRecTab(i).fixed_end_date;

                     END IF;

                     --- raise exception if END is NULL
/*                     IF l_recurr_end_date is NULL THEN
                               Okc_Api.Set_Message(G_APP_NAME,
                                'OKC_DEL_END_DT_NOT_FOUND');
                               RAISE FND_API.G_EXC_ERROR;
                     END IF; */

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'121a: new end date = '||l_recurr_end_date||' Old end date  '||delRecTab(i).end_event_date);
                        END IF;

             --- check if new date is less then old date
                   --- delete instances where actual date is equal to or
             --- greater then new date

             IF (l_recurr_end_date is not NULL) AND (TRUNC(l_recurr_end_date) < TRUNC(delRecTab(i).end_event_date)) THEN

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'122: Recurring Deliverable = '||delRecTab(i).deliverable_id||'New End Date is less then old end date');
                        END IF;

                --- hard Delete old instances from current version
                        OPEN get_del_ids_cur2(delRecTab(i).deliverable_id, l_recurr_end_date);
                        FETCH get_del_ids_cur2 BULK COLLECT INTO delIds;
                        CLOSE get_del_ids_cur2;

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'123: Recurring Deliverable = '||delRecTab(i).deliverable_id||'Calling OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances');
                        END IF;

                        IF delIds.count > 0 THEN
                    --- call delete_del_instances or OKC_DELIVERABLE_PROCESS_PVT
                OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances(
                 p_api_version  => l_api_version,
                 p_init_msg_list => G_FALSE,
                 p_doc_id    => p_bus_doc_id,
                 p_doc_type  => p_bus_doc_type,
                 p_doc_version => p_bus_doc_version,
                 p_Conditional_Delete_Flag => 'Y',
                 p_delid_tab => delIds,
                   x_msg_data   => x_msg_data,
                 x_msg_count  => x_msg_count,
                 x_return_status  => x_return_status);

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'124: Recurring Deliverable = '||delRecTab(i).deliverable_id||'Finished OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances'||x_return_status);
                            END IF;
                            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                                 RAISE FND_API.G_EXC_ERROR ;
                            END IF;

                         END IF;
                            --- increment the count
                            del_count := del_count+1;

               ----- Done Creating new deliverable instances ---
               --- update current deliverable definition with start and end event date
                   -- record deliverable id to be updated at the end
              deliverableIds(del_count) := delRecTab(i).deliverable_id;

              -- record actual date, start event date and end event date
              deliverableDueDates(del_count) := NULL;
              deliverableStartEventDates(del_count) := delRecTab(i).start_event_date;
              deliverableEndEventDates(del_count) := l_recurr_end_date;

            END IF;

            --- check if new date is greater then old date
            --- generate new instances with start date as old end date
              --- and end date as new end date, us the same repeat frequency on
            --- the given deliverable and resolve it.
            IF (l_recurr_end_date is not NULL) AND TRUNC(l_recurr_end_date) > TRUNC(delRecTab(i).end_event_date) THEN

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'125: Recurring Deliverable = '||delRecTab(i).deliverable_id||'New end date is greater then old end dates');
                        END IF;

             --- get the repeat frequency and create new instances
                   l_repeat_day_of_month := getDayOfMonth(
                        delRecTab(i).REPEATING_DAY_OF_MONTH);
             l_repeat_day_of_week  := getDayOfWeek(
                        delRecTab(i).REPEATING_DAY_OF_WEEK);

                         -- if both frequency values ar null
                         IF (l_repeat_day_of_month is NULL AND l_repeat_day_of_week is NULL) THEN
                                 Okc_Api.Set_Message(G_APP_NAME,
                                      'OKC_DEL_RECUR_FRQ_NOT_FOUND');
                                    RAISE FND_API.G_EXC_ERROR;
                         END IF;

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'126: Recurring Deliverable = '||delRecTab(i).deliverable_id||'Calling generate_del_instances');
                        END IF;
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'126a: Recurring Deliverable = '||delRecTab(i).deliverable_id||'Setting Status'||l_new_status);
                        END IF;

                        -- generate delta of recurring instances
                        generate_del_instances(
                                             p_recurr_start_date => delRecTab(i).end_event_date+1,
                                             p_recurr_end_date => l_recurr_end_date,
                                             p_repeat_duration => delRecTab(i).repeating_duration,
                                             p_repeat_day_of_month => l_repeat_day_of_month,
                                             p_repeat_day_of_week => l_repeat_day_of_week,
                                             delRecord => delRecTab(i),
                                             p_change_status_to => l_new_status);

                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'127: Recurring Deliverable = '||delRecTab(i).deliverable_id||'Done generate_del_instances');
                            END IF;

                            --- increment the count
                            del_count := del_count+1;

               ----- Done Creating new deliverable instances ---
               --- update current deliverable definition with start and end event date
                   -- record deliverable id to be updated at the end
              deliverableIds(del_count) := delRecTab(i).deliverable_id;

              -- record actual date, start event date and end event date
              deliverableDueDates(del_count) := NULL;
              deliverableStartEventDates(del_count) := delRecTab(i).start_event_date;
              deliverableEndEventDates(del_count) := l_recurr_end_date;
             END IF; -- if new end date is greater then old end date
           END IF; -- if start date is not changed
             END IF;
       END IF; -- if deliverables is recurring or not

       END LOOP;
     END IF;

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'128: Bulk Update Started');
          END IF;

          IF deliverableIds.count > 0 THEN
        --- bulk update for deliverables actual due date
       FORALL i IN deliverableIds.FIRST..deliverableIds.LAST
        UPDATE okc_deliverables
        SET
        actual_due_date = deliverableDueDates(i),
        start_event_date = deliverableStartEventDates(i),
        end_event_date = deliverableEndEventDates(i),
        last_updated_by= Fnd_Global.User_Id,
        last_update_date = sysdate,
        last_update_login = Fnd_Global.Login_Id
        WHERE deliverable_id = deliverableIds(i);
            END IF;

             IF del_cur %ISOPEN THEN
               CLOSE del_cur ;
             END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving updateDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving updateDeliverables Unexpected ERROR');
     END IF;
     IF del_cur %ISOPEN THEN
        CLOSE del_cur ;
     END IF;
     IF get_del_ids_cur2 %ISOPEN THEN
        CLOSE get_del_ids_cur2;
     END IF;
     IF get_del_ids_cur1 %ISOPEN THEN
        CLOSE get_del_ids_cur1;
     END IF;

     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving updateDeliverables Unexpected ERROR');
     END IF;
     IF del_cur %ISOPEN THEN
        CLOSE del_cur ;
     END IF;
     IF get_del_ids_cur2 %ISOPEN THEN
        CLOSE get_del_ids_cur2;
     END IF;
     IF get_del_ids_cur1 %ISOPEN THEN
        CLOSE get_del_ids_cur1;
     END IF;

     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving updateDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    IF del_cur %ISOPEN THEN
       CLOSE del_cur ;
    END IF;
     IF get_del_ids_cur2 %ISOPEN THEN
        CLOSE get_del_ids_cur2;
     END IF;
     IF get_del_ids_cur1 %ISOPEN THEN
        CLOSE get_del_ids_cur1;
     END IF;

    ROLLBACK TO g_update_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- updateDeliverables

   /**
    * Enable Notifications flag of deliverables for given business document id
    * and type.
    */
   PROCEDURE enableNotifications (
        p_api_version  IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_commit            IN  Varchar2,
        p_bus_doc_id IN NUMBER,
        p_bus_doc_type IN VARCHAR2,
        p_bus_doc_version             IN NUMBER,
        x_msg_data  OUT NOCOPY  VARCHAR2,
        x_msg_count OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
        IS
        l_api_name CONSTANT VARCHAR2(30) := 'enableNotifications';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

        BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_enable_del_ntf_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

            UPDATE OKC_DELIVERABLES set DISABLE_NOTIFICATIONS_YN = 'N'
            WHERE  business_document_id = p_bus_doc_id
            AND    business_document_type = p_bus_doc_type
            AND    business_document_version = p_bus_doc_version;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving enableNotifications');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving enableNotifications Unexpected ERROR');
     END IF;
     ROLLBACK TO g_enable_del_ntf_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving enableNotifications Unexpected ERROR');
     END IF;
     ROLLBACK TO g_enable_del_ntf_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving enableNotifications because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_enable_del_ntf_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- enableNotifications

   /**
    * Cancel deliverables for given business document id and type, without
    * activating deliverables for given cancel event code
    */
   PROCEDURE  cancelDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
        IS
        l_api_name CONSTANT VARCHAR2(30) := 'cancelDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

        BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_cancel_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||'change_deliverable_status');
        END IF;

            --- call change_deliverable_status, to change deliverable status
            --- to CANCELLED
            OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_doc_id => p_bus_doc_id,
                                p_doc_version => p_bus_doc_version,
                                p_doc_type => p_bus_doc_type,
                                p_cancel_yn => 'Y',
                                p_cancel_event_code => NULL,
                                p_current_status => NULL,
                                p_new_status => 'CANCELLED',
                                p_manage_yn => 'N',
                                x_msg_data => x_msg_data,
                                x_msg_count => x_msg_count,
                                x_return_status => x_return_status);

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished change_deliverable_status' ||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving cancelDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving cancelDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_cancel_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving cancelDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_cancel_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving cancelDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_cancel_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END;

   /**
    * Cancel deliverables for given business document id and type and
    * activate deliverables for given cancel event code
    */
   PROCEDURE  cancelDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_event_code                IN VARCHAR2,
    p_event_date                IN DATE,
    p_bus_doc_date_events_tbl IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
    IS
        l_api_name CONSTANT VARCHAR2(30) := 'cancelDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_cancel2_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||'change_deliverable_status');
        END IF;

        --- call change_deliverable_status, to change deliverable status
        --- to CANCELLED
        OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_doc_id => p_bus_doc_id,
                                p_doc_version => p_bus_doc_version,
                                p_doc_type => p_bus_doc_type,
                                p_cancel_yn => 'Y',
                                p_cancel_event_code => p_event_code,
                                p_current_status => null,
                                p_new_status => 'CANCELLED',
                                p_manage_yn => 'N',
                                x_msg_data => x_msg_data,
                                x_msg_count => x_msg_count,
                                x_return_status => x_return_status);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished change_deliverable_status' ||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||'resolveDeliverables');
        END IF;

        --- resolve deliverables
        resolveDeliverables(
                        p_api_version => l_api_version,
                        p_init_msg_list => G_FALSE,
                        p_commit => G_FALSE,
                        p_bus_doc_id => p_bus_doc_id,
                        p_bus_doc_type => p_bus_doc_type,
                        p_bus_doc_version => p_bus_doc_version,
                        p_event_code => p_event_code,
                        p_event_date => p_event_date,
                        p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                        x_msg_data => x_msg_data,
                        x_msg_count => x_msg_count,
                        x_return_status => x_return_status,
                        p_cancel_flag => G_TRUE);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished resolveDeliverables' ||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||'OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status');
        END IF;

        --- call change_deliverable_status, to change deliverable status from
        --- INACTIVE to 'OPEN'
        OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_doc_id => p_bus_doc_id,
                                p_doc_version => p_bus_doc_version,
                                p_doc_type => p_bus_doc_type,
                                p_cancel_yn => 'N',
                                p_cancel_event_code => NULL,
                                p_current_status => 'INACTIVE',
                                p_new_status => 'OPEN',
                                p_manage_yn => 'Y',
                                x_msg_data => x_msg_data,
                                x_msg_count => x_msg_count,
                                x_return_status => x_return_status);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status' ||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving cancelDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving cancelDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_cancel2_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving cancelDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_cancel2_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving cancelDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_cancel2_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- cancelDeliverables


   /**
    * Update buyer on deliverables for given business document id and type.
    */
  PROCEDURE updateBuyerOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_original_buyer_id         IN NUMBER,
    p_new_buyer_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
    IS
        l_api_name CONSTANT VARCHAR2(30) := 'updateBuyerOnDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_update_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

            UPDATE OKC_DELIVERABLES
            set internal_party_contact_id = p_new_buyer_id,
            last_updated_by= Fnd_Global.User_Id,
            last_update_date = sysdate,
            last_update_login=Fnd_Global.Login_Id
            WHERE  business_document_id = p_bus_doc_id
            AND    business_document_type = p_bus_doc_type
            AND    business_document_version = p_bus_doc_version
            AND    internal_party_contact_id = p_original_buyer_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving updateDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving updateDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving updateDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving updateDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_update_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- updateDeliverables

   /**
    * Update buyer on deliverables for given business document id and type.
    */
  PROCEDURE updateBuyerOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_docs_tbl              IN BUSDOCS_TBL_TYPE,
    p_original_buyer_id         IN NUMBER,
    p_new_buyer_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
    IS
        l_api_name CONSTANT VARCHAR2(30) := 'updateBuyerDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

    TYPE BusDocIdList IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
    TYPE BusDocTypeList IS TABLE OF VARCHAR2(30)
    INDEX BY BINARY_INTEGER;
    TYPE BusDocVersionList IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

    l_bus_doc_ids BusDocIdList;
    l_bus_doc_types BusDocTypeList;
    l_bus_doc_versions BusDocVersionList;

    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_update2_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_bus_docs_tbl.count > 0 THEN
        FOR i IN p_bus_docs_tbl.FIRST..p_bus_docs_tbl.LAST LOOP
            l_bus_doc_ids(i) := p_bus_docs_tbl(i).bus_doc_id;
            l_bus_doc_types(i) := p_bus_docs_tbl(i).bus_doc_type;
            l_bus_doc_versions(i) := p_bus_docs_tbl(i).bus_doc_version;
        END LOOP;
      END IF;
        --- bulk update for deliverables actual due date
        FORALL j IN p_bus_docs_tbl.FIRST..p_bus_docs_tbl.LAST
        UPDATE OKC_DELIVERABLES
        set internal_party_contact_id = p_new_buyer_id,
            last_updated_by= Fnd_Global.User_Id,
            last_update_date = sysdate,
            last_update_login=Fnd_Global.Login_Id
        WHERE internal_party_contact_id = p_original_buyer_id
        AND   business_document_id = l_bus_doc_ids(j)
        AND   business_document_type = l_bus_doc_types(j)
        AND   business_document_version = l_bus_doc_versions(j);

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving updateBuyerDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving updateBuyerDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update2_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving updateBuyerDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update2_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving updateBuyerDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_update2_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- updateBuyerDeliverables

    /**
     * This procedure disables execution of deliverables for a given business document
     * version.
     */
    PROCEDURE disableDeliverables (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_commit          IN VARCHAR2,
        p_bus_doc_id    IN  NUMBER,
        p_bus_doc_type      IN VARCHAR2,
        p_bus_doc_version   IN  NUMBER,   -- -99 for Sourcing.
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
    IS
        l_api_name CONSTANT VARCHAR2(30) := 'disableDeliverables';
        l_api_version      CONSTANT VARCHAR2(30) := 1;

    BEGIN
        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_disable_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Calling OKC_DELIVERABLE_PROCESS_PVT.disable_deliverables');
        END IF;

            --- call change_deliverable_status, to change deliverable status
            --- to CANCELLED
            OKC_DELIVERABLE_PROCESS_PVT.disable_deliverables(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_doc_id => p_bus_doc_id,
                                p_doc_version => p_bus_doc_version,
                                p_doc_type => p_bus_doc_type,
                                x_msg_data => x_msg_data,
                                x_msg_count => x_msg_count,
                                x_return_status => x_return_status);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished disable_deliverables' ||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;


       IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'400: Leaving disableDeliverables');
       END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving disableDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_disable_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving disableDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_disable_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving disableDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_disable_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END; --disableDeliverables




   /**
    * Update internal contact on deliverables for given business document id and type.
    */
  PROCEDURE updateIntContactOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_original_internal_contact_id         IN NUMBER,
    p_new_internal_contact_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
    IS
        l_api_name CONSTANT VARCHAR2(30) := 'updateIntContactOnDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_update_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

           --bug#4154567 update -99 version aswell
            UPDATE OKC_DELIVERABLES
            set internal_party_contact_id = p_new_internal_contact_id,
            last_updated_by= Fnd_Global.User_Id,
            last_update_date = sysdate,
            last_update_login=Fnd_Global.Login_Id
            WHERE  business_document_id = p_bus_doc_id
            AND    business_document_type = p_bus_doc_type
            AND    business_document_version IN (-99, p_bus_doc_version)
            AND    internal_party_contact_id = p_original_internal_contact_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving updateIntContactOnDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving updateIntContactOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving updateIntContactOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving updateIntContactOnDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_update_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- updateIntContactOnDeliverables


   /**
    * Update internal contact on deliverables for given set of business document id and type.
    */
  PROCEDURE updateIntContactOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_docs_tbl              IN BUSDOCS_TBL_TYPE,
    p_original_internal_contact_id         IN NUMBER,
    p_new_internal_contact_id              IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
    IS
        l_api_name CONSTANT VARCHAR2(30) := 'updateIntContactOnDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

    TYPE BusDocIdList IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
    TYPE BusDocTypeList IS TABLE OF VARCHAR2(30)
    INDEX BY BINARY_INTEGER;
    TYPE BusDocVersionList IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

    l_bus_doc_ids BusDocIdList;
    l_bus_doc_types BusDocTypeList;
    l_bus_doc_versions BusDocVersionList;

    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_update2_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_bus_docs_tbl.count > 0 THEN
        FOR i IN p_bus_docs_tbl.FIRST..p_bus_docs_tbl.LAST LOOP
            l_bus_doc_ids(i) := p_bus_docs_tbl(i).bus_doc_id;
            l_bus_doc_types(i) := p_bus_docs_tbl(i).bus_doc_type;
            l_bus_doc_versions(i) := p_bus_docs_tbl(i).bus_doc_version;
        END LOOP;
      END IF;
        --- bulk update for deliverables actual due date
        FORALL j IN p_bus_docs_tbl.FIRST..p_bus_docs_tbl.LAST
        --bug#4154567 update -99 version aswell
        UPDATE OKC_DELIVERABLES
        set internal_party_contact_id = p_new_internal_contact_id,
            last_updated_by= Fnd_Global.User_Id,
            last_update_date = sysdate,
            last_update_login=Fnd_Global.Login_Id
        WHERE internal_party_contact_id = p_original_internal_contact_id
        AND   business_document_id = l_bus_doc_ids(j)
        AND   business_document_type = l_bus_doc_types(j)
        AND   business_document_version IN (l_bus_doc_versions(j),-99);

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving updateIntContactOnDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving updateIntContactOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update2_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving updateIntContactOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update2_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving updateIntContactOnDeliverables  because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_update2_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- updateIntContactOnDeliverables

   /**
   * This procedure updates external party id and site id
   * on deliverables for given draft version of business document.
   */
   PROCEDURE updateExtPartyOnDeliverables (
   p_api_version               IN NUMBER,
   p_init_msg_list             IN VARCHAR2,
   p_commit                    IN VARCHAR2,
   p_bus_doc_id                IN NUMBER,
   p_bus_doc_type              IN VARCHAR2,
   p_external_party_id         IN NUMBER,
   p_external_party_site_id    IN NUMBER,
   x_msg_data                  OUT NOCOPY  VARCHAR2,
   x_msg_count                 OUT NOCOPY  NUMBER,
   x_return_status             OUT NOCOPY  VARCHAR2)
   IS

        l_api_name CONSTANT VARCHAR2(30) := 'updateExtPartyOnDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_update_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

            UPDATE OKC_DELIVERABLES
            SET external_party_id = p_external_party_id,
            external_party_site_id = p_external_party_site_id,
            last_updated_by= Fnd_Global.User_Id,
            last_update_date = sysdate,
            last_update_login=Fnd_Global.Login_Id
            WHERE  business_document_id = p_bus_doc_id
            AND    business_document_type = p_bus_doc_type
            AND    business_document_version = -99;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving updateExtPartyOnDeliverables ');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving updateExtPartyOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving updateExtPartyOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving updateExtPartyOnDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_update_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- updateExtPartyOnDeliverables

   /**
   * This procedure updates external party id and site id
   * on deliverables for given version of business document.
   * Used for Supplier Merge
   * 15-JUN-2004 pnayani - bug#3691985 Supplier merge for Sourcing not working
   */
   PROCEDURE updateExtPartyOnDeliverables (
   p_api_version               IN NUMBER,
   p_init_msg_list             IN VARCHAR2,
   p_commit                    IN VARCHAR2,
   p_document_class            IN VARCHAR2,
   p_from_external_party_id         IN NUMBER,
   p_from_external_party_site_id    IN NUMBER,
   p_to_external_party_id           IN NUMBER,
   p_to_external_party_site_id      IN NUMBER,
   x_msg_data                  OUT NOCOPY  VARCHAR2,
   x_msg_count                 OUT NOCOPY  NUMBER,
   x_return_status             OUT NOCOPY  VARCHAR2)
   IS

   l_api_name CONSTANT VARCHAR2(30) := 'updateExtPartyOnDeliverables';
   l_api_version     CONSTANT VARCHAR2(30) := 1;

   CURSOR del_cur IS
   SELECT deliverable_id,external_party_site_id
   FROM okc_deliverables
   where external_party_id = p_from_external_party_id
   and business_document_type IN (select document_type
   from okc_bus_doc_types_b
   where document_type_class = p_document_class);
   del_rec  del_cur%ROWTYPE;

   TYPE delIdTabType IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
   j  PLS_INTEGER;

   delIdTab    delIdTabType;
   delExtSiteIdTab    delIdTabType;


    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: p_from_external_party_id and p_from_external_party_site_id : '||p_from_external_party_site_id ||' and '||p_from_external_party_site_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: p_to_external_party_id and p_to_external_party_site_id : '||p_to_external_party_site_id ||' and '||p_to_external_party_site_id);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_update_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- initialize the table with 0 rows
      j := 0;
      delIdTab.delete;
      delExtSiteIdTab.delete;
            FOR del_rec IN del_cur LOOP
    IF p_from_external_party_site_id is not null THEN
      j := j+1;
      delIdTab(j) := del_rec.deliverable_id;
      delExtSiteIdTab(j) := p_to_external_party_site_id;
    ELSE
      j := j+1;
      delIdTab(j) := del_rec.deliverable_id;
      IF del_rec.external_party_site_id = -1 THEN
              delExtSiteIdTab(j) := -1;
      ELSE
        delExtSiteIdTab(j) := p_to_external_party_site_id;
            END IF;
          END IF;
      END LOOP;

      IF delIdTab.COUNT <> 0 THEN
              -- bulk update deliverables external party
              FORALL i IN delIdTab.FIRST..delIdTab.LAST
              UPDATE okc_deliverables
              SET external_party_id = p_to_external_party_id,
              external_party_site_id = delExtSiteIdTab(i),
              last_updated_by= Fnd_Global.User_Id,
              last_update_date = sysdate,
              last_update_login=Fnd_Global.Login_Id
              WHERE deliverable_id = delIdTab(i);
      END IF;
             IF del_cur %ISOPEN THEN
               CLOSE del_cur ;
             END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving updateExtPartyOnDeliverables ');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving updateExtPartyOnDeliverables Unexpected ERROR');
     END IF;
    -- close any open cursors
    IF del_cur %ISOPEN THEN
     CLOSE del_cur ;
    END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving updateExtPartyOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving updateExtPartyOnDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    -- close any open cursors
    IF del_cur %ISOPEN THEN
     CLOSE del_cur ;
    END IF;

    ROLLBACK TO g_update_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END;

   /**
    * Create status history rows and send notifications for
    * deliverables on this business document whose status has changed since
    * last entry in status history.
    * Can be called by code that wants to post status changes that have not been reflected in the middle tier (e.g. Bid Submission)
  */
   PROCEDURE postDelStatusChanges (
        p_api_version  IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_commit            IN  Varchar2,
        p_bus_doc_id IN NUMBER,
        p_bus_doc_type IN VARCHAR2,
        p_bus_doc_version             IN NUMBER,
        x_msg_data  OUT NOCOPY  VARCHAR2,
        x_msg_count OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
        IS
        l_api_name CONSTANT VARCHAR2(30) := 'postDelStatusChanges';
        l_api_version     CONSTANT VARCHAR2(30) := 1;


  k PLS_INTEGER := 0;
  l_msg_code VARCHAR2(30);
  l_key number;

  --Cursor to select rows where status differs from most recent record in status history
  cursor del_cursor IS
  select
    deliverable.deliverable_status,
    deliverable.status_change_notes,
    deliverable.deliverable_id,
    deliverable.notify_completed_yn
  from okc_deliverables deliverable
  where
        deliverable.deliverable_status <> 'INACTIVE' and
        business_document_id = p_bus_doc_id and
        business_document_type = p_bus_doc_type and
            business_document_version = p_bus_doc_version and
        deliverable.deliverable_status <>
            (select status_history_inner.deliverable_status
             from okc_del_status_history status_history_inner
             where status_history_inner.deliverable_id = deliverable.deliverable_id
                 and status_history_inner.deliverable_status <> 'INACTIVE'
             and status_history_inner.status_change_date = (select max(status_change_date)
                                   from okc_del_status_history
                                   where deliverable_id = deliverable.deliverable_id and
                                   deliverable_status <> 'INACTIVE'));


  del_rec del_cursor%ROWTYPE;
  delStsTab OKC_DELIVERABLE_PROCESS_PVT.delHistTabType;

  cursor status_notes_cur IS
    select
      deliverable.deliverable_status,
      deliverable.status_change_notes,
      deliverable.deliverable_id,
      status_history.status_change_date
    from
      okc_deliverables deliverable,
      okc_del_status_history status_history
    where
      deliverable.deliverable_status <> 'INACTIVE' and
          business_document_id = p_bus_doc_id and
          business_document_type = p_bus_doc_type and
                business_document_version = p_bus_doc_version and
      status_history.deliverable_status = deliverable.deliverable_status and
      status_history.deliverable_id = deliverable.deliverable_id and
      (deliverable.status_change_notes <> status_history.status_change_notes OR status_history.status_change_notes IS NULL) and
      status_history.status_change_date = (select max(status_history_inner.status_change_date)
                   from okc_del_status_history status_history_inner
                   where status_history_inner.deliverable_id = deliverable.deliverable_id and status_history_inner.deliverable_status <> 'INACTIVE');
  status_notes_rec status_notes_cur%ROWTYPE;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);

        BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_createHistory_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

  --loop thru deliverables where only the notes have changed
  FOR status_notes_rec IN status_notes_cur LOOP
    update okc_del_status_history
    set status_change_notes = status_notes_rec.status_change_notes
    where status_change_date = status_notes_rec.status_change_date and
    deliverable_id = status_notes_rec.deliverable_id and
    deliverable_status = status_notes_rec.deliverable_status;

  END LOOP;


  --loop through all modified deliverables
  FOR del_rec IN del_cursor LOOP
    k:=k+1;

    --add to status history table
    delStsTab(k).deliverable_id := del_rec.deliverable_id;
    delStsTab(k).deliverable_status := del_rec.deliverable_status;
    delStsTab(k).status_changed_by := fnd_global.user_id;
    delStsTab(k).status_change_date := sysdate;
    delStsTab(k).status_change_notes := del_rec.status_change_notes;
    delStsTab(k).object_version_number := 1;
    delStsTab(k).created_by := fnd_global.user_id;
    delStsTab(k).creation_date := sysdate;
    delStsTab(k).last_update_date := sysdate;
    delStsTab(k).last_updated_by := fnd_global.user_id;
    delStsTab(k).last_update_login := fnd_global.login_Id;

    --if necessary, send notification
    if ('Y' = del_rec.notify_completed_yn) then
      select OKC_WF_NOTIFY_S1.nextval into l_key from dual;


			  --Acq Plan Message Cleanup
   /*
      if ('COMPLETED' = del_rec.deliverable_status) then
          l_msg_code := 'OKC_DEL_COMPLETE_NTF_SUBJECT';
      elsif ('CANCELLED' = del_rec.deliverable_status) then
              l_msg_code := 'OKC_DEL_CANCEL_NTF_SUBJECT';
      elsif ('OPEN' = del_rec.deliverable_status) then
              l_msg_code := 'OKC_DEL_REOPEN_NTF_SUBJECT';
      elsif ('FAILED_TO_PERFORM' = del_rec.deliverable_status) then
              l_msg_code := 'OKC_DEL_FAILED_NTF_SUBJECT';
      elsif ('REJECTED' = del_rec.deliverable_status ) then
              l_msg_code := 'OKC_DEL_REJECT_NTF_SUBJECT';
      else
              l_msg_code := 'OKC_DEL_SUBMIT_NTF_SUBJECT';
      end if;
     */


      if ('COMPLETED' = del_rec.deliverable_status) THEN
        l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_COMPLETE_NTF_SUBJECT',p_bus_doc_type);
      elsif ('CANCELLED' = del_rec.deliverable_status) THEN
        l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_CANCEL_NTF_SUBJECT',p_bus_doc_type);
      elsif ('OPEN' = del_rec.deliverable_status) THEN
        l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_REOPEN_NTF_SUBJECT',p_bus_doc_type);
      elsif ('FAILED_TO_PERFORM' = del_rec.deliverable_status) THEN
        l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_FAILED_NTF_SUBJECT',p_bus_doc_type);
      elsif ('REJECTED' = del_rec.deliverable_status ) THEN
        l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_REJECT_NTF_SUBJECT',p_bus_doc_type);
      ELSE
        l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_SUBMIT_NTF_SUBJECT',p_bus_doc_type);
      end if;

     l_msg_code := l_resolved_msg_name;

      begin
        --raise bus event to send notification
        WF_EVENT.raise2(p_event_name => 'oracle.apps.okc.deliverables.sendNotification',
                    p_event_key => to_char(l_key),
                    p_parameter_name1 => 'DELIVERABLE_ID',
                    p_parameter_value1 => del_rec.deliverable_id,
                    p_parameter_name2 => 'MSG_CODE',
                    p_parameter_value2 => l_msg_Code);          exception
      when others then
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving postDelStatusChanges because of EXCEPTION in WF_event.raise2:'||sqlerrm);

        END IF;
        raise;
      end;

    end if;

  END LOOP;

  begin
  --bulk create status history records
    if k > 0 then
    OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history(p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_del_st_hist_tab => delStsTab,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count,
    x_return_status => x_return_status );
    end if;

  exception
  when others then
  IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving postDelStatusChanges because of EXCEPTION in OKC_DELIVERABLE_PROCESS_PVT.create_del_status_history:'||x_msg_data);

  END IF;
  raise;
  end;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving create history');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving postDelStatusChanges Unexpected ERROR');
     END IF;
     ROLLBACK TO g_createHistory_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving postDelStatusChanges Unexpected ERROR');
     END IF;
     ROLLBACK TO g_createHistory_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving postDelStatusChanges because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_createHistory_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- postDelStatusChanges

    /** 11.5.10+ code
    Function to check if any deliverables exist for a given external
    party for a given contract. Invoked by Repository ContractDetailsAMImpl.java    API.
    Parameter Details:
    p_busdoc_id :           Business document Id
    p_busdoc_type :         Business document type
    p_external_party_id              ID of internal or external party
    p_external_party_role            Role of internal or external party
                            (valid values INTERNAL,SUPPLIER, CUSTOMER, PARTNER)
    Returns N or Y, if there is unexpected error then it returns NULL.
    **/

FUNCTION deliverablesForExtPartyExist(
p_api_version      IN  NUMBER,
p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
x_return_status    OUT NOCOPY VARCHAR2,
x_msg_data         OUT NOCOPY VARCHAR2,
x_msg_count        OUT NOCOPY NUMBER,

p_busdoc_id          IN  NUMBER,
p_busdoc_type        IN  VARCHAR2,
p_external_party_id           IN  NUMBER,
p_external_party_role         IN  VARCHAR2)
RETURN VARCHAR2
IS
 --bug#4170483 removed check for responsible party. and added -99 version check
CURSOR del_cur IS
SELECT 'X'
FROM   okc_deliverables
WHERE  business_document_type = p_busdoc_type
AND    business_document_id = p_busdoc_id
AND    business_document_version =-99
AND    UPPER(external_party_role) = UPPER(p_external_party_role)
AND    external_party_id = p_external_party_id;

del_rec del_cur%ROWTYPE;
l_return_value  VARCHAR2(1);
l_api_name VARCHAR2(30) := 'deliverablesForExtPartyExist';



BEGIN

  --  Initialize API return status to success
  x_return_status := OKC_API.G_RET_STS_SUCCESS;


  l_return_value :=  'N';

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Inside '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

 -- check if deliverables exist for the given party on a contract.
 OPEN del_cur;
 FETCH del_cur INTO del_rec;
    IF del_cur%FOUND THEN

            l_return_value := 'Y';

    END IF;
 CLOSE del_cur;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    RETURN(l_return_value);

EXCEPTION
  WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name||' with unexpected error');
    END IF;
    IF del_cur %ISOPEN THEN
      CLOSE del_cur ;
    END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F'
      , p_count => x_msg_count
      , p_data => x_msg_data );

      RETURN null;

END deliverablesForExtPartyExist;


/** 11.5.10+ code
Function to check if any maneagable deliverables exist for a given contract.    Invoked by Repository ContractDetailsAMImpl.java.
Parameter Details:
p_busdoc_id :           Business document Id
p_busdoc_type :         Business document type
p_busdoc_version :      Business document version
Returns N or Y, if there is unexpected error then it returns NULL.
**/
FUNCTION check_manageable_deliverables(
p_api_version      IN  NUMBER,
p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
x_return_status    OUT NOCOPY VARCHAR2,
x_msg_data         OUT NOCOPY VARCHAR2,
x_msg_count        OUT NOCOPY NUMBER,

p_busdoc_id          IN  NUMBER,
p_busdoc_type        IN  VARCHAR2,
p_busdoc_version          IN  NUMBER)
RETURN VARCHAR2
IS
CURSOR del_cur IS
SELECT 'X'
FROM   okc_deliverables
WHERE  business_document_type = p_busdoc_type
AND    business_document_id = p_busdoc_id
AND    business_document_version = p_busdoc_version
AND    manage_yn = 'Y';
del_rec del_cur%ROWTYPE;
l_return_value  VARCHAR2(1);
l_api_name VARCHAR2(30) := 'check_manageable_deliverables';



BEGIN

  --  Initialize API return status to success
  x_return_status := OKC_API.G_RET_STS_SUCCESS;


  l_return_value :=  'N';

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Inside '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

 -- check if maneagable deliverables exist for the given contract.
 OPEN del_cur;
 FETCH del_cur INTO del_rec;
    IF del_cur%FOUND THEN

            l_return_value := 'Y';
    END IF;
 CLOSE del_cur;
    RETURN(l_return_value);
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name||' with unexpected error');
    END IF;
    IF del_cur %ISOPEN THEN
      CLOSE del_cur ;
    END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F'
      , p_count => x_msg_count
      , p_data => x_msg_data );

      RETURN null;

END check_manageable_deliverables;


    /**
     * 11.5.10+ This procedure updates external party id and site id
     * on deliverables for given class of business document.
     * This API is for HZ party Merge process, it handles site merge
     * within a customer
     */
    PROCEDURE mergeExtPartyOnDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_document_class            IN VARCHAR2,
    p_from_external_party_id         IN NUMBER,
    p_from_external_party_site_id    IN NUMBER,
    p_to_external_party_id         IN NUMBER,
    p_to_external_party_site_id    IN NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)

   IS

   l_api_name CONSTANT VARCHAR2(30) := 'mergeExtPartyOnDeliverables';
   l_api_version     CONSTANT VARCHAR2(30) := 1;

   CURSOR del_cur IS
   SELECT deliverable_id,external_party_site_id
   FROM okc_deliverables
   where external_party_id = NVL(p_from_external_party_id,external_party_id)
   and   external_party_role <> 'SUPPLIER_ORG'
   and business_document_type IN (select document_type
   from okc_bus_doc_types_b
   where document_type_class = p_document_class);
   del_rec  del_cur%ROWTYPE;

   TYPE delIdTabType IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
   j  PLS_INTEGER;

   delIdTab    delIdTabType;


    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Entered '||G_PKG_NAME ||'.'||l_api_name);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: p_from_external_party_id and p_from_external_party_site_id : '||p_from_external_party_site_id ||' and '||p_from_external_party_site_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: p_to_external_party_id and p_to_external_party_site_id : '||p_to_external_party_site_id ||' and '||p_to_external_party_site_id);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_update_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- initialize the table with 0 rows
      j := 0;
      delIdTab.delete;
        FOR del_rec IN del_cur LOOP
              j := j+1;
              delIdTab(j) := del_rec.deliverable_id;
      END LOOP;

      IF delIdTab.COUNT <> 0 THEN
              -- bulk update deliverables external party
              FORALL i IN delIdTab.FIRST..delIdTab.LAST
              UPDATE okc_deliverables
              SET external_party_id = NVL(p_to_external_party_id,external_party_id),
              external_party_site_id = p_to_external_party_site_id,
              last_updated_by= Fnd_Global.User_Id,
              last_update_date = sysdate,
              last_update_login=Fnd_Global.Login_Id
              WHERE deliverable_id = delIdTab(i);
      END IF;
             IF del_cur %ISOPEN THEN
               CLOSE del_cur ;
             END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving mergeExtPartyOnDeliverables ');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving mergeExtPartyOnDeliverables Unexpected ERROR');
     END IF;
    -- close any open cursors
    IF del_cur %ISOPEN THEN
     CLOSE del_cur ;
    END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving mergeExtPartyOnDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_update_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving mergeExtPartyOnDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    -- close any open cursors
    IF del_cur %ISOPEN THEN
     CLOSE del_cur ;
    END IF;

    ROLLBACK TO g_update_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END; -- mergeExtPartyOnDeliverables

   /**
    * Activate closeout deliverables for given business document id and type
    */
   PROCEDURE  activateCloseoutDeliverables (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_commit            IN  Varchar2,
    p_bus_doc_id                IN NUMBER,
    p_bus_doc_type              IN VARCHAR2,
    p_bus_doc_version           IN NUMBER,
    p_event_code                IN VARCHAR2,
    p_event_date                IN DATE,
    p_bus_doc_date_events_tbl IN BUSDOCDATES_TBL_TYPE,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2)
    IS
        l_api_name CONSTANT VARCHAR2(30) := 'activateCloseoutDeliverables';
        l_api_version     CONSTANT VARCHAR2(30) := 1;

    BEGIN

        -- start procedure
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_activatecloseout_del_GRP;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Calling '||'resolveDeliverables');
        END IF;

        --- resolve deliverables
        resolveDeliverables(
                        p_api_version => l_api_version,
                        p_init_msg_list => G_FALSE,
                        p_commit => G_FALSE,
                        p_bus_doc_id => p_bus_doc_id,
                        p_bus_doc_type => p_bus_doc_type,
                        p_bus_doc_version => p_bus_doc_version,
                        p_event_code => p_event_code,
                        p_event_date => p_event_date,
                        p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                        x_msg_data => x_msg_data,
                        x_msg_count => x_msg_count,
                        x_return_status => x_return_status,
                        p_cancel_flag => G_TRUE);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished resolveDeliverables' ||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'400: Entered '||'OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status');
        END IF;

        --- call change_deliverable_status, to change deliverable status from
        --- INACTIVE to 'OPEN'
        OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status(
                              p_api_version => l_api_version,
                                p_init_msg_list => G_FALSE,
                                p_doc_id => p_bus_doc_id,
                                p_doc_version => p_bus_doc_version,
                                p_doc_type => p_bus_doc_type,
                                p_cancel_yn => 'N',
                                p_cancel_event_code => NULL,
                                p_current_status => 'INACTIVE',
                                p_new_status => 'OPEN',
                                p_manage_yn => 'Y',
                                x_msg_data => x_msg_data,
                                x_msg_count => x_msg_count,
                                x_return_status => x_return_status);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'500: Finished OKC_DELIVERABLE_PROCESS_PVT.change_deliverable_status' ||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving activateCloseoutDeliverables');
   END IF;

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving activateCloseoutDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_activatecloseout_del_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving activateCloseoutDeliverables Unexpected ERROR');
     END IF;
     ROLLBACK TO g_activatecloseout_del_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving activateCloseoutDeliverables because of EXCEPTION: '||substr(sqlerrm,1,200));
    END IF;
    ROLLBACK TO g_activatecloseout_del_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   END; -- activateCloseoutDeliverables

/*-- Start of comments
--API name      : applyPaymentHolds
--Type          : Private.
--Function      : 1.  This API returns TRUE if the Invoices for the concerned PO need to be held.False otherwise
--              : (The check will only be made for a Standard PO, and only for 'CONTRACTUAL' deliverables)
--              : 2.  It runs through the pay_when_paid deliverables associated with the concerned PO.
--              :     It returns true based on which checkbox is checked and by comparing the sysdate with the actual due date.
--Usage         : This public API will be used only by the PO team to determine if invoices need to be held for the PO because of any deliverable
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_bus_doc_id          IN NUMBER       Required
--                   Header ID of the Standard Purchase Order
--              : p_bus_doc_version     IN NUMBER       Required
--                   Version number of the Standard Purchase Order
--OUT           : x_return_status       OUT  VARCHAR2
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments */
PROCEDURE applyPaymentHolds(
        p_api_version           IN NUMBER,
        p_bus_doc_id            IN NUMBER,
        p_bus_doc_version       IN NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2)
IS

CURSOR getDeliverables IS
SELECT
DELIVERABLE_ID,
PAY_HOLD_PRIOR_DUE_DATE_YN,
PAY_HOLD_PRIOR_DUE_DATE_VALUE,
PAY_HOLD_PRIOR_DUE_DATE_UOM,
PAY_HOLD_OVERDUE_YN,
ACTUAL_DUE_DATE
FROM okc_deliverables
WHERE business_document_id = p_bus_doc_id
AND business_document_version = p_bus_doc_version
AND business_document_type = 'PO_STANDARD'
AND deliverable_type = 'CONTRACTUAL'
AND responsible_party = 'SUPPLIER_ORG'
AND (PAY_HOLD_PRIOR_DUE_DATE_YN = 'Y' OR PAY_HOLD_OVERDUE_YN = 'Y')
AND deliverable_status NOT IN ('COMPLETED','CANCELLED','INACTIVE');

l_return_status_true  VARCHAR2(1)  := G_TRUE;
l_return_status_false VARCHAR2(1)  := G_FALSE;
l_effective_beforedue_date DATE;
l_api_name CONSTANT VARCHAR2(50) := 'applyPaymentHolds';


BEGIN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inside OKC_MANAGE_DELIVERABLES_GRP.payWhenPaidApplyHolds');
      END IF;
x_return_status := l_return_status_false;


FOR del_cur IN getDeliverables LOOP

   IF del_cur.PAY_HOLD_PRIOR_DUE_DATE_YN = 'Y' THEN

      IF UPPER(del_cur.PAY_HOLD_PRIOR_DUE_DATE_UOM) = 'DAY' THEN
          l_effective_beforedue_date := trunc(del_cur.actual_due_date)-del_cur.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      ELSIF UPPER(del_cur.PAY_HOLD_PRIOR_DUE_DATE_UOM) = 'WK' THEN
          l_effective_beforedue_date :=trunc(del_cur.actual_due_date)-7*del_cur.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      ELSIF UPPER(del_cur.PAY_HOLD_PRIOR_DUE_DATE_UOM) = 'MTH' THEN
          select add_months(del_cur.actual_due_date,-del_cur.PAY_HOLD_PRIOR_DUE_DATE_VALUE)
          INTO l_effective_beforedue_date from dual;
      END IF;

          IF trunc(l_effective_beforedue_date) = trunc(sysdate) OR
                   trunc(l_effective_beforedue_date) < trunc(sysdate) THEN

          x_return_status := l_return_status_true;
          RETURN;
          END IF;

   ELSIF del_cur.PAY_HOLD_OVERDUE_YN = 'Y' THEN

          IF trunc(sysdate) > trunc(del_cur.actual_due_date) THEN
          x_return_status := l_return_status_true;
          RETURN;
          END IF;

   END IF;

END LOOP;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'leaving OKC_MANAGE_DELIVERABLES_GRP.payWhenPaidApplyHolds');
      END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'leaving OKC_MANAGE_DELIVERABLES_GRP.payWhenPaidApplyHolds in OTHERS');
       END IF;
        IF getDeliverables %ISOPEN THEN
        CLOSE getDeliverables ;
        END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF;
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );


END applyPaymentHolds;

/*-- Start of comments
--Function name : checkDeliverablePayHold
--Type          : Public.
--Function      : This Function returns TRUE if the deliverable is holding invoices.False otherwise.
--Usage         : This public API will be used only by the Projects team to determine if a
--                particular deliverable is holding invoices or not.
--Pre-reqs      : None.
--Returns       :TRUE or FALSE, if there is unexpected error then it returns NULL.
-- End of comments */

FUNCTION checkDeliverablePayHold (
        p_deliverable_id        IN NUMBER)
RETURN VARCHAR2
IS

CURSOR del_cur IS
SELECT
PAY_HOLD_PRIOR_DUE_DATE_YN,
PAY_HOLD_PRIOR_DUE_DATE_VALUE,
PAY_HOLD_PRIOR_DUE_DATE_UOM,
PAY_HOLD_OVERDUE_YN,
ACTUAL_DUE_DATE
FROM okc_deliverables
WHERE deliverable_id = p_deliverable_id
AND business_document_type = 'PO_STANDARD'
AND deliverable_type = 'CONTRACTUAL'
AND responsible_party = 'SUPPLIER_ORG'
AND (PAY_HOLD_PRIOR_DUE_DATE_YN = 'Y' OR PAY_HOLD_OVERDUE_YN = 'Y')
AND deliverable_status NOT IN ('COMPLETED','CANCELLED','INACTIVE');

del_rec del_cur%ROWTYPE;
l_return_value  VARCHAR2(1);
l_effective_beforedue_date DATE;
l_api_name VARCHAR2(30) := 'checkDeliverablePayHold';

BEGIN
  l_return_value :=  G_FALSE;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inside '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

 OPEN del_cur;
 FETCH del_cur INTO del_rec;

  IF del_cur%FOUND THEN
   IF del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN = 'Y' THEN

      IF UPPER(del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM) = 'DAY' THEN
          l_effective_beforedue_date := trunc(del_rec.actual_due_date)-del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      ELSIF UPPER(del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM) = 'WK' THEN
          l_effective_beforedue_date :=trunc(del_rec.actual_due_date)-7*del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      ELSIF UPPER(del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM) = 'MTH' THEN
          l_effective_beforedue_date:= add_months(del_rec.actual_due_date,-del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE);
      END IF;

          IF trunc(l_effective_beforedue_date) = trunc(sysdate) OR
                   trunc(l_effective_beforedue_date) < trunc(sysdate) THEN

          l_return_value := G_TRUE;
          END IF;

   ELSIF del_rec.PAY_HOLD_OVERDUE_YN = 'Y' THEN

          IF trunc(sysdate) > trunc(del_rec.actual_due_date) THEN
          l_return_value := G_TRUE;
          END IF;

   END IF;

 END IF;

 CLOSE del_cur;
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;


RETURN(l_return_value);

EXCEPTION
    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'leaving OKC_MANAGE_DELIVERABLES_GRP.checkDeliverablePayHold in OTHERS');
       END IF;
        IF del_cur%ISOPEN THEN
        CLOSE del_cur ;
        END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF;
RETURN null;

END checkDeliverablePayHold;


  ---------------------------------------------------------------------------
  -- END: Public Procedures and Functions
  ---------------------------------------------------------------------------


END;

/
