--------------------------------------------------------
--  DDL for Package Body EDR_PSIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_PSIG" AS
/* $Header: EDRPSIGB.pls 120.3.12000000.1 2007/01/18 05:54:43 appldev ship $ */

/* Exceptions */
TIMEZONE_ERROR exception;
DOCUMENT_NOT_FOUND exception;
DOCUMENT_PENDING exception;
DOCUMENT_CLOSE_ERROR exception;
EDR_GENERIC_ERROR exception;
EDR_INVALID_DOC_STATUS exception;
EDR_INVALID_DOC_TRAN exception;
EDR_INVALID_SIGN_REQUEST exception;
EDR_INVALID_USER exception;
EDR_DUPLICATE_SIGNER Exception;

--Bug 3212117: Start
G_CHILD_ERECORD_COUNT NUMBER;
--Bug 3212117: End


/* Global variables */
/* Verify Servertime Zone */
PROCEDURE VERIFY_TIMEZONE(X_TIMEZONE OUT NOCOPY VARCHAR2,
                          X_ERROR OUT  NOCOPY NUMBER,
                          X_ERROR_MSG OUT NOCOPY VARCHAR2) IS

l_server_timezone varchar2(240);
l_edr_timezone varchar2(240);

BEGIN

  --Bug 4073809 : start
  l_server_timezone :=fnd_timezones.GET_SERVER_TIMEZONE_CODE;
  l_edr_timezone :=fnd_profile.VALUE('EDR_SERVER_TIMEZONE');
  --Bug 4073809 : end

  /* Bug Fix 3225490 . Added new or condition to check null value for edr_timezone */
   IF (l_edr_timezone <> l_server_timezone) or (l_server_timezone is NULL)  or (l_edr_timezone is NULL) THEN
   /*end of bug fix 3225490 */
      fnd_message.set_name('EDR','EDR_PSIG_TIMEZONE_ERROR');
      X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_TIMEZONE_ERROR');
      X_ERROR_MSG:= fnd_message.get();
      X_TIMEZONE:=NULL;
   END IF;
   X_TIMEZONE := L_EDR_TIMEZONE;
END VERIFY_TIMEZONE;

/* Get_DOCUMENT_STATUS. This procedure will return the current document status for a given document_id
   if document is not availalbe the procedure will raise a not data found exception
*/

PROCEDURE GET_DOCUMENT_STATUS(P_DOCUMENT_ID IN NUMBER,
                              X_STATUS OUT NOCOPY VARCHAR2,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2) IS
 CURSOR C1 is
 SELECT PSIG_STATUS from EDR_PSIG_DOCUMENTS
  WHERE DOCUMENT_ID = P_DOCUMENT_ID;
 L_document_status varchar2(240);
 BEGIN
   OPEN C1;
   FETCH C1 into X_STATUS;
   if c1%NOTFOUND THEN
      raise DOCUMENT_NOT_FOUND;
   END IF;
   CLOSE C1;
 EXCEPTION
 WHEN DOCUMENT_NOT_FOUND THEN
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOCUMENT');
                X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOCUMENT');
                X_ERROR_MSG:= fnd_message.get();
                CLOSE c1;
 WHEN OTHERS then
             X_ERROR:=SQLCODE;
             X_ERROR_MSG:=SQLERRM;
             CLOSE c1;
 END GET_DOCUMENT_STATUS;

PROCEDURE GET_SIGNATURE_STATUS(P_SIGNATURE_ID IN NUMBER,
                              X_STATUS OUT NOCOPY VARCHAR2,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2) IS
 CURSOR C1 is
 SELECT SIGNATURE_STATUS from EDR_PSIG_DETAILS
  WHERE SIGNATURE_ID = P_SIGNATURE_ID;
 L_Signature_status varchar2(240);
 BEGIN
   OPEN C1;
   FETCH C1 into X_STATUS;
   if c1%NOTFOUND THEN
      raise DOCUMENT_NOT_FOUND;
   END IF;
   CLOSE C1;
 EXCEPTION
 WHEN DOCUMENT_NOT_FOUND THEN
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNATURE');
                X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNATURE');
                X_ERROR_MSG:= fnd_message.get();
                CLOSE c1;
 WHEN OTHERS then
             X_ERROR:=SQLCODE;
             X_ERROR_MSG:=SQLERRM;
             CLOSE c1;
 END GET_SIGNATURE_STATUS;

PROCEDURE VALIDATE_USER(P_USER IN VARCHAR2,
                              X_STATUS OUT NOCOPY boolean,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2) IS
 CURSOR C1 is
 SELECT count(*) from FND_USER
  WHERE USER_NAME = P_USER;
 L_count number;
 BEGIN
   OPEN C1;
      FETCH C1 into l_count;
   CLOSE C1;
   IF l_count > 0 THEN
      x_status :=true;
   else
      x_status := false;
      RAISE EDR_INVALID_USER;
   END IF;
 EXCEPTION
 WHEN EDR_INVALID_USER THEN
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_USER');
                fnd_message.set_token('USER',P_USER);
                X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_USER');
                X_ERROR_MSG:= fnd_message.get();

 WHEN OTHERS then
             X_ERROR:=SQLCODE;
             X_ERROR_MSG:=SQLERRM;
             CLOSE c1;
 END VALIDATE_USER;

/* Copy Attachments */
function COPY_NTF_ATTACHMENTS(p_nid VARCHAR2,
               p_target_value varchar2) return boolean
IS
  l_erecord_id number;
      l_entity_name varchar2(240);
      l_pk1_value VARCHAR2(100);
      l_pk2_value VARCHAR2(100);
      l_pk3_value VARCHAR2(100);
      l_pk4_value VARCHAR2(100);
      l_pk5_value VARCHAR2(100);
      l_eres_category_id NUMBER;
      l_user_id NUMBER;
      l_login_id NUMBER;
      l_attachment_string varchar2(2000);
      --Bug 4006844: Start
      --This would hold the value of the document category specified in workflow.
      l_category_name VARCHAR2(100);
      --This would hold the corresponding category id, if it exists.
      l_category_id NUMBER;
      --Bug 4006844: End
BEGIN
     /* Parse the string */
      BEGIN
        wf_log_pkg.string(6, 'Copy Attachments...','Verifying....the attribute attachments');
       l_attachment_string:=wf_notification.getattrtext(p_nid,'#ATTACHMENTS');
       wf_log_pkg.string(6, 'Copy Attachments...','Attribute String.....'||l_attachment_string);
      exception
        when others then
       NULL;
      END;
      if l_attachment_string is NULL then
         return true;
      end if;
       wf_log_pkg.string(6, 'Copy Attachments...','Parsing String'||l_attachment_string);
      /* parse String */
         /* get the entity name */
         l_entity_name:=substr(l_attachment_string,instr(l_attachment_string,'=')+1,
                        instr(l_attachment_string,'&')-(instr(l_attachment_string,'=')+1));
           if l_entity_name ='ERECORD' then
              /* this is already an ERECORD entity Don't make a copy of it */
              return true;
          end if;
          wf_log_pkg.string(6, 'Copy Attachments...','ENTITY....'||l_entity_Name);
          /* Check the for number of parameter */
          --Bug 4006844: Start
    --This parsing logic would be changed completely
    /*
           if  instr(l_attachment_string,'&',1,3) > 0 then
                l_pk1_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,3)+1,                                                               instr(l_attachment_string,'&',1,3)-(instr(l_attachment_string,'=',1,3)+1));
              if  instr(l_attachment_string,'&',1,5) > 0 then
                l_pk2_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,5)+1,
                        instr(l_attachment_string,'&',1,5)-(instr(l_attachment_string,'=',1,5)+1));
                 if  instr(l_attachment_string,'&',1,7) > 0 then
                    l_pk3_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,7)+1,
                        instr(l_attachment_string,'&',1,7)-(instr(l_attachment_string,'=',1,7)+1));
                    if  instr(l_attachment_string,'&',1,9) > 0 then
                         l_pk4_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,9)+1,
                         instr(l_attachment_string,'&',1,9)-(instr(l_attachment_string,'=',1,9)+1));
                       if  instr(l_attachment_string,'&',1,11) > 0 then
                              l_pk5_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,11)+1,
                              instr(l_attachment_string,'&',1,11)-(instr(l_attachment_string,'=',1,11)+1));
                       else
                           l_pk5_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,11)+1);
                       end if;
                    else
                      l_pk4_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,9)+1);
                    end if;
                 else
                   l_pk3_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,7)+1);
                 end if;
               else
                l_pk2_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,5)+1);
               end if;
           else
               l_pk1_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,3)+1);
           END IF; */


     --The new parsing technique would take care of the category attribute if it exists.
           if  instr(l_attachment_string,'&',1,3) > 0 then
                l_pk1_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,3)+1,
            instr(l_attachment_string,'&',1,3)-(instr(l_attachment_string,'=',1,3)+1));
              if  instr(l_attachment_string,'&',1,5) > 0 then
                l_pk2_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,5)+1,
                        instr(l_attachment_string,'&',1,5)-(instr(l_attachment_string,'=',1,5)+1));
                 if  instr(l_attachment_string,'&',1,7) > 0 then
                    l_pk3_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,7)+1,
                        instr(l_attachment_string,'&',1,7)-(instr(l_attachment_string,'=',1,7)+1));
                    if  instr(l_attachment_string,'&',1,9) > 0 then
                         l_pk4_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,9)+1,
                         instr(l_attachment_string,'&',1,9)-(instr(l_attachment_string,'=',1,9)+1));
                       if  instr(l_attachment_string,'&',1,11) > 0 then
                              l_pk5_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,11)+1,
                              instr(l_attachment_string,'&',1,11)-(instr(l_attachment_string,'=',1,11)+1));

                              if(instr(l_attachment_string,'=',1,12) > 0) then
                                l_category_name := substr(l_attachment_string,instr(l_attachment_string,'=',1,12)+1);
                              end if;
                       else

       if(instr(l_attachment_string,'&',1,10) > 0 and instr(l_attachment_string,'=',1,11) >0) then
         l_pk5_value := substr(l_attachment_string,instr(l_attachment_string,'=',1,11)+1);

       elsif(instr(l_attachment_string,'&',1,9) > 0 and instr(l_attachment_string,'=',1,10) > 0) then
         l_category_name := substr(l_attachment_string,instr(l_attachment_string,'=',1,10)+1);

       end if;

           end if;

                    else

          if(instr(l_attachment_string,'&',1,8) > 0 and instr(l_attachment_string,'=',1,9) >0) then
                        l_pk4_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,9)+1);

          elsif(instr(l_attachment_string,'&',1,7) > 0 and instr(l_attachment_string,'=',1,8) > 0) then
      l_category_name := substr(l_attachment_string,instr(l_attachment_string,'=',1,8)+1);
                      end if;

                    end if;
                 else
       if(instr(l_attachment_string,'&',1,6) > 0 and instr(l_attachment_string,'=',1,7) >0) then
                     l_pk3_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,7)+1);

             elsif(instr(l_attachment_string,'&',1,5) > 0 and instr(l_attachment_string,'=',1,6) > 0) then
         l_category_name := substr(l_attachment_string,instr(l_attachment_string,'=',1,6)+1);

                   end if;

                 end if;

               else
           if(instr(l_attachment_string,'&',1,4) > 0 and instr(l_attachment_string,'=',1,5) >0) then
                   l_pk2_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,5)+1);

           elsif(instr(l_attachment_string,'&',1,3) > 0 and instr(l_attachment_string,'=',1,4) > 0) then
       l_category_name := substr(l_attachment_string,instr(l_attachment_string,'=',1,4)+1);

                 end if;
               end if;
           else
               l_pk1_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,3)+1);
           END IF;
  --Bug 4006844: End


        wf_log_pkg.string(6, 'Copy Attachments...','pk1....'||l_pk1_value);
    wf_log_pkg.string(6, 'Copy Attachments...','pk2....'||l_pk2_value);
    wf_log_pkg.string(6, 'Copy Attachments...','pk3....'||l_pk3_value);
    wf_log_pkg.string(6, 'Copy Attachments...','pk4....'||l_pk4_value);
    wf_log_pkg.string(6, 'Copy Attachments...','pk5....'||l_pk5_value);

  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;
  l_erecord_id := p_target_value;

   /* obtain the category id of the document category 'ERES' */
  select category_id into l_eres_category_id
  from fnd_document_categories_vl
  where name = 'ERES';

        --Bug 4006844: Start
  --Obtain the ID of the document category specified in workflow.
  if(l_category_name is not null) then
      select category_id into l_category_id
    from fnd_document_categories_vl
    where name = l_category_name;
  end if;
        --Bug 4006844: End



  wf_log_pkg.string(6, 'Copy Attachments...','Category....'||l_eres_category_id);
      --Bug 4381237: Start
      --fnd_attached_documents2_pkg.copy_attachments(
      edr_attachments_grp.copy_attachments(
      --Bug 4381237: End
        X_from_entity_name    => l_entity_name,
        X_from_pk1_value      => l_pk1_value,
        X_from_pk2_value      => l_pk2_value,
        X_from_pk3_value      => l_pk3_value,
        X_from_pk4_value      => l_pk4_value,
        X_from_pk5_value      => l_pk5_value,
        X_to_entity_name      => 'ERECORD',
        X_to_pk1_value      => l_erecord_id,
        X_to_pk2_value      => null,
        X_to_pk3_value      => null,
        X_to_pk4_value      => null,
        X_to_pk5_value      => null,
        X_created_by      => l_user_id,
        X_last_update_login     => l_login_id,
        X_program_application_id  => null,
        X_program_id      => null,
        X_request_id      => null,
        X_automatically_added_flag  => 'N',
                            --Bug 4006844: Start
          --Pass the category ID
          X_from_category_id            => l_category_id,
          --Bug 4006844: End
                X_to_category_id              => l_eres_category_id);
  wf_log_pkg.string(6, 'Copy Attachments...','Copy Completed');

           return true;
EXCEPTION
 WHEN OTHERS then
 return false;
END COPY_NTF_ATTACHMENTS;

/* Document Creation Procedure
   IN:
    PSIG_XML
    PSIG_DOCUMENT
    PSIG_DOCUMENTFORMAT
    PSIG_REQUESTER
    PSIG_SOURCE
    EVENT_NAME
    EVENT_KEY
   Description :
    This procedure will create a document instance for signature and can associate signatures
    before closing the docuemnt

*/

PROCEDURE openDocument
( P_PSIG_XML      IN    CLOB   DEFAULT NULL ,
  P_PSIG_DOCUMENT   IN    CLOB   DEFAULT NULL ,
  P_PSIG_DOCUMENTFORMAT IN    VARCHAR2 DEFAULT NULL ,
  P_PSIG_REQUESTER  IN    VARCHAR2    ,
  P_PSIG_SOURCE     IN    VARCHAR2 DEFAULT NULL ,
  P_EVENT_NAME    IN    VARCHAR2 DEFAULT NULL ,
  P_EVENT_KEY     IN    VARCHAR2 DEFAULT NULL ,
  p_WF_NID              IN    NUMBER   DEFAULT NULL ,
  P_DOCUMENT_ID         OUT NOCOPY  NUMBER      ,
  P_ERROR               OUT NOCOPY  NUMBER      ,
  P_ERROR_MSG           OUT NOCOPY  VARCHAR2
)
IS
  l_document_id NUMBER;
  l_document CLOB;
  l_xml CLOB;
  l_temp varchar2(32767);
  l_end_of_msgbody varchar2(1);
  l_msg varchar2(32000);
  l_status boolean;

  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);
  l_ackn_id number;
  l_server_timezone varchar2(240);
  l_doc_format varchar2(100);

  l_doc_req_disp_name varchar2(360); -- Bug : 3604783

  L_CREATION_DATE       	 DATE;
  L_CREATED_BY           	 NUMBER;
  L_LAST_UPDATE_DATE    	 DATE;
  L_LAST_UPDATED_BY     	 NUMBER;
  L_LAST_UPDATE_LOGIN   	 NUMBER;

BEGIN
       --Bug 4073809 : start
  l_document := empty_clob();
  l_end_of_msgbody := 'N';
       --Bug 4073809 : end

  wf_notification.newclob(l_document,l_msg);

      /* Check if Server time Zone is set to NULL and if error out */
          VERIFY_TIMEZONE(X_TIMEZONE =>l_server_timezone,
                          X_ERROR => P_ERROR,
                          X_ERROR_MSG =>P_ERROR_MSG);

      if P_ERROR > 0  then
          RAISE TIMEZONE_ERROR;
      end if;

        if P_WF_NID is NULL then
           /* Assign passed Document to l_document */
            l_document:=   P_PSIG_DOCUMENT;
        else
             /* Begin Bug Fix 3142631*/
    /* Check the Document_type */
              if (P_PSIG_DOCUMENTFORMAT is NULL
                                        or P_PSIG_DOCUMENTFORMAT ='TEXT'
                                        or P_PSIG_DOCUMENTFORMAT = WF_NOTIFICATION.doc_text) THEN
                 l_doc_format:=WF_NOTIFICATION.doc_text;
              elsif ( P_PSIG_DOCUMENTFORMAT = 'HTML' or P_PSIG_DOCUMENTFORMAT = WF_NOTIFICATION.doc_html)  THEN
                 l_doc_format:=WF_NOTIFICATION.doc_html;
              else
                fnd_message.set_name('EDR','EDR_PSIG_WFNTF_DOCFORMAT');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_WFNTF_FORMAT');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
              end if;
           /* End Bug Fix 3142631*/

            /* User requested to use Workflow notification body as text */
            BEGIN
      while (l_end_of_msgbody <> 'Y') Loop
          wf_notification.GetFullBodyWrapper
          ( NID     => P_WF_NID ,
        msgbody   => l_msg  ,
        end_of_body => l_end_of_msgbody,
                    disptype    => l_doc_format
          );
          wf_log_pkg.string(6, 'EDR_PSIG_rule.psig_rule','l_msg '|| l_msg);
          wf_notification.writetoclob(l_document,l_msg);
      end loop;
            EXCEPTION
              WHEN OTHERS then
                fnd_message.set_name('EDR','EDR_PSIG_WFNTF_ERROR');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_WFNTF_ERROR');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
            END;
        end if;

        /* Generate a new Document ID */
        select EDR_PSIG_DOCUMENTS_S.nextval into l_document_id from dual;

       /* Attachments Bug Fix. Added if statement */
       if P_WF_NID is not NULL then
         /* capture Attachemnts if Exists */
         l_status:= COPY_NTF_ATTACHMENTS
                   ( p_nid          => P_WF_NID   ,
         p_target_value   => l_document_id
       );
       END IF;

        /* Insert the document in pending status */
        /* Recieve the CLOB */
        l_XML:=P_PSIG_XML;

  -- Bug 3604783 : Start
  -- Find the document requester's display name
  l_doc_req_disp_name := edr_utilities.getuserdisplayname(p_psig_requester);

  --Bug 4672801: start
  EDR_UTILITIES.getWhoColumns
  ( creation_date 	=> l_creation_date	,
    created_by    	=> l_created_by		,
    last_update_date	=> l_last_update_date	,
    last_updated_by	=> l_last_updated_by	,
    last_update_login	=> l_last_update_login
  );
  --Bug 4672801: end

  --Insert the row
  INSERT into EDR_PSIG_DOCUMENTS
  (
    DOCUMENT_ID   ,
    PSIG_XML    ,
    PSIG_DOCUMENT   ,
    PSIG_DOCUMENTFORMAT ,
    PSIG_TIMESTAMP    ,
    PSIG_TIMEZONE   ,
    DOCUMENT_REQUESTER  ,
    DOC_REQ_DISP_NAME ,
    PSIG_STATUS   ,
    PSIG_SOURCE   ,
    EVENT_NAME    ,
    --Bug 4672801: start
    --EVENT_KEY
    EVENT_KEY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
    --Bug 4672801: end
  )
  values
  (
    l_document_id   ,
    L_XML     ,
    l_document    ,
    P_PSIG_DOCUMENTFORMAT ,
    sysdate     ,
    l_server_timezone ,
    P_PSIG_REQUESTER  ,
    L_DOC_REQ_DISP_NAME ,
    'PENDING'   ,
    P_PSIG_SOURCE   ,
    P_EVENT_NAME    ,
    --Bug 4672801: start
    --P_EVENT_KEY
    P_EVENT_KEY,
    l_CREATION_DATE,
    l_CREATED_BY,
    l_LAST_UPDATE_DATE,
    l_LAST_UPDATED_BY,
    l_LAST_UPDATE_LOGIN
    --Bug 4672801: end
  );

  -- Bug 3604783 : End

        p_document_id:=l_document_id;

        -- after inserting a row in the erecord table, insert a row in the
        -- acknowledgement table with the default ack status of NOTACKNOWLEDGED
        -- we dont have to do any validation at all as erecord id is valid
        -- we just created it, status is valid, there is no risk of duplicate
        -- ack status for this erecord as its just created in the step above

  EDR_TRANS_ACKN_PVT.INSERT_ROW
  ( p_api_version          => 1.0         ,
    p_init_msg_list  => FND_API.G_TRUE        ,
    p_validation_level   => FND_API.G_VALID_LEVEL_NONE    ,
    x_return_status  => l_return_status     ,
    x_msg_count    => l_msg_count       ,
    x_msg_data     => l_msg_data        ,
    p_erecord_id           => l_document_id     ,
    p_trans_status   => EDR_CONSTANTS_GRP.g_no_ack_status ,
    p_ackn_by              => null        ,
    p_ackn_note          => null        ,
    x_ackn_id              => l_ackn_id
  );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
      WHEN EDR_GENERIC_ERROR then
             NULL;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      l_msg_count     ,
             p_data           =>      l_msg_data
        );

        p_error   := 22000;
        P_ERROR_MSG   := l_msg_data ;
        WHEN TIMEZONE_ERROR then
            NULL;
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END openDocument;

/* Document Creation Procedure over loaded
   IN:
   Description :
   This procedure will create a document instance for signature and can associate signatures
   before closing the docuemnt

*/

PROCEDURE openDocument
  (
         P_DOCUMENT_ID          OUT NOCOPY NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  ) IS
l_document_id NUMBER;
l_document CLOB;
l_xml CLOB;
l_temp varchar2(32767);
l_end_of_msgbody varchar2(1);
l_msg varchar2(32000);
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);
l_ackn_id number;
l_server_timezone varchar2(240);

L_CREATION_DATE       	 DATE;
L_CREATED_BY           	 NUMBER;
L_LAST_UPDATE_DATE    	 DATE;
L_LAST_UPDATED_BY     	 NUMBER;
L_LAST_UPDATE_LOGIN   	 NUMBER;

BEGIN
       --Bug 4073809 : start
  l_document := empty_clob();
  l_end_of_msgbody := 'N';
       --Bug 4073809 : end



      wf_notification.newclob(l_document,l_msg);
        /* Check if Server time Zone is set to NULL and if error out */
          VERIFY_TIMEZONE(X_TIMEZONE =>l_server_timezone,
                          X_ERROR => P_ERROR,
                          X_ERROR_MSG =>P_ERROR_MSG);

      if P_ERROR > 0  then
          RAISE TIMEZONE_ERROR;
      end if;

        --Generate a new Document ID
        select EDR_PSIG_DOCUMENTS_S.nextval into l_document_id from dual;

        --Bug 4672801: start
        EDR_UTILITIES.getWhoColumns
        ( creation_date 	=> l_creation_date	,
          created_by    	=> l_created_by		,
          last_update_date	=> l_last_update_date	,
          last_updated_by	=> l_last_updated_by	,
          last_update_login	=> l_last_update_login
        );
        --Bug 4672801: end

        --Insert the document in pending status
        INSERT into EDR_PSIG_DOCUMENTS
        (DOCUMENT_ID,
         PSIG_STATUS,
         PSIG_TIMESTAMP,
         --Bug 4672801: start
         --PSIG_TIMEZONE
         PSIG_TIMEZONE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN
        --Bug 4672801: end
        )
        values
        (l_document_id,
         'PENDING',
         sysdate,
         --Bug 4672801: start
         --l_server_timezone
         l_server_timezone,
         l_CREATION_DATE,
         l_CREATED_BY,
         l_LAST_UPDATE_DATE,
         l_LAST_UPDATED_BY,
         l_LAST_UPDATE_LOGIN
         --Bug 4672801: end
        );

        p_document_id:=l_document_id;

        p_document_id:=l_document_id;

        -- after inserting a row in the erecord table, insert a row in the
        -- acknowledgement table with the default ack status of NOTACKNOWLEDGED
        -- we dont have to do any validation at all as erecord id is valid
        -- we just created it, status is valid, there is no risk of duplicate
        -- ack status for this erecord as its just created in the step above

  EDR_TRANS_ACKN_PVT.INSERT_ROW
  ( p_api_version          => 1.0         ,
    p_init_msg_list  => FND_API.G_TRUE        ,
    p_validation_level   => FND_API.G_VALID_LEVEL_NONE    ,
    x_return_status  => l_return_status     ,
    x_msg_count    => l_msg_count       ,
    x_msg_data     => l_msg_data        ,
    p_erecord_id           => l_document_id     ,
    p_trans_status   => EDR_CONSTANTS_GRP.g_no_ack_status ,
    p_ackn_by              => null        ,
    p_ackn_note          => null        ,
    x_ackn_id              => l_ackn_id
  );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      l_msg_count     ,
             p_data           =>      l_msg_data
        );
        p_error   := 22000;
        P_ERROR_MSG   := l_msg_data ;

        WHEN TIMEZONE_ERROR then
             NULL;
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END openDocument;

PROCEDURE changeDocumentstatus
  (
         P_DOCUMENT_ID          IN  NUMBER,
         P_STATUS               IN VARCHAR2,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  ) IS
l_status varchar2(240);
L_LAST_UPDATE_DATE    	 DATE;
L_LAST_UPDATED_BY     	 NUMBER;
L_LAST_UPDATE_LOGIN   	 NUMBER;
CURSOR C1 is
SELECT count(*) from EDR_PSIG_DETAILS
WHERE document_id =P_DOCUMENT_ID AND
      SIGNATURE_STATUS='PENDING';
l_count number;
BEGIN
  /*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
  /*12-26-2002 End*/
       /* CHECK if document Status is Valid */
       IF UPPER(P_STATUS) NOT IN ('CANCEL','COMPLETE','ERROR','PENDING','REJECTED','TIMEDOUT') then
          RAISE EDR_INVALID_DOC_STATUS;
       END IF;

      /* Check if document is existing */

       GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>P_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF P_ERROR > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
        IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
           RAISE EDR_INVALID_DOC_TRAN;
        END IF;

         IF UPPER(P_STATUS) = 'COMPLETE' THEN
            /* Check if there are any pending signatures */
           OPEN C1;
             FETCH C1 into l_count;
           CLOSE C1;

           IF l_count > 0 THEN
                fnd_message.set_name('EDR','EDR_PSIG_DOC_SIGNATURES');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_DOC_SIGNATURES');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
           END IF;
          END IF;


           -- Document Exist
           UPDATE EDR_PSIG_DOCUMENTS
           set PSIG_STATUS=UPPER(p_STATUS),
           --Bug 4672801: start
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id(),
           last_update_login = fnd_global.login_id()
           --Bug 4672801: end
           where DOCUMENT_ID=P_DOCUMENT_ID;

     --Bug 3101047: Start
     if UPPER(p_status) in ('CANCEL','REJECTED') then
    EDR_PSIG.UPDATE_PSIG_USER_DETAILS( P_DOCUMENT_ID  => P_DOCUMENT_ID);
     end if;
       --Bug 3101047: End

EXCEPTION
        WHEN EDR_GENERIC_ERROR then
             NULL;
        WHEN EDR_INVALID_DOC_TRAN then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                fnd_message.set_token('FROM',l_status);
                fnd_message.set_token('TO',p_status);
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                P_ERROR_MSG:= fnd_message.get();
        WHEN EDR_INVALID_DOC_STATUS then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOC_STATUS');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOC_STATUS');
                P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END changeDocumentstatus;

/* Document Update Procedure
   IN:
    PSIG_XML
    PSIG_DOCUMENT
    PSIG_DOCUMENTFORMAT
    PSIG_REQUESTER
    PSIG_SOURCE
    EVENT_NAME
    EVENT_KEY
    DOCUMENT_ID
   Description :
    This procedure will update a docuemnt

*/

PROCEDURE updateDocument
  (
         P_DOCUMENT_ID            IN NUMBER,
     P_PSIG_XML         IN CLOB DEFAULT NULL,
         P_PSIG_DOCUMENT      IN CLOB DEFAULT NULL,
         P_PSIG_DOCUMENTFORMAT    IN VARCHAR2 DEFAULT NULL,
         P_PSIG_REQUESTER   IN VARCHAR2,
         P_PSIG_SOURCE        IN VARCHAR2 DEFAULT NULL,
         P_EVENT_NAME       IN VARCHAR2 DEFAULT NULL,
         P_EVENT_KEY        IN VARCHAR2 DEFAULT NULL,
         p_WF_NID                 IN NUMBER   DEFAULT NULL,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  ) IS
l_document_id NUMBER;
l_document CLOB;
l_xml CLOB;
l_temp varchar2(32767);
l_end_of_msgbody varchar2(1);
l_msg varchar2(32000);
l_count number;
l_status varchar2(240);
l_doc_format varchar2(240);
l_doc_req_disp_name varchar2(360); -- Bug 3604783

BEGIN

       --Bug 4073809 : start
  l_document := empty_clob();
  l_end_of_msgbody := 'N';
       --Bug 4073809 : end



/*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
/*12-26-2002 End*/

/* Check if document is existing */

       GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>P_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF P_ERROR > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
        IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
           RAISE EDR_INVALID_DOC_TRAN;
        END IF;

      wf_notification.newclob(l_document,l_msg);
      if P_WF_NID is NULL then
         /* Assign passed Document to l_document */
          l_document:=   P_PSIG_DOCUMENT;
      else

          /* Begin Bug Fix 3142631*/
    /* Check the Document_type */
            if (P_PSIG_DOCUMENTFORMAT is NULL
                                        or P_PSIG_DOCUMENTFORMAT ='TEXT'
                                        or P_PSIG_DOCUMENTFORMAT = WF_NOTIFICATION.doc_text) THEN
                 l_doc_format:=WF_NOTIFICATION.doc_text;
              elsif ( P_PSIG_DOCUMENTFORMAT = 'HTML' or P_PSIG_DOCUMENTFORMAT = WF_NOTIFICATION.doc_html)  THEN
                 l_doc_format:=WF_NOTIFICATION.doc_html;
              else
                fnd_message.set_name('EDR','EDR_PSIG_WFNTF_DOCFORMAT');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_WFNTF_FORMAT');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
              end if;

           /* End Bug Fix 3142631*/

            /* User requested to use Workflow notification body as text */
            BEGIN
      while (l_end_of_msgbody <> 'Y') Loop
          wf_notification.GetFullBodyWrapper
          ( NID     => P_WF_NID ,
        msgbody   => l_msg  ,
        end_of_body => l_end_of_msgbody,
                    disptype    => l_doc_format
          );
          wf_log_pkg.string(6, 'EDR_PSIG_rule.psig_rule','l_msg '|| l_msg);
          wf_notification.writetoclob(l_document,l_msg);
      end loop;
            EXCEPTION
              WHEN OTHERS then
                fnd_message.set_name('EDR','EDR_PSIG_WFNTF_ERROR');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_WFNTF_ERROR');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
            END;
        end if;
         /* Recieve the CLOB */
             l_XML:=P_PSIG_XML;

  -- Bug 3604783 : Start
  /* Recieve the document requester's display name */
    l_doc_req_disp_name := edr_utilities.getuserdisplayname(p_psig_requester);

         update EDR_PSIG_DOCUMENTS
         set
         PSIG_XML=l_xml,
         PSIG_DOCUMENT=l_document,
         PSIG_DOCUMENTFORMAT=P_PSIG_DOCUMENTFORMAT,
         DOCUMENT_REQUESTER=p_PSIG_REQUESTER,
         DOC_REQ_DISP_NAME=DECODE(DOC_REQ_DISP_NAME, NULL,
         L_DOC_REQ_DISP_NAME, DOC_REQ_DISP_NAME),
         PSIG_SOURCE=P_PSIG_SOURCE,
         EVENT_NAME=P_EVENT_NAME,
         EVENT_KEY=P_EVENT_KEY,
         --Bug 4672801: start
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id(),
         last_update_login = fnd_global.login_id()
         --Bug 4672801: end
         where DOCUMENT_ID=P_DOCUMENT_ID;
  -- Bug 3604783 : End

EXCEPTION
          WHEN EDR_GENERIC_ERROR then
             NULL;
        WHEN EDR_INVALID_DOC_TRAN then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                fnd_message.set_token('FROM',l_status);
                fnd_message.set_token('TO','COMPLETE');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                P_ERROR_MSG:= fnd_message.get();
        WHEN EDR_INVALID_DOC_STATUS then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOC_STATUS');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOC_STATUS');
                P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;


END updateDocument;

/* Close Document
   IN:
    P_DOCUMENT_ID


*/

PROCEDURE closeDocument
  (
         P_DOCUMENT_ID          IN  NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  ) IS
l_status varchar2(240);
CURSOR C1 is
SELECT count(*) from EDR_PSIG_DETAILS
WHERE document_id =P_DOCUMENT_ID AND
      SIGNATURE_STATUS='PENDING';
l_count number;
BEGIN
  /*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
  /*12-26-2002 End*/

      /* Check if document is existing */

       GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>P_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
        IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
           RAISE EDR_INVALID_DOC_TRAN;
        END IF;

         /* Check if there are any pending signatures */
           OPEN C1;
             FETCH C1 into l_count;
           CLOSE C1;

           IF l_count > 0 THEN
                fnd_message.set_name('EDR','EDR_PSIG_DOC_SIGNATURES');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_DOC_SIGNATURES');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
           END IF;

           /* Document Exist */
           UPDATE EDR_PSIG_DOCUMENTS
           set PSIG_STATUS='COMPLETE',
           --Bug 4672801: start
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id(),
           last_update_login = fnd_global.login_id()
           --Bug 4672801: end
           where DOCUMENT_ID=P_DOCUMENT_ID;

EXCEPTION
        WHEN EDR_GENERIC_ERROR then
             NULL;
        WHEN EDR_INVALID_DOC_TRAN then
             fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                fnd_message.set_token('FROM',l_status);
                fnd_message.set_token('TO','COMPLETE');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END closeDocument;



/* Cancel Document
   IN:
    P_DOCUMENT_ID

*/

PROCEDURE cancelDocument
  (
         P_DOCUMENT_ID          IN  NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  ) AS
l_status varchar2(240);

BEGIN
  /*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
  /*12-26-2002 End*/

      /* Check if document is existing */

       GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>P_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
        IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
           RAISE EDR_INVALID_DOC_TRAN;
        END IF;

           /* Document Exist */
           UPDATE EDR_PSIG_DOCUMENTS
           set PSIG_STATUS='CANCEL',
           --Bug 4672801: start
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id(),
           last_update_login = fnd_global.login_id()
           --Bug 4672801: end
           where DOCUMENT_ID=P_DOCUMENT_ID;

EXCEPTION
        WHEN EDR_GENERIC_ERROR then
             NULL;
        WHEN EDR_INVALID_DOC_TRAN then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                fnd_message.set_token('FROM',l_status);
                fnd_message.set_token('TO','CANCEL');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOC_TRAN');
                P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END cancelDocument;

/* Post Signatures
   IN:
    P_DOCUMENT_ID
    P_EVIDENCE_STORE_ID
    P_USER_NAME
    P_USER_RESPONSE

*/

--Bug 3330240 : start
--adding new in parameters
--P_SIGNATURE_SEQUENCE
--P_ADHOC_STATUS

PROCEDURE requestSignature
         (
            P_DOCUMENT_ID            IN NUMBER,
      P_USER_NAME              IN VARCHAR2,
            P_ORIGINAL_RECIPIENT     IN VARCHAR2 DEFAULT NULL,
            P_OVERRIDING_COMMENTS    IN VARCHAR2 DEFAULT NULL,
            P_SIGNATURE_SEQUENCE     IN NUMBER DEFAULT NULL,
            P_ADHOC_STATUS           IN VARCHAR2 DEFAULT NULL,
            P_SIGNATURE_ID         OUT NOCOPY NUMBER,
            P_ERROR                OUT NOCOPY NUMBER,
            P_ERROR_MSG            OUT NOCOPY VARCHAR2
          ) IS
--bug 3330240 : end
l_status varchar2(240);
l_usrstatus boolean;
l_signature_id NUMBER;
l_cpint Number;
l_count number;
l_server_timezone varchar2(240);
--Bug 3330240 :Start
-- we need to check the uniquencess of user now on adhoc_status also
-- default signer can now have two rows with ADHOC_STATUS as DELETED
-- and ADDED also
/*
CURSOR C1 is
Select count(*)
from EDR_PSIG_DETAILS
where document_id=p_document_id and
      USER_NAME=P_USER_NAME and
      NVL(ORIGINAL_RECIPIENT,0)=NVL(P_ORIGINAL_RECIPIENT,0);
*/
CURSOR C1 is
Select count(*)
from EDR_PSIG_DETAILS
where document_id=p_document_id and
      USER_NAME=P_USER_NAME and
      NVL(ORIGINAL_RECIPIENT,0)=NVL(P_ORIGINAL_RECIPIENT,0) and
      NVL(ADHOC_STATUS,'0') <> 'DELETED';

l_signer_seq number :=0;
--Bug 3330240: end

BEGIN
/*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
/*12-26-2002 End*/

  /* Check if Server time Zone is set to NULL and if error out */
          VERIFY_TIMEZONE(X_TIMEZONE =>l_server_timezone,
                          X_ERROR => P_ERROR,
                          X_ERROR_MSG =>P_ERROR_MSG);

      if P_ERROR > 0  then
          RAISE TIMEZONE_ERROR;
      end if;

/*Check the validity of user */
      VALIDATE_USER           (P_USER =>P_USER_NAME,
                              X_STATUS =>L_usrSTATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);
       IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
     IF P_ORIGINAL_RECIPIENT IS NOT NULL THEN
      VALIDATE_USER(P_USER =>P_ORIGINAL_RECIPIENT,
                              X_STATUS =>L_usrSTATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
      END IF;

/* Check if document is existing */

       GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>P_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
        IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
           RAISE EDR_INVALID_SIGN_REQUEST;
        END IF;
          /* Document Exist
          Check Duplicate Rows */
          OPEN c1;
          fetch c1 into l_count;
          CLOSE C1;
          IF l_count > 0 THEN
              RAISE EDR_DUPLICATE_SIGNER;
        END IF;


        --Bug 3330240: start
        --If the signature_sequence is not present in the argument
        --get the max and then add 1
        --raise error if the signature sequence is passed as 0
         IF (P_SIGNATURE_SEQUENCE is null ) then
            select (nvl(max(signature_sequence),0) +1) into l_signer_seq from edr_psig_details
            where document_id = P_DOCUMENT_ID;
         ELSIF ( P_SIGNATURE_SEQUENCE <= 0) THEN
             fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNATURE_SEQ');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNATURE_SEQ');
             P_ERROR_MSG:= fnd_message.get();
             RAISE EDR_GENERIC_ERROR;
         ELSE
             l_signer_seq := P_SIGNATURE_SEQUENCE;
         END IF;
         --verify the adhoc status value if its not null
         --adhoc status should be ADDED or DELETED only
         IF (P_ADHOC_STATUS is not null) then
             IF (P_ADHOC_STATUS not in ('ADDED','DELETED') ) then
                 fnd_message.set_name('EDR','EDR_PSIG_INVALID_ADHOC_STATUS');
                 P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_ADHOC_STATUS');
                 P_ERROR_MSG:= fnd_message.get();
                 RAISE EDR_GENERIC_ERROR;
             END IF;
         END IF;

        --Bug 3330240 : end
            /* Get New Signature Id */
              select EDR_PSIG_DETAILS_S.nextval into l_signature_id from dual;
           /* Insert signature Details */

         --Bug 3330240 : Start
         --Inert the adhoc_status, signature_sequence also
         -- and also the 5 WHO columns
         /*
           INSERT into EDR_PSIG_DETAILS
                  (
      SIGNATURE_ID,
      DOCUMENT_ID,
      USER_NAME,
                        ORIGINAL_RECIPIENT,
                        SIGNATURE_OVERRIDING_COMMENTS,
      SIGNATURE_STATUS
                  )
           values
                  (
              L_SIGNATURE_ID,
      P_DOCUMENT_ID,
      P_USER_NAME,
                  P_ORIGINAL_RECIPIENT,
                  P_OVERRIDING_COMMENTS,
      'PENDING'
                  );
        */
           INSERT into EDR_PSIG_DETAILS
                  (
                        SIGNATURE_ID,
                        DOCUMENT_ID,
                        USER_NAME,
                        ORIGINAL_RECIPIENT,
                        SIGNATURE_OVERRIDING_COMMENTS,
                        SIGNATURE_STATUS,
                        CREATION_DATE,
                        CREATED_BY ,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN ,
                        ADHOC_STATUS,
                        SIGNATURE_SEQUENCE
                  )
           values
                  (
                        L_SIGNATURE_ID,
                        P_DOCUMENT_ID,
                        P_USER_NAME,
                        P_ORIGINAL_RECIPIENT,
                        P_OVERRIDING_COMMENTS,
                        'PENDING',
                        SYSDATE,
                        FND_GLOBAL.USER_ID,
                        SYSDATE,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID,
                        P_ADHOC_STATUS,
                        l_signer_seq
                  );
          --Bug 3330240 : end
        P_SIGNATURE_ID:=l_SIGNATURE_ID;
EXCEPTION
        WHEN EDR_GENERIC_ERROR then
             NULL;
        WHEN TIMEZONE_ERROR then
             NULL;
       WHEN EDR_INVALID_SIGN_REQUEST then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGN_REQUEST');
                fnd_message.set_token('STATUS',L_STATUS);
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGN_REQUEST');
                P_ERROR_MSG:= fnd_message.get();
       WHEN EDR_DUPLICATE_SIGNER then
                fnd_message.set_name('EDR','EDR_PSIG_DUPLICATE_SIGNER');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_DUPLICATE_SIGNER');
                P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END requestSignature;

/* Post Signatures
   IN:
    P_DOCUMENT_ID
    P_EVIDENCE_STORE_ID
    P_USER_NAME
    P_USER_RESPONSE

*/


PROCEDURE postSignature
         (
            P_DOCUMENT_ID            IN NUMBER,
        P_EVIDENCE_STORE_ID      IN VARCHAR2,
        P_USER_NAME              IN VARCHAR2,
        P_USER_RESPONSE          IN VARCHAR2,
            P_ORIGINAL_RECIPIENT     IN VARCHAR2 DEFAULT NULL,
            P_OVERRIDING_COMMENTS    IN VARCHAR2 DEFAULT NULL,
            P_SIGNATURE_ID         OUT NOCOPY NUMBER,
            P_ERROR                OUT NOCOPY NUMBER,
            P_ERROR_MSG            OUT NOCOPY VARCHAR2
          ) IS

l_status varchar2(240);
l_usrstatus boolean;
l_signature_id NUMBER;
l_server_timezone varchar2(240);

--Bug 3101047 : Start
l_user_display_name VARCHAR2(360);
l_orig_system VARCHAR2(240);
l_orig_system_id NUMBER;
--Bug 3101047 : End

--Bug 3330240 : start
--we need to verify for signature_status CANCEL also
-- as if a default signer is deleted we put the status as CANCEL
/*
CURSOR C1 IS
select Signature_id from EDR_PSIG_DETAILS
             where DOCUMENT_ID=P_DOCUMENT_ID AND
                   decode(P_ORIGINAL_RECIPIENT,NULL,USER_NAME,ORIGINAL_RECIPIENT)
                          = nvl(P_ORIGINAL_RECIPIENT,P_USER_NAME)
                  AND SIGNATURE_STATUS <> 'COMPLETE';
*/

CURSOR C1 IS
select Signature_id from EDR_PSIG_DETAILS
             where DOCUMENT_ID=P_DOCUMENT_ID AND
                   decode(P_ORIGINAL_RECIPIENT,NULL,USER_NAME,ORIGINAL_RECIPIENT)
                          = nvl(P_ORIGINAL_RECIPIENT,P_USER_NAME)
                  AND SIGNATURE_STATUS not in ('COMPLETE','CANCEL');
l_pending_count number;
--Bug 3330240 : end

BEGIN
/*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
/*12-26-2002 End*/

  /* Check if Server time Zone is set to NULL and if error out */
          VERIFY_TIMEZONE(X_TIMEZONE =>l_server_timezone,
                          X_ERROR => P_ERROR,
                          X_ERROR_MSG =>P_ERROR_MSG);

      if P_ERROR > 0  then
          RAISE TIMEZONE_ERROR;
      end if;

    /*Check the validity of user */
        VALIDATE_USER         (P_USER =>P_USER_NAME,
                              X_STATUS =>L_usrSTATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);
        IF nvl(P_ERROR,0) > 0  THEN
            RAISE EDR_GENERIC_ERROR;
        END IF;
     IF P_ORIGINAL_RECIPIENT IS NOT NULL THEN
        VALIDATE_USER(P_USER =>P_ORIGINAL_RECIPIENT,
                              X_STATUS =>L_usrSTATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);
        IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
      END IF;

/* Check if document is existing */

       GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>P_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
        IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
           RAISE EDR_INVALID_SIGN_REQUEST;
        END IF;


        -- IF P_ORIGINAL_RECIPIENT is NULL THEN
         OPEN C1;
           FETCH C1 into l_signature_id;
           IF c1%NOTFOUND THEN
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGN_POST');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGN_POST');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
           END IF;
         CLOSE C1;

          --Bug 3330240 : start
          -- validate if the posting is in conjuction with the signature
          -- sequence

          select count(*) into l_pending_count from edr_psig_details
          where signature_status = 'PENDING'
          and signature_sequence < (select signature_sequence
                                    from edr_psig_details
                                    where signature_id = l_signature_id)
          and document_id = P_DOCUMENT_ID
          and adhoc_status <> 'DELETED';

          IF (l_pending_count > 0) THEN
              fnd_message.set_name('EDR','EDR_PSIG_PENDING_SIGNATURE');
              P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_PENDING_SIGNATURE');
              P_ERROR_MSG:= fnd_message.get();
              RAISE EDR_GENERIC_ERROR;
          END IF;
          -- we need to update the WHO columns also

           /* Above NVL logic is to make sure that we support old code */
           /* UPDATE signature Details */
           /*
           UPDATE EDR_PSIG_DETAILS
                  SET
      EVIDENCE_STORE_ID=P_EVIDENCE_STORE_ID,
      USER_RESPONSE=P_USER_RESPONSE,
                        ORIGINAL_RECIPIENT=nvl(P_ORIGINAL_RECIPIENT,ORIGINAL_RECIPIENT),
                        USER_NAME=P_USER_NAME,
                        SIGNATURE_OVERRIDING_COMMENTS=SIGNATURE_OVERRIDING_COMMENTS||' '||P_OVERRIDING_COMMENTS,
      SIGNATURE_TIMESTAMP=SYSDATE,
      SIGNATURE_TIMEZONE=l_server_timezone,
      SIGNATURE_STATUS='COMPLETE'
                  WHERE DOCUMENT_ID=P_DOCUMENT_ID AND
                   decode(P_ORIGINAL_RECIPIENT,NULL,USER_NAME,ORIGINAL_RECIPIENT)
                          =nvl(P_ORIGINAL_RECIPIENT,P_USER_NAME);
           */

     --Bug 3101047 : Start
         EDR_UTILITIES .getUserRoleInfo(p_user_name, l_user_display_name, l_orig_system, l_orig_system_id);
           UPDATE EDR_PSIG_DETAILS
                  SET
                        EVIDENCE_STORE_ID=P_EVIDENCE_STORE_ID,
                        USER_RESPONSE=P_USER_RESPONSE,
                        ORIGINAL_RECIPIENT=nvl(P_ORIGINAL_RECIPIENT,ORIGINAL_RECIPIENT),
                        USER_NAME=P_USER_NAME,
                        SIGNATURE_OVERRIDING_COMMENTS=SIGNATURE_OVERRIDING_COMMENTS||' '||P_OVERRIDING_COMMENTS,
                        SIGNATURE_TIMESTAMP=SYSDATE,
                        SIGNATURE_TIMEZONE=l_server_timezone,
                        SIGNATURE_STATUS='COMPLETE',
                        LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
                        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      USER_DISPLAY_NAME = L_USER_DISPLAY_NAME,
      ORIG_SYSTEM = L_ORIG_SYSTEM,
      ORIG_SYSTEM_ID = L_ORIG_SYSTEM_ID
                  WHERE SIGNATURE_ID = l_SIGNATURE_ID;
      --bug 3101047 : end

            --bug 3330240 : end
               P_SIGNATURE_ID:=l_SIGNATURE_ID;

EXCEPTION
        WHEN EDR_GENERIC_ERROR then
             NULL;
        WHEN TIMEZONE_ERROR then
             NULL;
       WHEN EDR_INVALID_SIGN_REQUEST then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGN_REQUEST');
                fnd_message.set_token('STATUS',L_STATUS);
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGN_REQUEST');
                P_ERROR_MSG:= fnd_message.get();
       WHEN EDR_DUPLICATE_SIGNER then
                fnd_message.set_name('EDR','EDR_PSIG_DUPLICATE_SIGNER');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_DUPLICATE_SIGNER');
                P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;

END postSignature;


/* Cancel Signature
   IN:
    P_SIGNATURE_ID


*/

PROCEDURE cancelSignature
  (
         P_SIGNATURE_ID          IN  NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  ) IS

l_document_id NUMBER;
l_status varchar2(240);
l_sig_status varchar2(100);
CURSOR C1
    is SELECT DOCUMENT_ID,SIGNATURE_STATUS
         from EDR_PSIG_DETAILS
          where SIGNATURE_ID = P_SIGNATURE_ID;
BEGIN
  /*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
  /*12-26-2002 End*/
     /* Check if Signature Row Exist */
         OPEN C1;
         FETCH C1 into l_document_id,l_sig_status;
         IF c1%NOTFOUND THEN
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNID');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNID');
                P_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
         END IF;
         CLOSE C1;
     /* Check if it's the row is in PENDING */
        IF l_sig_status = 'COMPLETE' THEN
           fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
           P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
           P_ERROR_MSG:= fnd_message.get();
           RAISE EDR_GENERIC_ERROR;
        END IF;

/* Check if document is existing */

       GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>L_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>P_ERROR,
                              X_ERROR_MSG =>P_ERROR_MSG);

        IF nvl(P_ERROR,0) > 0  THEN
           RAISE EDR_GENERIC_ERROR;
        END IF;
        IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
           RAISE EDR_INVALID_DOC_TRAN;
        END IF;

           /* Document Exist */
           --Bug 3330240 : start
           --update the WHO columns also
           /*
            UPDATE EDR_PSIG_DETAILS
              set SIGNATURE_STATUS='CANCEL'
              where SIGNATURE_ID=P_SIGNATURE_ID;
           */
           UPDATE EDR_PSIG_DETAILS
              set SIGNATURE_STATUS='CANCEL',
                  LAST_UPDATE_DATE=SYSDATE,
                  LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
                  LAST_UPDATE_LOGIN=FND_GLOBAL.LOGIN_ID
               where SIGNATURE_ID=P_SIGNATURE_ID;
          --Bug 3330240 : end
EXCEPTION
        WHEN EDR_GENERIC_ERROR then
             NULL;
        WHEN EDR_INVALID_DOC_TRAN then
           fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
           P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
           P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END cancelSignature;


/* Post Document Parameters */

PROCEDURE postDocumentParameter
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_PARAMETERS           IN  EDR_PSIG.params_table,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        )
IS
l_status varchar2(240);
i number;
l_parameter_id NUMBER;
L_ROWID ROWID;

BEGIN
  /*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
  /*12-26-2002 End*/

      /* Check if document is existing */
        SELECT  PSIG_STATUS into l_status
              from EDR_PSIG_DOCUMENTS
              where DOCUMENT_ID=P_DOCUMENT_ID;
        IF l_status in ('PENDING','ERROR') THEN
           /* Document Exist */
           /* Process Table and inser rows in Table */
            FOR i in 1.. P_PARAMETERS.count LOOP
                IF P_PARAMETERS(i).PARAM_NAME IS NOT NULL THEN
                   BEGIN
                   select parameter_id into l_parameter_id from EDR_PSIG_DOC_PARAMS_VL
                     where document_id=P_DOCUMENT_ID and
                           NAME=P_PARAMETERS(i).PARAM_NAME;
                   EDR_PSIG_DOC_PARAMS_PKG.UPDATE_ROW (
                                                                        X_PARAMETER_ID => L_PARAMETER_ID,
                      X_DOCUMENT_ID => P_DOCUMENT_ID,
                      X_NAME => P_PARAMETERS(i).PARAM_NAME,
                      X_VALUE => P_PARAMETERS(i).PARAM_VALUE,
                      X_DISPLAY_NAME =>                                                               NVL(P_PARAMETERS(i).PARAM_DISPLAYNAME,P_PARAMETERS(i).PARAM_NAME),
                      X_LAST_UPDATE_DATE => SYSDATE,
                      X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
                      X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);


                   EXCEPTION
                   WHEN NO_DATA_FOUND  then
                   /* Insert a ROW */
                        select EDR_PSIG_PARAMS_S.nextval into l_parameter_id from dual;
                        EDR_PSIG_DOC_PARAMS_PKG.INSERT_ROW(
                          X_ROWID => L_ROWID,
                      X_PARAMETER_ID => L_PARAMETER_ID,
                      X_DOCUMENT_ID => P_DOCUMENT_ID,
                      X_NAME => P_PARAMETERS(i).PARAM_NAME,
                      X_VALUE => P_PARAMETERS(i).PARAM_VALUE,
                      X_DISPLAY_NAME => NVL(P_PARAMETERS(i).PARAM_DISPLAYNAME,P_PARAMETERS(i).PARAM_NAME),
                      X_CREATION_DATE => SYSDATE,
                      X_CREATED_BY => FND_GLOBAL.USER_ID,
                      X_LAST_UPDATE_DATE => SYSDATE,
                      X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
                      X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);
                   END;
                 END IF;
             END LOOP;
           else
             raise DOCUMENT_CLOSE_ERROR;
          end if;

EXCEPTION
        WHEN DOCUMENT_CLOSE_ERROR then
             fnd_message.set_name('EDR','EDR_PSIG_DOC_CLOSED');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_DOC_CLOSED');
             P_ERROR_MSG:= fnd_message.get();
        WHEN NO_DATA_FOUND then
             fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOCUMENT');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOCUMENT');
             P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END postDocumentParameter;

/* Delete Document Parameters */

PROCEDURE deleteDocumentParameter
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_PARAMETER_NAME       IN  VARCHAR,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        )
IS

l_status varchar2(240);
i number;
l_parameter_id NUMBER;
L_ROWID ROWID;
BEGIN
             fnd_message.set_name('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR_MSG:= fnd_message.get();

END deleteDocumentParameter;


/* Delete All Document Parameters */

PROCEDURE deleteAllDocumentParams
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        )
IS
BEGIN
             fnd_message.set_name('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR_MSG:= fnd_message.get();END deleteAllDocumentParams;

/* Post Signature Parameters */


PROCEDURE postSignatureParameter
          (
           P_SIGNATURE_ID         IN  NUMBER,
           P_PARAMETERS           IN  EDR_PSIG.params_table,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        )
IS

l_status varchar2(240);
i number;
l_parameter_id NUMBER;
L_ROWID ROWID;
L_PARAM_NAME VARCHAR2(240);
CURSOR C1 IS
select parameter_id from EDR_PSIG_SIGN_PARAMS_VL
                     where signature_id=P_SIGNATURE_ID and
                           NAME=L_PARAM_NAME;

BEGIN
  /*12-26-2002 Start: Set the secure context to access edr_psig_documents table */
  edr_ctx_pkg.set_secure_attr;
  /*12-26-2002 End*/

      /* Check if document is existing */
        SELECT  PSIG_STATUS into l_status
              from EDR_PSIG_DOCUMENTS
              where DOCUMENT_ID in
              (select Document_id from EDR_PSIG_DETAILS
                 where signature_id=P_SIGNATURE_ID);
        IF l_status in ('PENDING','ERROR') THEN
           /* Document Exist */
           /* Process Table and inser rows in Table */
            FOR i in 1.. P_PARAMETERS.count LOOP
                IF P_PARAMETERS(i).PARAM_NAME IS NOT NULL THEN
                   L_PARAM_NAME:=P_PARAMETERS(i).PARAM_NAME;
                   OPEN C1;
                    FETCH C1 into l_parameter_id;
                    IF C1%NOTFOUND THEN
                   /* Insert a ROW */
                        select EDR_PSIG_PARAMS_S.nextval into l_parameter_id from dual;
                        EDR_PSIG_SIGN_PARAMS_PKG.INSERT_ROW(
                X_ROWID => L_ROWID,
              X_PARAMETER_ID => L_PARAMETER_ID,
              X_SIGNATURE_ID => P_SIGNATURE_ID,
              X_NAME => P_PARAMETERS(i).PARAM_NAME,
              X_VALUE => P_PARAMETERS(i).PARAM_VALUE,
              X_DISPLAY_NAME => NVL(P_PARAMETERS(i).PARAM_DISPLAYNAME,P_PARAMETERS(i).PARAM_NAME),
              X_CREATION_DATE => SYSDATE,
              X_CREATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_DATE => SYSDATE,
              X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);
                    ELSE
                            EDR_PSIG_SIGN_PARAMS_PKG.UPDATE_ROW(
                    X_PARAMETER_ID => L_PARAMETER_ID,
                X_SIGNATURE_ID => P_SIGNATURE_ID,
                X_NAME => P_PARAMETERS(i).PARAM_NAME,
                X_VALUE => P_PARAMETERS(i).PARAM_VALUE,
                X_DISPLAY_NAME => NVL(P_PARAMETERS(i).PARAM_DISPLAYNAME,P_PARAMETERS(i).PARAM_NAME),
                X_LAST_UPDATE_DATE => SYSDATE,
                X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
                X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);
                  END IF;
                  CLOSE C1;
                 END IF;
             END LOOP;
           else
             raise DOCUMENT_CLOSE_ERROR;
          end if;

EXCEPTION
        WHEN DOCUMENT_CLOSE_ERROR then
             fnd_message.set_name('EDR','EDR_PSIG_DOC_CLOSED');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_DOC_CLOSED');
             P_ERROR_MSG:= fnd_message.get();
        WHEN NO_DATA_FOUND then
             fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOCUMENT');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOCUMENT');
             P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;

END postSignatureParameter;

/* Delete Signature Parameters */

PROCEDURE deleteSignatureParameter
          (
           P_SIGNATURE_ID          IN  NUMBER,
           P_PARAMETER_NAME        IN  VARCHAR,
           P_ERROR                OUT  NOCOPY NUMBER,
           P_ERROR_MSG            OUT  NOCOPY VARCHAR2
        )
IS
BEGIN
             fnd_message.set_name('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR_MSG:= fnd_message.get();
END deleteSignatureParameter;

/* Delete All Signature Parameters */

PROCEDURE deleteAllSignatureParams
          (
           P_SIGNATURE_ID          IN  NUMBER,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        )
IS

BEGIN
             fnd_message.set_name('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_OBSOLETE_CALL');
             P_ERROR_MSG:= fnd_message.get();
END deleteAllSignatureParams;

/* Get Document Details */

PROCEDURE getDocumentDetails
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_DOCUMENT             OUT NOCOPY EDR_PSIG.DOCUMENT,
           P_DOCPARAMS            OUT NOCOPY EDR_PSIG.params_table,
         P_SIGNATURES           OUT NOCOPY EDR_PSIG.SignatureTable,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        ) IS
l_status varchar2(240);
l_parameter_id NUMBER;
i number;

CURSOR DOC_PARAMS
    is SELECT NAME,VALUE,DISPLAY_NAME
         from EDR_PSIG_DOC_PARAMS_VL
          where DOCUMENT_ID=P_DOCUMENT_ID;
CURSOR SIGN_DETAILS
    is SELECT  SIGNATURE_ID,
         DOCUMENT_ID,
               EVIDENCE_STORE_ID,
               USER_NAME,
               USER_RESPONSE,
               SIGNATURE_TIMESTAMP,
               SIGNATURE_TIMEZONE,
               SIGNATURE_STATUS,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN,
               LAST_UPDATED_BY,
         --Bug 3101047 : Start
         DECODE(SIGNATURE_TIMESTAMP,NULL,EDR_UTILITIES.GETUSERDISPLAYNAME(USER_NAME), USER_DISPLAY_NAME)USER_DISPLAY_NAME
         --Bug 3101047 : End
   FROM EDR_PSIG_DETAILS
         where DOCUMENT_ID=P_DOCUMENT_ID;
BEGIN
       --Bug 4073809 : start
  i := 1;
       --Bug 4073809 : end





  /* Fetch Document information */
        SELECT
    DOCUMENT_ID,
    PSIG_XML,
    PSIG_DOCUMENT,
    PSIG_DOCUMENTFORMAT,
    PSIG_TIMESTAMP,
    PSIG_TIMEZONE,
    DOCUMENT_REQUESTER,
    PSIG_STATUS,
    PSIG_SOURCE,
    EVENT_NAME,
    EVENT_KEY,
    PRINT_COUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY
          into
    P_DOCUMENT.DOCUMENT_ID,
    P_DOCUMENT.PSIG_XML,
    P_DOCUMENT.PSIG_DOCUMENT,
    P_DOCUMENT.PSIG_DOCUMENTFORMAT,
    P_DOCUMENT.PSIG_TIMESTAMP,
    P_DOCUMENT.PSIG_TIMEZONE,
    P_DOCUMENT.DOCUMENT_REQUESTER,
    P_DOCUMENT.PSIG_STATUS,
    P_DOCUMENT.PSIG_SOURCE,
    P_DOCUMENT.EVENT_NAME,
    P_DOCUMENT.EVENT_KEY,
    P_DOCUMENT.PRINT_COUNT,
    P_DOCUMENT.CREATION_DATE,
    P_DOCUMENT.CREATED_BY,
    P_DOCUMENT.LAST_UPDATE_DATE,
    P_DOCUMENT.LAST_UPDATE_LOGIN,
    P_DOCUMENT.LAST_UPDATED_BY
              from EDR_PSIG_DOCUMENTS
              where DOCUMENT_ID=P_DOCUMENT_ID;
    /* Fetch Document Parameters */
          open DOC_PARAMS;
           Loop
-- Bug 3581537 : Start
-- Replaced PARAM_NAME with PARAM_VALUE for the value column. Probably it was
-- copy paste error.
             fetch DOC_PARAMS into P_DOCPARAMS(i).PARAM_NAME,P_DOCPARAMS(i).PARAM_VALUE,P_DOCPARAMS(i).PARAM_DISPLAYNAME ;
-- Bug 3581537 : End
             exit when DOC_PARAMS%notfound;
             i:=i+1;
            end loop;
           close DOC_PARAMS;
    /* Fetch Signature Details */
          open SIGN_DETAILS;
           i:=1;
           Loop
             fetch SIGN_DETAILS into
               P_SIGNATURES(i).SIGNATURE_ID,
         P_SIGNATURES(i).DOCUMENT_ID,
               P_SIGNATURES(i).EVIDENCE_STORE_ID,
               P_SIGNATURES(i).USER_NAME,
               P_SIGNATURES(i).USER_RESPONSE,
               P_SIGNATURES(i).SIGNATURE_TIMESTAMP,
               P_SIGNATURES(i).SIGNATURE_TIMEZONE,
               P_SIGNATURES(i).SIGNATURE_STATUS,
               P_SIGNATURES(i).CREATION_DATE,
               P_SIGNATURES(i).CREATED_BY,
               P_SIGNATURES(i).LAST_UPDATE_DATE,
               P_SIGNATURES(i).LAST_UPDATE_LOGIN,
               P_SIGNATURES(i).LAST_UPDATED_BY,
         --Bug 3101047 : Start
         P_SIGNATURES(i).USER_DISPLAY_NAME;
         --Bug 3101047 : End
             exit when SIGN_DETAILS%notfound;
             i:=i+1;
            end loop;
           close SIGN_DETAILS;

EXCEPTION
        WHEN NO_DATA_FOUND then
             fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOCUMENT');
             P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOCUMENT');
             P_ERROR_MSG:= fnd_message.get();

        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END getDocumentDetails;


PROCEDURE getSignatureDetails
          (
           P_SIGNATURE_ID         IN  NUMBER DEFAULT NULL,
       P_SIGNATUREDETAILS     OUT NOCOPY EDR_PSIG.Signature,
           P_SIGNATUREPARAMS      OUT NOCOPY EDR_PSIG.params_table,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        ) AS
l_status varchar2(240);
l_parameter_id NUMBER;
i number;
CURSOR SIGN_PARAMS
    is SELECT PARAMETER_ID
         from EDR_PSIG_SIGN_PARAMS_VL
          where SIGNATURE_ID =P_SIGNATURE_ID;
CURSOR SIG_PARAMS
    is SELECT NAME,VALUE,DISPLAY_NAME
         from EDR_PSIG_SIGN_PARAMS_VL
          where SIGNATURE_ID=P_SIGNATURE_ID;
CURSOR SIGN_DETAILS
    is SELECT  SIGNATURE_ID,
         DOCUMENT_ID,
               EVIDENCE_STORE_ID,
               USER_NAME,
               USER_RESPONSE,
               SIGNATURE_TIMESTAMP,
               SIGNATURE_TIMEZONE,
               SIGNATURE_STATUS,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN,
               LAST_UPDATED_BY,
         --Bug 3101047 : Start
         DECODE(SIGNATURE_TIMESTAMP,NULL,EDR_UTILITIES.GETUSERDISPLAYNAME(USER_NAME), USER_DISPLAY_NAME)USER_DISPLAY_NAME
         --Bug 3101047 : End
        FROM   EDR_PSIG_DETAILS
         where SIGNATURE_ID=P_SIGNATURE_ID;
BEGIN

       --Bug 4073809 : start
  i := 1;
       --Bug 4073809 : end



   /* Fetch Signature Details */
          open SIGN_DETAILS;
          Loop
             fetch SIGN_DETAILS into
               P_SIGNATUREDETAILS.SIGNATURE_ID,
         P_SIGNATUREDETAILS.DOCUMENT_ID,
               P_SIGNATUREDETAILS.EVIDENCE_STORE_ID,
               P_SIGNATUREDETAILS.USER_NAME,
               P_SIGNATUREDETAILS.USER_RESPONSE,
               P_SIGNATUREDETAILS.SIGNATURE_TIMESTAMP,
               P_SIGNATUREDETAILS.SIGNATURE_TIMEZONE,
               P_SIGNATUREDETAILS.SIGNATURE_STATUS,
               P_SIGNATUREDETAILS.CREATION_DATE,
               P_SIGNATUREDETAILS.CREATED_BY,
               P_SIGNATUREDETAILS.LAST_UPDATE_DATE,
               P_SIGNATUREDETAILS.LAST_UPDATE_LOGIN,
               P_SIGNATUREDETAILS.LAST_UPDATED_BY,
         --Bug 3101047 : Start
         P_SIGNATUREDETAILS.USER_DISPLAY_NAME;
         --Bug 3101047 : End
             exit when SIGN_DETAILS%notfound;
             i:=i+1;
            end loop;
           close SIGN_DETAILS;

     /* Fetch Signature Parameters */
          open SIG_PARAMS;
           i:=1;
           Loop
             fetch SIG_PARAMS into P_SIGNATUREPARAMS(i).PARAM_NAME,P_SIGNATUREPARAMS(i).PARAM_VALUE,P_SIGNATUREPARAMS(i).PARAM_DISPLAYNAME ;
             exit when SIG_PARAMS%notfound;
             i:=i+1;
            end loop;
           close SIG_PARAMS;

EXCEPTION
        WHEN NO_DATA_FOUND then
                fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNID');
                P_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNID');
                P_ERROR_MSG:= fnd_message.get();
        WHEN OTHERS then
             P_ERROR:=SQLCODE;
             P_ERROR_MSG:=SQLERRM;
END getSignatureDetails;


PROCEDURE updatePrintCount (
  P_DOC_ID    IN  edr_psig_documents.document_id%TYPE,
  P_NEW_COUNT OUT NOCOPY  NUMBER
) IS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  SELECT print_count into P_NEW_COUNT
  FROM   edr_psig_documents
  WHERE  document_id = P_DOC_ID;

  P_NEW_COUNT := NVL(P_NEW_COUNT,0) + 1;

  UPDATE edr_psig_documents
  SET
  print_count = P_NEW_COUNT,
  --Bug 4672801: start
  last_update_date = sysdate,
  last_updated_by = fnd_global.user_id(),
  last_update_login = fnd_global.login_id()
  --Bug 4672801: end
  WHERE  document_id = P_DOC_ID;

  commit;
END updatePrintCount;

--Bug 3161859 : start

/* Get the signatureid based on the originalrecipient
 * final receipient and documentid and signature status */

procedure getSignatureId (P_DOCUMENT_ID in number,
                          P_ORIGINAL_RECIPIENT in varchar2,
                          P_USER_NAME in varchar2,
                          P_SIGNATURE_STATUS in varchar2,
                          X_SIGNATURE_ID out NOCOPY number,
                          X_ERROR out NOCOPY number,
                          X_ERROR_MSG out NOCOPY varchar2)
is
 CURSOR c1 is
 SELECT SIGNATURE_ID from EDR_PSIG_DETAILS
  WHERE DOCUMENT_ID = P_DOCUMENT_ID
  AND ORIGINAL_RECIPIENT = P_ORIGINAL_RECIPIENT
  AND USER_NAME = P_USER_NAME
  AND SIGNATURE_STATUS = P_SIGNATURE_STATUS;
BEGIN
   OPEN c1;
   FETCH c1 into X_SIGNATURE_ID;
   if c1%NOTFOUND THEN
      raise DOCUMENT_NOT_FOUND;
   END IF;
   CLOSE c1;
   X_ERROR := 0;
EXCEPTION
   WHEN DOCUMENT_NOT_FOUND THEN
      fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOCUMENT');
      X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOCUMENT');
      X_ERROR_MSG:= fnd_message.get();
      CLOSE c1;
 WHEN OTHERS then
      X_ERROR:=SQLCODE;
      X_ERROR_MSG:=SQLERRM;
      CLOSE c1;
END getSignatureId;

/* Get the adhoc status for the signature id */
procedure GET_ADHOC_STATUS (  P_SIGNATURE_ID IN NUMBER,
                              X_STATUS OUT NOCOPY VARCHAR2,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2)
IS
 CURSOR C1 is
 SELECT ADHOC_STATUS from EDR_PSIG_DETAILS
  WHERE SIGNATURE_ID = P_SIGNATURE_ID;

BEGIN
   OPEN C1;
   FETCH C1 into X_STATUS;
   if c1%NOTFOUND THEN
      raise DOCUMENT_NOT_FOUND;
   END IF;
   CLOSE C1;
   X_ERROR := 0;
EXCEPTION
   WHEN DOCUMENT_NOT_FOUND THEN
      fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNATURE');
      X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNATURE');
      X_ERROR_MSG:= fnd_message.get();
      CLOSE c1;
   WHEN OTHERS then
      X_ERROR:=SQLCODE;
      X_ERROR_MSG:=SQLERRM;
      CLOSE c1;
END GET_ADHOC_STATUS;

/* Delete the adhoc user */
procedure DELETE_ADHOC_USER ( P_SIGNATURE_ID IN NUMBER,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2)

is
l_document_id NUMBER;
l_status varchar2(240);
l_sig_status varchar2(100);
l_adhoc_status varchar2(32);
CURSOR C1
    is SELECT DOCUMENT_ID,SIGNATURE_STATUS, ADHOC_STATUS
         from EDR_PSIG_DETAILS
          where SIGNATURE_ID = P_SIGNATURE_ID;
BEGIN
   /* set the secure context */
   edr_ctx_pkg.set_secure_attr;
  /* Check if Signature Row Exist */
  OPEN C1;
   FETCH C1 into l_document_id,l_sig_status, l_adhoc_status;
   IF c1%NOTFOUND THEN
     fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNID');
                X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNID');
                X_ERROR_MSG:= fnd_message.get();
                RAISE EDR_GENERIC_ERROR;
   END IF;
  CLOSE C1;

  /* Check if the user is adhoc */
  IF (l_adhoc_status <> 'ADDED') THEN
     fnd_message.set_name('EDR','EDR_PSIG_NOT_ADHOC_SIGNER');
     x_error :=fnd_message.get_number('EDR','EDR_PSIG_NOT_ADHOC_SIGNER');
     X_ERROR_MSG:= fnd_message.get();
     RAISE EDR_GENERIC_ERROR;
  END IF;

  /* Check if it's the row is in PENDING */
  IF l_sig_status = 'COMPLETE' THEN
    fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
    X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
    X_ERROR_MSG:= fnd_message.get();
    RAISE EDR_GENERIC_ERROR;
  END IF;

   /* Check if document is existing */
   GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>L_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>X_ERROR,
                              X_ERROR_MSG =>X_ERROR_MSG);

   IF nvl(X_ERROR,0) > 0  THEN
     RAISE EDR_GENERIC_ERROR;
   END IF;

   IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
     RAISE EDR_INVALID_DOC_TRAN;
   END IF;


   /* Document Exist */
   DELETE FROM EDR_PSIG_DETAILS
    where SIGNATURE_ID=P_SIGNATURE_ID;

   X_ERROR := 0;
EXCEPTION
   WHEN EDR_GENERIC_ERROR then
     NULL;

   WHEN EDR_INVALID_DOC_TRAN then
     fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
     X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
     X_ERROR_MSG:= fnd_message.get();

   WHEN OTHERS then
     X_ERROR:=SQLCODE;
     X_ERROR_MSG:=SQLERRM;

END DELETE_ADHOC_USER;

--Bug 3161859 : end
--Bug 3330240 : start
/* Update the Signer Sequence for the record */
procedure UPDATE_SIGNATURE_SEQUENCE ( P_SIGNATURE_ID in number,
                                      P_SIGNATURE_SEQUENCE in number,
                                      X_ERROR OUT NOCOPY number,
                                      X_ERROR_MSG OUT NOCOPY varchar2)
is
l_document_id NUMBER;
l_status varchar2(240);
l_sig_status varchar2(100);
CURSOR C1
    is SELECT DOCUMENT_ID,SIGNATURE_STATUS
         from EDR_PSIG_DETAILS
         where SIGNATURE_ID = P_SIGNATURE_ID;

BEGIN
   /*Start: Set the secure context to access edr_psig_documents table */
   edr_ctx_pkg.set_secure_attr;
   /* Check if Signature Row Exist */
   OPEN C1;
   FETCH C1 into l_document_id,l_sig_status;
   IF c1%NOTFOUND THEN
     fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNID');
     X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNID');
     X_ERROR_MSG:= fnd_message.get();
     RAISE EDR_GENERIC_ERROR;
   END IF;
   CLOSE C1;

   /* Check if it's the row is in PENDING */
   IF l_sig_status = 'COMPLETE' THEN
      fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
      X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
      X_ERROR_MSG:= fnd_message.get();
      RAISE EDR_GENERIC_ERROR;
   END IF;

   /* Check if document is existing */
   GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>L_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>X_ERROR,
                              X_ERROR_MSG =>X_ERROR_MSG);

   IF nvl(X_ERROR,0) > 0  THEN
     RAISE EDR_GENERIC_ERROR;
   END IF;

   IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
     RAISE EDR_INVALID_DOC_TRAN;
   END IF;

   IF ( P_SIGNATURE_SEQUENCE <= 0) THEN
     fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNATURE_SEQ');
     X_ERROR:= fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNATURE_SEQ');
     X_ERROR_MSG:= fnd_message.get();
     RAISE EDR_GENERIC_ERROR;
   END IF;

   /* Document Exist */
   UPDATE EDR_PSIG_DETAILS
     set SIGNATURE_SEQUENCE=P_SIGNATURE_SEQUENCE,
         LAST_UPDATE_DATE=SYSDATE,
         LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
         LAST_UPDATE_LOGIN=FND_GLOBAL.LOGIN_ID
     where SIGNATURE_ID=P_SIGNATURE_ID;

   X_ERROR := 0;
EXCEPTION
   WHEN EDR_GENERIC_ERROR then
      NULL;

   WHEN EDR_INVALID_DOC_TRAN then
     fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
     X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
     X_ERROR_MSG:= fnd_message.get();

   WHEN OTHERS then
      X_ERROR:=SQLCODE;
      X_ERROR_MSG:=SQLERRM;
END UPDATE_SIGNATURE_SEQUENCE;

/* Update the Adhoc Status for the record */
procedure UPDATE_ADHOC_STATUS ( P_SIGNATURE_ID in number,
                                P_ADHOC_STATUS in varchar2,
                                X_ERROR OUT NOCOPY number,
                                X_ERROR_MSG OUT NOCOPY varchar2)
is
l_document_id NUMBER;
l_status varchar2(240);
l_sig_status varchar2(100);
CURSOR C1
    is SELECT DOCUMENT_ID,SIGNATURE_STATUS
         from EDR_PSIG_DETAILS
         where SIGNATURE_ID = P_SIGNATURE_ID;

BEGIN
   /*Start: Set the secure context to access edr_psig_documents table */
   edr_ctx_pkg.set_secure_attr;
   /* Check if Signature Row Exist */
   OPEN C1;
   FETCH C1 into l_document_id,l_sig_status;
   IF c1%NOTFOUND THEN
     fnd_message.set_name('EDR','EDR_PSIG_INVALID_SIGNID');
     X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_SIGNID');
     X_ERROR_MSG:= fnd_message.get();
     RAISE EDR_GENERIC_ERROR;
   END IF;
   CLOSE C1;

   /* Check if it's the row is in PENDING */
   IF l_sig_status = 'COMPLETE' THEN
      fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
      X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
      X_ERROR_MSG:= fnd_message.get();
      RAISE EDR_GENERIC_ERROR;
   END IF;

   /* Check if document is existing */
   GET_DOCUMENT_STATUS(P_DOCUMENT_ID =>L_DOCUMENT_ID,
                              X_STATUS =>L_STATUS,
                              X_ERROR =>X_ERROR,
                              X_ERROR_MSG =>X_ERROR_MSG);

   IF nvl(X_ERROR,0) > 0  THEN
     RAISE EDR_GENERIC_ERROR;
   END IF;

   IF L_STATUS IN ('COMPLETE','REJECTED','CANCEL','TIMEDOUT') THEN
     RAISE EDR_INVALID_DOC_TRAN;
   END IF;

   --adhoc status should be ADDED or DELETED only
   IF (P_ADHOC_STATUS not in ('ADDED','DELETED') ) then
      fnd_message.set_name('EDR','EDR_PSIG_INVALID_ADHOC_STATUS');
      X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_ADHOC_STATUS');
      X_ERROR_MSG:= fnd_message.get();
      RAISE EDR_GENERIC_ERROR;
   END IF;
   /* Document Exist */
   UPDATE EDR_PSIG_DETAILS
     set ADHOC_STATUS=P_ADHOC_STATUS,
         LAST_UPDATE_DATE=SYSDATE,
         LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
         LAST_UPDATE_LOGIN=FND_GLOBAL.LOGIN_ID
     where SIGNATURE_ID=P_SIGNATURE_ID;

   X_ERROR := 0;
EXCEPTION
 WHEN EDR_GENERIC_ERROR then
      NULL;

   WHEN EDR_INVALID_DOC_TRAN then
     fnd_message.set_name('EDR','EDR_PSIG_SIGN_COMPLETE');
     X_ERROR:=fnd_message.get_number('EDR','EDR_PSIG_SIGN_COMPLETE');
     X_ERROR_MSG:= fnd_message.get();

   WHEN OTHERS then
      X_ERROR:=SQLCODE;
      X_ERROR_MSG:=SQLERRM;
END UPDATE_ADHOC_STATUS;

--Bug 3330240 : end

-- Bug 3170251 - Start
-- Added a getter to get PSIG_XML (eRecord XML ) in CLOB.
--This procedure gets the PSIG_XML from EDR_PSIG_DOCUMENTS table
--for the given p_document_id i.e. eRecordId

-- Start of comments
-- API name             : getERecordXML
-- Type                 : Public Utility
-- Function             : Get the XML Document Contents for given eRecordId
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_DOCUMENT_ID in number
-- OUT                  : X_PSIG_XML OUT NOCOPY CLOB
--                      : X_ERROR_CODE out NOCOPY number
--                      : X_ERROR_MSG out NOCOPY varchar2
-- End of comments
procedure getERecordXML( P_DOCUMENT_ID number,
               X_PSIG_XML OUT NOCOPY CLOB,
             X_ERROR_CODE OUT NOCOPY NUMBER,
             X_ERROR_MSG OUT NOCOPY VARCHAR2 )
IS
BEGIN
         /* Set the security context to get access to PSIG_DOCUMENTS */
   edr_ctx_pkg.set_secure_attr;

   select psig_xml into x_psig_xml
   from edr_psig_documents
   where document_id = p_document_id;
exception
WHEN NO_DATA_FOUND then
             fnd_message.set_name('EDR','EDR_PSIG_INVALID_DOCUMENT');
             X_ERROR_CODE:=fnd_message.get_number('EDR','EDR_PSIG_INVALID_DOCUMENT');
             X_ERROR_MSG:= fnd_message.get();
WHEN OTHERS then
             X_ERROR_CODE:=SQLCODE;
             X_ERROR_MSG:=SQLERRM;
END getERecordXML;
-- Bug 3170251 - End


--Bug 3101047: Start
PROCEDURE UPDATE_PSIG_USER_DETAILS(P_DOCUMENT_ID IN NUMBER)
IS

l_user_name   VARCHAR2(100);
l_user_display_name VARCHAR2(360);
l_orig_system   VARCHAR2(240);
l_orig_system_id  NUMBER;

CURSOR GET_PSIG_USER_NAME IS
  select USER_NAME from EDR_PSIG_DETAILS where DOCUMENT_ID=p_document_id
                       and SIGNATURE_STATUS = 'PENDING'
           and USER_DISPLAY_NAME is null
           and ORIG_SYSTEM is null
           and ORIG_SYSTEM_ID is null;


BEGIN


SAVEPOINT PSIG_USER_DETAILS;

OPEN GET_PSIG_USER_NAME;
LOOP
  FETCH GET_PSIG_USER_NAME INTO l_user_name;
  EXIT WHEN GET_PSIG_USER_NAME%NOTFOUND;

  EDR_UTILITIES.GETUSERROLEINFO(P_USER_NAME   => l_user_name,
              X_USER_DISPLAY_NAME => l_user_display_name,
              X_ORIG_SYSTEM   => l_orig_system,
              X_ORIG_SYSTEM_ID    => l_orig_system_id);


  update EDR_PSIG_DETAILS
    set
        USER_DISPLAY_NAME=l_user_display_name,
        ORIG_SYSTEM=l_orig_system,
        ORIG_SYSTEM_ID=l_orig_system_id

        where
      USER_NAME=l_user_name
        and DOCUMENT_ID=p_document_id;
END LOOP;

CLOSE GET_PSIG_USER_NAME;

EXCEPTION
 WHEN OTHERS THEN
     ROLLBACK TO PSIG_USER_DETAILS;
     FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
     FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG');
     FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','UPDATE_PSIG_USER_DETAILS');
     RAISE;

END UPDATE_PSIG_USER_DETAILS;

--Bug 3101047: End


--Bug 3212117: Start

--This function would fetch the e-record header details in XML format for the specified e-record ID.
FUNCTION GET_ERECORD_HEADER_XML(P_DOCUMENT_ID IN NUMBER)

RETURN XMLType

IS

--This variable would hold the resultant XML for e-record header details obtained from the query.
l_result XMLType;

begin

  --This query would fetch the e-record header details in XML format.
  select XMLELEMENT("ERECORD_HEADER_DETAILS",
                    XMLFOREST(evid.event_name as EVENT_NAME,
                              wfev.display_name as EVENT_DISPLAY_NAME,
                              evid.event_key as EVENT_KEY,
                              evid.document_id as ERECORD_ID,
                              evid.PSIG_TIMESTAMP as EVENT_DATE,
                              evid.psig_timezone as TIMEZONE,
                              evid.psig_source as APPLICATION_SOURCE,
                              evid.DOCUMENT_REQUESTER as DOCUMENT_REQUESTER,
                              evid.DOC_REQ_DISP_NAME DOCUMENT_REQUESTER_DISP_NAME,
                              lookup1.meaning as DOCUMENT_STATUS,
                              evid.print_count as PRINT_COUNT,
                              evid.creation_date as CREATION_DATE,
                              evid.created_by as CREATED_BY,
                              evid.last_update_date as LAST_UPDATE_DATE,
                              evid.last_updated_by as LAST_UPDATED_BY,
                              evid.last_update_login as LAST_UPDATE_LOGIN,
                              (select xmlagg(xmlelement("DOC_PARAMS",
                                                        xmlforest(param1.name as PARAM_NAME,
                                                                  param1.value as PARAM_VALUE)
                                             ))
                              from edr_psig_doc_params_vl param1
                              where param1.document_id = evid.document_id
                              ) as DOC_PARAM_DETAILS
                             )
                     )

         into l_result

         from edr_psig_documents evid,
              wf_events_vl wfev,
              fnd_lookup_values_vl lookup1

              where
              evid.event_name = wfev.name
              and lookup1.lookup_type = 'EDR_DOCUMENT_STATUS'
              and lookup1.lookup_code = evid.psig_status
              and evid.document_id = p_document_id;

return l_result;

end GET_ERECORD_HEADER_XML;


--This function would fetch the PSIG_XML identified by the specified e-record ID.
FUNCTION GET_ERECORD_XML (P_DOCUMENT_ID IN NUMBER)

return XMLType

is

--This holds the query context.
qryCtx DBMS_XMLGEN.ctxHandle;

--This would hold the resultant CLOB.
l_result XMLType;

BEGIN

  --Create the query context based on the SQL QUERY.
  qryCtx := dbms_xmlgen.newContext('select xmltype(psig_xml) as ERECORD_XML from edr_psig_documents where document_id = ' || p_document_id);

  --We want the "<ROW>" tag to be null
  dbms_xmlgen.setRowTag(qryCtx,null);

  --We want the "ROWSET" tag to be null
  dbms_xmlgen.setRowSetTag(qryCtx,null);

  --We don't want any conversion of special characters.
  --This will ensure that the '<' and '> symbols in the base psig_xml are retained.
  dbms_xmlgen.setConvertSpecialChars(qryCtx,false);

  --This would give us the required XML without any standard comments.
  select extract(dbms_xmlgen.getXMLType(qryCtx),'/ERECORD_XML/*')
  into l_result
  from dual;

  SELECT xmlelement("ERECORD_XML",l_result)
  into l_result
  from dual;

  return l_result;

END GET_ERECORD_XML;


--This function would fetch the signature details for the specified e-record ID in XML format.
FUNCTION GET_PSIG_DETAIL_XML(P_DOCUMENT_ID IN NUMBER)

return XMLType

is

l_result XMLType;

l_temp XMLType;

begin

--This query would fetch the required XML.
select xmlelement("ERECORD_SIGNATURE_DETAILS",
                  xmlagg(xmlelement("SIGNER_DETAIL",
                                    xmlforest(psig.signature_sequence as SIGNATURE_SEQUENCE,
                                              psig.user_name as SIGNER_USER_NAME,
                                              psig.user_display_name as SIGNER_DISPLAY_NAME,
                                              psig.user_response as SIGNER_RESPONSE,
                                              psig.signature_timestamp as SIGNING_DATE,
                                              psig.SIGNATURE_OVERRIDING_COMMENTS as OVERRIDING_DETAILS,
                                              (select xmlagg(xmlelement("SIGNATURE_PARAMS",
                                                                        xmlforest(param1.name as PARAM_NAME,
                                                                                  param1.value as PARAM_VALUE)
                                                                       )
                                                            )
                                               from edr_psig_sign_params_vl param1
                                               where param1.signature_id = psig.signature_id
                                              ) as SIGNATURE_PARAM_DETAILS
                                             )
                                   )
                        )
                )

        into l_result

        from edr_psig_details psig

        where

        psig.document_id = p_document_id;

  select extract(l_result,'/ERECORD_SIGNATURE_DETAILS/*') into l_temp from dual;

  if l_temp is null then
    l_result := null;
  end if;

  return l_result;

END GET_PSIG_DETAIL_XML;


--This function would fetch the acknowledgement details for the specified in XML format.
FUNCTION GET_ACKN_DETAIL_XML(P_DOCUMENT_ID IN NUMBER)

return XMLType

is

l_result XMLType;

begin

  --This query would fetch the required XML.
  select  xmlelement("ACKNOWLEDGEMENT_DETAILS",
                     xmlforest(ackn.ackn_id as acknowledgement_id,
                               ackn.ackn_date as acknowledgement_date,
                               lookup1.meaning as acknowledgement_status,
                               ackn.ackn_by as acknowledged_by,
                               ackn.ackn_note as acknowledgement_comment,
                               ackn.CREATED_BY as CREATED_BY,
                               ackn.CREATION_DATE as CREATION_DATE,
                               ackn.LAST_UPDATED_BY as LAST_UPDATED_BY,
                               ackn.LAST_UPDATE_LOGIN as LAST_UPDATE_LOGIN,
                               ackn.LAST_UPDATE_DATE as LAST_UPDATE_DATE
                              )
                    )

  into l_result

  from edr_Trans_ackn ackn,
       fnd_lookup_values_vl lookup1

  where ackn.erecord_id = p_document_id
  and   lookup1.lookup_type = 'EDR_TRANS_STATUS'
  and   lookup1.lookup_code = ackn.transaction_status;

return l_result;

end GET_ACKN_DETAIL_XML;


--This function would fetch the print history details for the specified e-record ID in XML format.
FUNCTION GET_PRINT_HISTORY_DETAIL_XML(P_DOCUMENT_ID IN NUMBER)

return XMLType

is

l_result XMLType;

l_temp XMLType;

begin


  --This query would fetch the required XML.
  select xmlelement("PRINT_HISTORY_DETAILS",
                    xmlagg(xmlelement("PRINT_DETAILS",
                                      xmlforest(print.print_document_id as PRINT_ERECORD_ID,
                                                print.PRINT_COUNT as PRINT_COUNT,
                                                PRINT.PRINT_REQUESTED_BY as PRINT_REQUESTER,
                                                PRINT.USER_DISPLAY_NAME as PRINT_REQUESTER_DISPLAY_NAME,
                                                PRINT.PRINT_REQUESTED_DATE as PRINT_EVENT_DATE,
                                                (select lookup3.meaning
                                                 from fnd_lookup_values_vl lookup3,
                                                      edr_psig_documents printevid
                                                 where lookup3.lookup_code = printevid.psig_status
                                                 and   lookup3.lookup_type = 'EDR_DOCUMENT_STATUS'
                                                 and   printevid.document_id = print.print_document_id
                                                ) as PRINT_ERECORD_STATUS,
                                                print.CREATED_BY as CREATED_BY,
                                                print.CREATION_DATE as CREATION_DATE,
                                                print.LAST_UPDATED_BY as LAST_UPDATED_BY,
                                                print.LAST_UPDATE_LOGIN as LAST_UPDATE_LOGIN,
                                                print.LAST_UPDATE_DATE as LAST_UPDATE_DATE
                                               )
                                     )
                          )
                   )

  into l_result

  from edr_psig_print_history print

  where print.document_id = p_document_id;


  --Verify if the print history details actually exist.
  select extract(l_result,'/PRINT_HISTORY_DETAILS/*') into l_temp from dual;

  --If the print history details do not exist, then set the result variable to null.
  if l_temp is null then
    l_result := null;
  end if;

  return l_result;

END GET_PRINT_HISTORY_DETAIL_XML;


--This function would fetch the parent e-record details for the specified e-record ID in XML format.
FUNCTION GET_PARENT_ERECORD_DETAIL_XML(P_DOCUMENT_ID            IN NUMBER,
                                       P_GET_ERECORD_XML        IN VARCHAR2,
                                       P_GET_PSIG_DETAILS       IN VARCHAR2,
                                       P_GET_ACKN_DETAILS       IN VARCHAR2,
                                       P_GET_PRINT_DETAILS      IN VARCHAR2)

RETURN XMLType

as

l_result XMLType;
l_current_xml XMLType;
l_parent_erecord_id NUMBER;

begin

  --Obtain the parent e-record ID.
  select rel.parent_erecord_id into l_parent_erecord_id
  from edr_event_relationship rel
  where child_erecord_id = p_document_id;

  --Obtain the e-record header details.
  l_current_xml := get_erecord_header_xml(p_document_id => l_parent_erecord_id);

  --Copy the same to the result variable.
  select xmlconcat(l_result,l_current_xml) into l_result from dual;

  --Fetch the psig_xml if required.
  if(FND_API.TO_BOOLEAN(p_get_erecord_xml)) then

    l_current_xml := GET_ERECORD_XML(p_document_id => l_parent_erecord_id);

    --Append the psig_xml into the result variable.
    select xmlconcat(l_result,l_current_xml) into l_result from dual;

  end if;

  --Fetch the signature details if required.
  if(FND_API.TO_BOOLEAN(p_get_psig_details)) then

    l_current_xml := GET_PSIG_DETAIL_XML(p_document_id => l_parent_erecord_id);

    --Append the signature details
    select xmlconcat(l_result,l_current_xml) into l_result from dual;
  end if;

  if(FND_API.TO_BOOLEAN(p_get_ackn_details)) then

    l_current_xml := get_ackn_detail_xml(p_document_id => l_parent_erecord_id);

    --Append the acknowledgement details.
    select xmlconcat(l_result,l_current_xml) into l_result from dual;

  end if;

  if(FND_API.TO_BOOLEAN(p_get_print_details)) then
    l_current_xml := get_print_history_detail_xml(p_document_id => l_parent_erecord_id);
    select xmlconcat(l_result,l_current_xml) into l_result from dual;
  end if;

  select xmlelement("ERECORD",l_result) into l_result from dual;

  select xmlelement("PARENT_ERECORD_DETAILS",l_result) into l_result from dual;

  return l_result;

EXCEPTION
  WHEN NO_DATA_FOUND then
  return null;

end get_parent_erecord_detail_xml;


--This function is called recursively to fetch the entire child e-record hierarchy.
FUNCTION PROCESS_RESULT_SET(X_CURRENT_LEVEL  IN OUT NOCOPY NUMBER,
                            X_CURRENT_NODE   IN OUT NOCOPY XMLTYPE,
                            P_LEVEL_TBL      IN NUMBER_TBL,
                            P_RESULT_XML_TBL IN XMLTYPE_TBL)
return XMLType
is

l_this_Level number;
l_this_Node xmlType;
l_result xmlType;

begin

l_this_Level := x_current_Level;
l_this_Node := x_current_Node;

g_child_erecord_count := g_child_erecord_count + 1;


if (g_child_erecord_count > p_level_tbl.count) then
  x_current_Level := -1;

else

x_current_level := p_level_tbl(g_child_erecord_count);

x_current_node := p_result_xml_tbl(g_child_erecord_count);

end if;


while (x_current_Level >= l_this_Level) loop

-- Next Node is a decendant of sibling of this Node.
if (x_current_Level > l_this_Level) then

-- Next Node is a decendant of this Node.
l_result := process_Result_Set(x_current_Level, x_current_Node,p_level_tbl,
                               p_result_xml_tbl);
select xmlElement
(
"ERECORD",
extract(l_this_Node,'/ERECORD/*'),
xmlElement
(
"CHILD_ERECORD_DETAILS",
l_result
)
)
into l_this_Node
from dual;
else
-- Next node is a sibling of this Node.
l_result := process_Result_Set(x_current_Level, x_current_Node,p_level_tbl,
                               p_result_xml_tbl);

--Append the child details in to the result variable.
select xmlconcat(l_this_Node,l_result) into l_this_Node from dual;
end if;
end loop;

return l_this_Node;

end process_result_set;


--This function is used to obtain the child e-record details in XML for the specified e-record ID.
--The entire recursive child hierarchy is obtained.
FUNCTION GET_CHILD_ERECORD_DETAIL_XML(P_DOCUMENT_ID              IN NUMBER,
                                      P_GET_ERECORD_XML          IN VARCHAR2,
                                      P_GET_PSIG_DETAILS         IN VARCHAR2,
                                      P_GET_ACKN_DETAILS         IN VARCHAR2,
                                      P_GET_PRINT_DETAILS        IN VARCHAR2)
return XMLType

as

l_result XMLType;

l_current_xml XMLType;

l_result_xml_tbl XMLType_TBL;

l_level_tbl NUMBER_TBL;

l_current_level NUMBER;
l_current_node XMLType;

l_child_erecord_ids NUMBER_TBL;

l_count NUMBER;



cursor get_child_erecord_ids_cur(p_document_id NUMBER) is
select  level,rel.CHILD_ERECORD_ID CHILD_ERECORD_ID
from EDR_EVENT_RELATIONSHIP rel
connect by prior CHILD_ERECORD_ID = PARENT_ERECORD_ID
start with PARENT_ERECORD_ID = p_document_id and CHILD_ERECORD_ID <> p_document_id;


begin

  l_count := 0;

  --Fetch the child e-record details hierarchy into the respective variables.
  open get_child_erecord_ids_cur(p_document_id);
  loop
    fetch get_child_erecord_ids_cur into l_level_tbl(l_count + 1),l_child_erecord_ids(l_count+1);
      exit when get_child_erecord_ids_cur%NOTFOUND;
      l_count := l_count + 1;
  end loop;

  close get_child_erecord_ids_cur;

  --If the no child e-records are present then return zero.
  if l_count = 0 then
    return null;
  end if;


for i in 1..l_count loop

  --For each child e-record fetch the required details in XML format.
  --Set them into a XML Type Table.

  l_current_xml := get_erecord_header_xml(p_document_id => l_child_erecord_ids(i));

  l_result_xml_tbl(i) := l_current_xml;

  if(FND_API.TO_BOOLEAN(p_get_erecord_xml)) then
    l_current_xml := GET_ERECORD_XML(p_document_id => l_child_erecord_ids(i));
    select xmlconcat(l_result_xml_tbl(i),l_current_xml) into l_result_xml_tbl(i) from dual;
  end if;

  if(FND_API.TO_BOOLEAN(p_get_psig_details)) then
    l_current_xml := GET_PSIG_DETAIL_XML(p_document_id => l_child_erecord_ids(i));
    select xmlconcat(l_result_xml_tbl(i),l_current_xml) into l_result_xml_tbl(i) from dual;
  end if;

  if(FND_API.TO_BOOLEAN(p_get_ackn_details)) then
    l_current_xml := get_ackn_detail_xml(p_document_id => l_child_erecord_ids(i));
    select xmlconcat(l_result_xml_tbl(i),l_current_xml) into l_result_xml_tbl(i) from dual;
  end if;

  if(FND_API.TO_BOOLEAN(p_get_print_details)) then
    l_current_xml := get_print_history_detail_xml(p_document_id => l_child_erecord_ids(i));
    select xmlconcat(l_result_xml_tbl(i),l_current_xml) into l_result_xml_tbl(i) from dual;
  end if;

  select xmlelement("ERECORD",l_result_xml_tbl(i)) into l_result_xml_tbl(i) from dual;

end loop;

g_child_erecord_count := 1;

l_current_level := l_level_tbl(1);
l_current_node := l_result_xml_tbl(1);

--Proceed the table of child e-record IDs.
--Re-arrange them to form the correct hierarchy of child e-records.
l_result := process_result_set(l_current_level,l_current_node,l_level_tbl,l_result_xml_tbl);

select xmlelement("CHILD_ERECORD_DETAILS",l_result) into l_result from dual;

return l_result;

end get_child_erecord_detail_xml;



PROCEDURE GET_XML_FOR_ERECORDS(P_ERECORD_IDS              IN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE,
                               P_GET_ERECORD_XML          IN  VARCHAR2,
                               P_GET_PSIG_DETAILS         IN  VARCHAR2,
                               P_GET_ACKN_DETAILS         IN  VARCHAR2,
                               P_GET_PRINT_DETAILS        IN  VARCHAR2,
                               P_GET_RELATED_EREC_DETAILS IN  VARCHAR2,
                               X_FINAL_XML                OUT NOCOPY CLOB)

IS

--This variable would hold the result XML.
l_result XMLType;

--This variable would hold the current XML data being processed.
l_current_xml XMLType;

l_current_result XMLType;

BEGIN

for i in 1..P_ERECORD_IDS.COUNT loop
  l_current_result := null;

  --Fetch the e-record header details in XML format.
  l_current_xml := get_erecord_header_xml(p_document_id => p_erecord_ids(i));

  select xmlconcat(l_current_result,l_current_xml) into l_current_result from dual;

  --If the psig_xml is required, fetch the same in XML format.
  if(FND_API.TO_BOOLEAN(p_get_erecord_xml)) then
    l_current_xml := GET_ERECORD_XML(p_document_id => p_erecord_ids(i));
    select xmlconcat(l_current_result,l_current_xml) into l_current_result from dual;
  end if;

  --If the signature details are required, fetch the same in XML format.
  if(FND_API.TO_BOOLEAN(p_get_psig_details)) then
    l_current_xml := GET_PSIG_DETAIL_XML(p_document_id => p_erecord_ids(i));
    select xmlconcat(l_current_result,l_current_xml) into l_current_result from dual;
  end if;

  --If the acknowledgement details are required, fetch the same in XML format.
  if(FND_API.TO_BOOLEAN(p_get_ackn_details)) then
    l_current_xml := get_ackn_detail_xml(p_document_id => p_erecord_ids(i));
    select xmlconcat(l_current_result,l_current_xml) into l_current_result from dual;
  end if;

  --If the print history details are required, fetch the same in XML format.
  if(FND_API.TO_BOOLEAN(p_get_print_details)) then
    l_current_xml := get_print_history_detail_xml(p_document_id => p_erecord_ids(i));
    select xmlconcat(l_current_result,l_current_xml) into l_current_result from dual;
  end if;

  --If the related e-record details are required, fetch the same in XML format.
  if(FND_API.TO_BOOLEAN(p_get_related_erec_details)) then
    l_current_xml := get_parent_erecord_detail_xml(p_document_id              => p_erecord_ids(i),
                                                   P_GET_ERECORD_XML          => P_GET_ERECORD_XML,
                                                   P_GET_PSIG_DETAILS         => P_GET_PSIG_DETAILS,
                                                   P_GET_ACKN_DETAILS         => P_GET_ACKN_DETAILS,
                                                   P_GET_PRINT_DETAILS        => P_GET_PRINT_DETAILS
                                                  );
    select xmlconcat(l_current_result,l_current_xml) into l_current_result from dual;


    l_current_xml := get_child_erecord_detail_xml(p_document_id              => p_erecord_ids(i),
                                                  P_GET_ERECORD_XML          => P_GET_ERECORD_XML,
                                                  P_GET_PSIG_DETAILS         => P_GET_PSIG_DETAILS,
                                                  P_GET_ACKN_DETAILS         => P_GET_ACKN_DETAILS,
                                                  P_GET_PRINT_DETAILS        => P_GET_PRINT_DETAILS
                                                  );
    select xmlconcat(l_current_result,l_current_xml) into l_current_result from dual;
  end if;

  select xmlelement("ERECORD",l_current_result) into l_current_result from dual;

  select xmlconcat(l_result,l_current_result) into l_result from dual;

end loop;

select xmlelement("ERECORDS",l_result) into l_result from dual;

--Convert the final result value into a CLOB.
X_FINAL_XML := l_result.getClobVal;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_FINAL_XML := NULL;

END GET_XML_FOR_ERECORDS;


--This PROCEDURE will fetch the event data in XML format.
--The individual e-record details such as acknowledgement details, signature details etc... are fetched based
--the value of the individual flags set.
PROCEDURE GET_EVENT_XML(P_EVENT_NAME               IN  VARCHAR2,
                        P_EVENT_KEY                IN  VARCHAR2,
                        P_ERECORD_ID               IN  NUMBER,
                        P_GET_ERECORD_XML          IN  VARCHAR2,
                        P_GET_PSIG_DETAILS         IN  VARCHAR2,
                        P_GET_ACKN_DETAILS         IN  VARCHAR2,
                        P_GET_PRINT_DETAILS        IN  VARCHAR2,
                        P_GET_RELATED_EREC_DETAILS IN  VARCHAR2,
                        X_FINAL_XML                OUT NOCOPY CLOB
                        )

is

l_count NUMBER;

l_temp_counter NUMBER;

l_erecord_ids EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE;

--This cursor is used to fetch the e-record IDs identified by the event name and event key.
cursor get_erecord_ids_cur(p_event_name VARCHAR2,
                           p_event_key VARCHAR2) is
select evid.document_id
from edr_psig_documents evid
where evid.event_name = p_event_name
and   evid.event_key = p_event_key;

INVALID_EVENT_NAME_ERROR EXCEPTION;

INVALID_EVENT_KEY_ERROR EXCEPTION;

INVALID_PARAMS_ERROR EXCEPTION;

begin

--Set the secure context.
edr_ctx_pkg.set_secure_attr;

l_count := 0;
l_temp_counter := 0;

if p_event_name is null and p_event_key is null and p_erecord_id is null then

  RAISE INVALID_PARAMS_ERROR;

END IF;

--If the event name and event key are set with the e-record ID being null, then fetch the
--e-record IDs identified by the event name/event key combination and set them on
--the e-record ID table type.
if(p_event_name is not null and p_event_key is not null and p_erecord_id is null) then

  open get_erecord_ids_cur(p_event_name,
                           p_event_key);
  loop
    fetch get_erecord_ids_cur into l_erecord_ids(l_count + 1);
      exit when get_erecord_ids_cur%NOTFOUND;
      l_count := l_count + 1;
  end loop;

  close get_erecord_ids_cur;

  if l_count = 0 then
    --Quit the API.
    return;
  end if;

--If only the e-record ID is specified then copy the same into the e-record ID table type.
elsif (p_event_name is null and p_event_key is null and p_erecord_id is not null) then

  select evid.document_id into l_erecord_ids(l_count + 1)
  from edr_psig_documents evid
  where evid.document_id = p_erecord_id;
  l_count := l_count +1;

elsif (p_event_name is not null and p_event_key is not null and p_erecord_id is not null) then

  select evid.document_id into l_erecord_ids(l_count + 1)
  from edr_psig_documents evid
  where evid.event_name=p_event_name
  and evid.event_key = event_key
  and evid.document_id = p_erecord_id;
  l_count := l_count +1;

elsif (p_event_name is null and p_event_key is not null) then

  --Event name is not set but event key is set.
  --Hence raise an exception.
  RAISE INVALID_EVENT_NAME_ERROR;

elsif (p_event_name is not null and p_event_key is null) then

  --Event name is set, but event key is not set.
  --Hence raise an exception.
  RAISE INVALID_EVENT_KEY_ERROR;

end if;

  GET_XML_FOR_ERECORDS(P_ERECORD_IDS              => L_ERECORD_IDS,
                       P_GET_ERECORD_XML          => P_GET_ERECORD_XML,
                       P_GET_PSIG_DETAILS         => P_GET_PSIG_DETAILS,
                       P_GET_ACKN_DETAILS         => P_GET_ACKN_DETAILS,
                       P_GET_PRINT_DETAILS        => P_GET_PRINT_DETAILS,
                       P_GET_RELATED_EREC_DETAILS => P_GET_RELATED_EREC_DETAILS,
                       X_FINAL_XML                => X_FINAL_XML);


--Unset the secure context.
edr_ctx_pkg.unset_secure_attr;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_FINAL_XML := null;

  WHEN INVALID_EVENT_NAME_ERROR THEN

    FND_MESSAGE.SET_NAME('EDR','EDR_EVENT_XML_EVENT_NAME_ERR');

    --Diagnostics Start
    if FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG.GET_EVENT_XML',
                      FALSE
                     );
    end if;

    APP_EXCEPTION.RAISE_EXCEPTION;
    --Diagnostics End

  WHEN INVALID_EVENT_KEY_ERROR THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_EVENT_XML_EVENT_KEY_ERR');

    --Diagnostics Start
    if FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG.GET_EVENT_XML',
                      FALSE
                     );
    end if;

    APP_EXCEPTION.RAISE_EXCEPTION;
    --Diagnostics End

  WHEN INVALID_PARAMS_ERROR THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_EVENT_XML_PARAMS_ERR');

    --Diagnostics Start
    if FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG.GET_EVENT_XML',
                      FALSE
                     );
    end if;

    APP_EXCEPTION.RAISE_EXCEPTION;
    --Diagnostics End

  WHEN OTHERS THEN

    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_EVENT_XML');
    if FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG.GET_EVENT_XML',
                      FALSE
                     );
   end if;
   --Diagnostics End


END GET_EVENT_XML;

--Bug 3212117: End

--Bug 4577122: Start
procedure clear_pending_signatures
(p_document_id in number)
is
begin
  update edr_psig_details
  set signature_status = null,
  LAST_UPDATE_DATE=SYSDATE,
  LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
  LAST_UPDATE_LOGIN=FND_GLOBAL.LOGIN_ID
  where document_id = p_document_id
  and signature_status = 'PENDING';
end clear_pending_signatures;
--Bug 4577122: End

END EDR_PSIG;

/
