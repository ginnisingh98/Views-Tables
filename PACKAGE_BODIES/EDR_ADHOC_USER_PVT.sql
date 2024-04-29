--------------------------------------------------------
--  DDL for Package Body EDR_ADHOC_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_ADHOC_USER_PVT" AS
/* $Header: EDRVADHB.pls 120.1.12000000.1 2007/01/18 05:56:02 appldev ship $

/* Exception declaration */
-- defined a exception if there is from edr_psig
EDR_PSIG_ERROR Exception;

-- Bug 2674799 : start
-- Update approver list for the signer process
procedure UPDATE_SIGNERLIST (
        p_event_id             IN number,
        p_event_name           IN VARCHAR2 ,
        p_document_id          IN number,
        p_originalrecipient    IN FND_TABLE_OF_VARCHAR2_255,
        p_finalrecipient       IN FND_TABLE_OF_VARCHAR2_255,
        p_overridingdetails    IN FND_TABLE_OF_VARCHAR2_255,
        p_signaturesequence    IN FND_TABLE_OF_VARCHAR2_255,
        p_recipientdisplayname IN FND_TABLE_OF_VARCHAR2_255 DEFAULT NULL,
        p_originating_system   IN FND_TABLE_OF_VARCHAR2_255 DEFAULT NULL,
        p_orignating_system_id IN FND_TABLE_OF_VARCHAR2_255 DEFAULT NULL,
        x_error                OUT NOCOPY NUMBER,
        x_error_msg            OUT NOCOPY VARCHAR2
) IS PRAGMA AUTONOMOUS_TRANSACTION;


l_final_recipient varchar2(100);
l_original_recipient varchar2(100);
l_signature_sequence number;
l_overriding_approver varchar2(80);
l_overriding_comments varchar2(4000);
i integer;
l_temp_signature_id number;
l_psig_signature_id number;
l_actiondone varchar2(100);
l_error number;
l_error_msg varchar2(4000);
l_status varchar2(1);
l_adhoc_status varchar2(32);
l_updatestatus FND_TABLE_OF_VARCHAR2_255 := FND_TABLE_OF_VARCHAR2_255();
cursor GET_SIGNERS_FOR_EVENT is
           --Bug 4272262: Start
	   select user_name, original_recipient, to_number(signature_sequence,'999999999999.999999')
           --Bug 4272262: End
	   from edr_esignatures
	   where event_id = p_event_id
           --Bug 4272262: Start
	   order by to_number(signature_sequence,'999999999999.999999');
           --Bug 4272262: Start
BEGIN
   --create the updatestatus array of the required length and
   --update the  status as Action reqd for the row
   for i in 1 .. p_originalrecipient.count loop
      l_updatestatus.extend;
      l_updatestatus(i):= G_ACTION_REQD;
   end loop;
   -- open the cursor
   -- this is done for updating or deleting the default signers,
   -- insert of adhoc users is done after the loop of current rows
   open GET_SIGNERS_FOR_EVENT;
   loop
     fetch GET_SIGNERS_FOR_EVENT into l_final_recipient,l_original_recipient,
l_signature_sequence;
     EXIT WHEN GET_SIGNERS_FOR_EVENT%NOTFOUND;

       l_psig_signature_id := null;
       l_actiondone := G_ACTION_REQD;
       l_error := null;
       l_error_msg := null;

       -- get the signature id from edr_psig
       edr_psig.getSignatureId(
                                   P_DOCUMENT_ID => P_DOCUMENT_ID,
                                   P_ORIGINAL_RECIPIENT=>  l_original_recipient,
                                   P_USER_NAME => l_final_recipient,
                                   P_SIGNATURE_STATUS => 'PENDING',
                                   X_SIGNATURE_ID =>  l_psig_signature_id,
                                   X_ERROR => l_error,
                                   X_ERROR_MSG => l_error_msg);
       IF (nvl(l_error,0) >0) then
         RAISE EDR_PSIG_ERROR;
       END IF;

       for i in 1 .. p_originalrecipient.count loop
          if  p_originalrecipient(i) is not null then
            --match the final recipient and original recipient
            if ( p_originalrecipient(i) = l_original_recipient and
                 p_finalrecipient(i) = l_final_recipient) then
                -- check for signer sequence
                --if (i <> l_signature_sequence) then
                    -- update the signature sequence in the
                    -- temp and GQ tables

                    --Bug 2674799: start
                    -- Use the signature sequence passed to this API.

                    UPDATE EDR_ESIGNATURES
                        SET SIGNATURE_SEQUENCE = p_signaturesequence(i)
                        WHERE EVENT_ID = p_event_id
		        AND USER_NAME =l_final_recipient
		        AND ORIGINAL_RECIPIENT = l_original_recipient;

                    edr_psig.update_signature_sequence (
                                          P_SIGNATURE_ID => l_psig_signature_id,
                                          P_SIGNATURE_SEQUENCE =>
p_signaturesequence(i),
                                          X_ERROR => l_error,
                                          X_ERROR_MSG => l_error_msg);
                    --Bug 2674799 : end

                    IF (nvl(l_error,0) >0) then
                       RAISE EDR_PSIG_ERROR;
                    end if;
                --end if;
                l_updatestatus(i) := G_NO_ACTION_REQD;
                l_actiondone := G_NO_ACTION_REQD;
            end if;
         end if;
       end loop;

       -- if the original recipeint and final recipeint is not found in the row
       -- set, delete the row
       if (l_actiondone = G_ACTION_REQD) then
          DELETE FROM EDR_ESIGNATURES
            WHERE EVENT_ID = p_event_id
            AND USER_NAME = l_final_recipient
            AND ORIGINAL_RECIPIENT = l_original_recipient;

          -- get the adhoc status for the signatureid
          -- if the adhoc status is ADDED then delete
          -- delete the user else cancel the signature

         edr_psig.get_adhoc_status (P_SIGNATURE_ID =>  l_psig_signature_id,
                                     X_STATUS => l_adhoc_status,
                                     X_ERROR => l_error,
                                   X_ERROR_MSG => l_error_msg);

         IF (nvl(l_error,0) >0) then
             RAISE EDR_PSIG_ERROR;
         END IF;

         IF (l_adhoc_status = 'ADDED') then
             edr_psig.delete_adhoc_user (P_SIGNATURE_ID =>  l_psig_signature_id,
                                         X_ERROR => l_error,
                                         X_ERROR_MSG => l_error_msg);
             IF (nvl(l_error,0) >0) then
                RAISE EDR_PSIG_ERROR;
             END IF;

         else
             edr_psig.cancelSignature ( P_SIGNATURE_ID =>  l_psig_signature_id,
                                         P_ERROR => l_error,
                                         P_ERROR_MSG => l_error_msg);
             IF (nvl(l_error,0) >0) then
                RAISE EDR_PSIG_ERROR;
             END IF;

             edr_psig.update_adhoc_status ( P_SIGNATURE_ID =>
l_psig_signature_id,
                                            P_ADHOC_STATUS => 'DELETED',
                                            X_ERROR => l_error,
                                            X_ERROR_MSG => l_error_msg);
             IF (nvl(l_error,0) >0) then
                RAISE EDR_PSIG_ERROR;
             END IF;
         end if;
       end if;-- end l_action_done
    end loop;
    CLOSE GET_SIGNERS_FOR_EVENT;

    for i in 1 .. p_originalrecipient.count loop
        if p_originalrecipient(i) is NOT NULL then
            l_status :=  l_updatestatus(i);
            l_original_recipient := p_originalrecipient(i);
            l_error := null;
            l_error_msg := null;
    	    l_overriding_approver := null;
            l_overriding_comments := null;

            if ((l_status is null) or  (l_status = G_ACTION_REQD)) then
               -- you already have the final recipient and overriding details
               l_overriding_approver := p_finalrecipient(i);
               l_overriding_comments := p_overridingdetails(i);
               SELECT EDR_ESIGNATURES_S.NEXTVAL into l_temp_signature_id from
DUAL;
               --Bug 2674799 : start

               INSERT into EDR_ESIGNATURES
		(
			 SIGNATURE_ID,
			 EVENT_ID,
			 EVENT_NAME,
			 USER_NAME,
			 SIGNATURE_SEQUENCE,
			 SIGNATURE_STATUS,
			 ADHOC_STATUS,
			 ORIGINAL_RECIPIENT,
			 SIGNATURE_OVERRIDING_COMMENTS
		)
	        values
		(
			 l_temp_signature_id,
			 p_event_id,
			 p_event_name,
			 l_overriding_approver,
			 p_signaturesequence(i),
			 'PENDING',
			 'ADDED',
			 l_original_recipient,
			 l_overriding_comments
	         );

               EDR_PSIG.REQUESTSIGNATURE(P_DOCUMENT_ID => p_document_id ,
				         P_USER_NAME => l_overriding_approver,
				         P_ORIGINAL_RECIPIENT =>
l_original_recipient,
				         P_OVERRIDING_COMMENTS =>
l_overriding_comments,
				         P_SIGNATURE_ID => l_psig_signature_id,
                                         P_SIGNATURE_SEQUENCE
=>p_signaturesequence(i),
                                         P_ADHOC_STATUS => 'ADDED',
					 P_ERROR=>L_ERROR,
                                         P_ERROR_MSG=>l_error_msg);
               --Bug 2674799 : end

               IF (nvl(l_error,0) >0) then
                 RAISE EDR_PSIG_ERROR;
               END IF;
            end if;
        end if;
    end loop;
    commit;
    X_ERROR := 0;
EXCEPTION
  WHEN EDR_PSIG_ERROR THEN
    ROLLBACK;
    X_ERROR := l_ERROR;
    X_ERROR_MSG := l_error_msg;

  WHEN OTHERS THEN
    ROLLBACK;
    X_ERROR:=SQLCODE;
    X_ERROR_MSG:=SQLERRM;


END UPDATE_SIGNERLIST;

END EDR_ADHOC_USER_PVT;

/
