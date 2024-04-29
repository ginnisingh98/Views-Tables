--------------------------------------------------------
--  DDL for Package Body EDR_EINITIALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_EINITIALS_PVT" AS
/* $Header: EDRVINTB.pls 120.5.12000000.1 2007/01/18 05:56:15 appldev ship $ */

--This procedure is aimed at fetching the workflow attribtues values for the
--specified attribute names associated with the item type and item key.
PROCEDURE GET_WF_ATTRIBUTES(P_ITEMTYPE     IN VARCHAR2,
                            P_ITEMKEY      IN VARCHAR2,
                            P_PARAM_NAMES  IN FND_TABLE_OF_VARCHAR2_255,
                            X_PARAM_VALUES OUT NOCOPY FND_TABLE_OF_VARCHAR2_255)

IS

L_PARAM_VALUE VARCHAR2(4000);

BEGIN

  X_PARAM_VALUES := FND_TABLE_OF_VARCHAR2_255();

  --For each parameter specified obtain the parameter value.
  FOR i IN 1..P_PARAM_NAMES.COUNT LOOP
    X_PARAM_VALUES.EXTEND;
    L_PARAM_VALUE := WF_ENGINE.GETITEMATTRTEXT(P_ITEMTYPE, P_ITEMKEY,P_PARAM_NAMES(i), TRUE);

    --If the parameter name is the requester of the ERES transaction, then
    --obtain his display name as the attribute value.
    IF(P_PARAM_NAMES(i) = '#WF_SIGN_REQUESTER') THEN
      X_PARAM_VALUES(i) := EDR_UTILITIES.GETUSERDISPLAYNAME(L_PARAM_VALUE);
    ELSE
      X_PARAM_VALUES(i) := L_PARAM_VALUE;
    END IF;
  END LOOP;

END GET_WF_ATTRIBUTES;
-- Bug 5158510 : start
-- returns wf text item attribute
FUNCTION GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype varchar2, p_itemkey varchar2,
                                    p_attname varchar2)
                   RETURN VARCHAR2
IS
BEGIN

     return WF_ENGINE.GETITEMATTRTEXT(p_itemtype, p_itemkey,p_attname, TRUE);
END GET_WF_ITEM_ATTRIBUTE_TEXT;
-- Bug 5158510 : end

--This procedure is used to obtain the e-record details associated with the specified workflow item type
--and item key.
PROCEDURE GET_ERECORD_DETAILS(P_ITEMTYPE     IN         VARCHAR2,
                              P_ITEMKEY      IN         VARCHAR2,
                              P_PARAM_NAMES  IN         FND_TABLE_OF_VARCHAR2_255,
                              X_PARAM_VALUES OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
                              X_ERECORD_TEXT OUT NOCOPY CLOB)
IS

L_COUNT NUMBER;
L_ERECORD_ID NUMBER;
BEGIN

  --Fetch the attribute values from workflow.
  GET_WF_ATTRIBUTES(P_ITEMTYPE     => P_ITEMTYPE,
                    P_ITEMKEY      => P_ITEMKEY,
                    P_PARAM_NAMES  => P_PARAM_NAMES,
                    X_PARAM_VALUES => X_PARAM_VALUES);

  --Obtain the e-record ID value in number format.
  L_ERECORD_ID := TO_NUMBER(WF_ENGINE.GETITEMATTRTEXT(P_ITEMTYPE,P_ITEMKEY,EDR_CONSTANTS_GRP.G_ERECORD_ID_ATTR,TRUE),'999999999999.999999');

  --Set the secure context.
  EDR_CTX_PKG.SET_SECURE_ATTR;

  --Fetch the e-record document.
  SELECT PSIG_DOCUMENT INTO X_ERECORD_TEXT
  FROM EDR_PSIG_DOCUMENTS
  WHERE DOCUMENT_ID = L_ERECORD_ID;

  --Adjust the CLOB document for rendering in the OA page.
  --Primarily we would be converting all instances of '<' to '&lt' and '>' to '&gt'.
  if X_ERECORD_TEXT IS NOT NULL AND DBMS_LOB.GETLENGTH(X_ERECORD_TEXT) > 0 then

    X_ERECORD_TEXT := EDR_UTILITIES.ADJUST_CLOB_FOR_DISPLAY(P_PAYLOAD => X_ERECORD_TEXT,
                                                            P_PAYLOAD_TYPE => 'ERECORD');
  end if;

  --Unset the secure context.
  EDR_CTX_PKG.UNSET_SECURE_ATTR;

END GET_ERECORD_DETAILS;


--This procedure is used to obtain the e-record details associated with the specified ERES process ID.
PROCEDURE GET_ERECORD_DETAILS(P_PROCESS_ID      IN         VARCHAR2,
                              P_PARAM_NAMES     IN         FND_TABLE_OF_VARCHAR2_255,
                              X_ITEMTYPE        OUT NOCOPY VARCHAR2,
                              X_ITEMKEY         OUT NOCOPY VARCHAR2,
                              X_PARAM_VALUES    OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
                              X_ERECORD_COUNT   OUT NOCOPY NUMBER,
                              X_ESIGN_COMPLETED OUT NOCOPY VARCHAR2,
                              X_ERECORD_TEXT    OUT NOCOPY CLOB)
IS

L_ERECORD_STATUS VARCHAR2(100);

BEGIN

  --Fetch the number of e-records associated with the specified ERES process ID.
  SELECT COUNT(*) INTO X_ERECORD_COUNT FROM EDR_PROCESS_ERECORDS_T WHERE ERES_PROCESS_ID = P_PROCESS_ID;

  --If more than one e-record is present, then an invalid process ID parameter has been used.
  --Hence just return.
  IF X_ERECORD_COUNT > 1 OR X_ERECORD_COUNT = 0 THEN

    RETURN;

  END IF;


  --Obtain the status of the e-record.
  SELECT STATUS INTO L_ERECORD_STATUS FROM EDR_PROCESS_ERECORDS_T WHERE ERES_PROCESS_ID = P_PROCESS_ID;

  --Set the ESIGN completed flag based on the e-record status.
  IF L_ERECORD_STATUS IS NOT NULL THEN

    X_ESIGN_COMPLETED := 'Y';
    RETURN;

  ELSE

    X_ESIGN_COMPLETED := 'N';

  END IF;

  --Fetch the workflow item type and item key values.
  SELECT WF_ITEM_TYPE,WF_ITEM_KEY INTO X_ITEMTYPE,X_ITEMKEY
  FROM EDR_PROCESS_ERECORDS_T
  WHERE ERES_PROCESS_ID = P_PROCESS_ID;

  --Get the e-record details.
  GET_ERECORD_DETAILS
  (P_ITEMTYPE     => X_ITEMTYPE,
   P_ITEMKEY      => X_ITEMKEY,
   P_PARAM_NAMES  => P_PARAM_NAMES,
   X_PARAM_VALUES => X_PARAM_VALUES,
   X_ERECORD_TEXT => X_ERECORD_TEXT);

END GET_ERECORD_DETAILS;



--This private procedure validates the approver details passed as API parameters.
PROCEDURE VALIDATE_APPROVER(P_ROLE_NAME          IN  VARCHAR2,
                            P_SIGNER_NAME        IN  VARCHAR2,
                            P_SIGNER_PASSWORD    IN  VARCHAR2,
                            P_SIGNER_RESPONSE    IN  VARCHAR2,
                            X_IS_APPROVER_VALID  OUT NOCOPY VARCHAR2)

IS

i                     NUMBER;
L_ROLE_USERS          WF_DIRECTORY.USERTABLE;
L_IS_APPROVER_VALID   BOOLEAN;

BEGIN


  --Initials the flags.
  X_IS_APPROVER_VALID := 'Y';

  L_IS_APPROVER_VALID := TRUE;


  --Validate the approver details only if the signer response is not 'DEFER' and signer response is not null.
  IF INSTR(P_ROLE_NAME,'#') = 1 THEN
    --The role name is a responsibility
    --Hence strip the '#' character symbol and validate the signer name with the role.
    L_IS_APPROVER_VALID := WF_DIRECTORY.ISPERFORMER(UPPER(P_SIGNER_NAME),
                                                    LTRIM(P_ROLE_NAME,'#'));

  ELSIF P_ROLE_NAME IS NOT NULL AND LENGTH(P_ROLE_NAME) > 0 THEN
    --The role name itself is a signer name
    --Hence validate the same against the specified signer name.
    L_IS_APPROVER_VALID := WF_DIRECTORY.ISPERFORMER(UPPER(P_SIGNER_NAME),
                                                          P_ROLE_NAME);
  END IF;

  --Identify the invalid approvers and set them into a comma separated string.
  IF NOT L_IS_APPROVER_VALID THEN
    X_IS_APPROVER_VALID := 'N';
  END IF;

  IF (L_IS_APPROVER_VALID) THEN
    --Validate the login details of the signers.
    L_IS_APPROVER_VALID := FND_USER_PKG.VALIDATELOGIN(P_SIGNER_NAME, P_SIGNER_PASSWORD);

    --Identify the invalid approvers and set them into a comma separated string.
    IF NOT L_IS_APPROVER_VALID THEN
      X_IS_APPROVER_VALID := 'N';
    END IF;
  END IF;

END VALIDATE_APPROVER;


--This procedure is used to post the signature details into evidence store.
PROCEDURE POST_SIGNATURE_DETAILS(P_ERECORD_ID              IN  VARCHAR2,
                                 P_ITEMTYPE                IN  VARCHAR2,
                                 P_ITEMKEY                 IN  VARCHAR2,
                                 P_SIGNATURE_ID            IN  NUMBER,
                                 P_ROLE_NAME               IN  VARCHAR2,
                                 P_SIGNER_NAME             IN  VARCHAR2,
                                 P_SIGNER_PASSWORD         IN  VARCHAR2,
                                 P_SIGNATURE_SEQUENCE      IN  NUMBER,
                                 P_SIGNER_RESPONSE         IN  VARCHAR2,
                                 P_SIGNER_TYPE             IN  VARCHAR2,
                                 P_SIGNER_COMMENTS         IN  VARCHAR2,
                                 P_SIGNING_REASON          IN  VARCHAR2,
                                 X_IS_APPROVER_VALID       OUT NOCOPY VARCHAR2,
                                 X_SIGNER_DISPLAY_NAME     OUT NOCOPY VARCHAR2)

IS

PRAGMA AUTONOMOUS_TRANSACTION;

i NUMBER;
L_ERECORD_ID          NUMBER;
L_SIGNATURE_ID        NUMBER;
L_SIGNATURE_SEQUENCE  NUMBER;
L_ERROR_CODE          NUMBER;
L_ERROR_MSG           VARCHAR2(4000);
L_SIGN_PARAMS         EDR_PSIG.PARAMS_TABLE;
L_RESPONSE_MEANING    VARCHAR2(400);
L_EVENT_ID            NUMBER;
L_OVERRIDING_COMMENTS VARCHAR2(4000);
L_ORIGINAL_RECIPIENT  VARCHAR2(100);
UNEXPECTED_ERROR      EXCEPTION;

CURSOR FETCH_OVERRIDING_DETAILS IS
  SELECT ORIGINAL_RECIPIENT,
         SIGNATURE_OVERRIDING_COMMENTS
  FROM   EDR_ESIGNATURES
  WHERE  EVENT_ID     = L_EVENT_ID
  AND    SIGNATURE_ID = P_SIGNATURE_ID;

BEGIN

  --Get the e-record ID value in number format.
  L_ERECORD_ID     := TO_NUMBER(P_ERECORD_ID,'999999999999.999999');

  --Get the event ID in number format.
  L_EVENT_ID       := TO_NUMBER(P_ITEMKEY,'999999999999.999999');

  --Validate the approver.
  VALIDATE_APPROVER(P_ROLE_NAME          => P_ROLE_NAME,
                    P_SIGNER_NAME        => P_SIGNER_NAME,
                    P_SIGNER_PASSWORD    => P_SIGNER_PASSWORD,
                    P_SIGNER_RESPONSE    => P_SIGNER_RESPONSE,
                    X_IS_APPROVER_VALID  => X_IS_APPROVER_VALID);

  --Post the signature details only if the approver is valid.
  IF X_IS_APPROVER_VALID = 'Y' THEN

    --Fetch the signature sequence in number format.
    L_SIGNATURE_SEQUENCE := P_SIGNATURE_SEQUENCE;

    --Fetch the signature ID in number format.
    L_SIGNATURE_ID := P_SIGNATURE_ID;


    --Check if the role name is null or if it contains a responsibility.
    IF P_ROLE_NAME IS NULL OR INSTR(P_ROLE_NAME,'#') = 1 THEN

      --Update the signer details in the EDR_ESIGNATURES table.
      UPDATE EDR_ESIGNATURES
        SET USER_NAME             = P_SIGNER_NAME,
            SIGNATURE_TYPE        = P_SIGNER_TYPE,
            SIGNATURE_TIMESTAMP   = SYSDATE,
            SIGNATURE_STATUS      = P_SIGNER_RESPONSE,
            SIGNER_COMMENTS       = P_SIGNER_COMMENTS,
            ORIGINAL_RECIPIENT    = P_SIGNER_NAME,
            SIGNATURE_REASON_CODE = P_SIGNING_REASON

        WHERE SIGNATURE_ID        = L_SIGNATURE_ID;


      --Since the role name is either null or contains a responsibility,
      --we need to first request signature in EDR_PSIG_DETAILS before posting the signer response
      --details.
      EDR_PSIG.REQUESTSIGNATURE(P_DOCUMENT_ID          => L_ERECORD_ID,
                                P_USER_NAME            => UPPER(P_SIGNER_NAME),
                                P_ORIGINAL_RECIPIENT   => NULL,
                                P_OVERRIDING_COMMENTS  => NULL,
                                P_SIGNATURE_SEQUENCE   => L_SIGNATURE_SEQUENCE,
                                P_ADHOC_STATUS         => NULL,
                                P_SIGNATURE_ID         => L_SIGNATURE_ID,
                                P_ERROR                => L_ERROR_CODE,
                                P_ERROR_MSG            => L_ERROR_MSG);

      --If the error code is not null then an unexpected error has occurred.
      --Hence raise an exception.
      IF L_ERROR_CODE IS NOT NULL THEN
        RAISE UNEXPECTED_ERROR;
      END IF;

      --Fetch the signer response meaning from FND LOOKUPS.
      EDR_STANDARD.GET_MEANING('EDR_SIGN_RESPONSE_TYPE', P_SIGNER_RESPONSE,L_RESPONSE_MEANING);

      --Post the signature details into evidence store.
      EDR_PSIG.POSTSIGNATURE(P_DOCUMENT_ID           => L_ERECORD_ID,
                             P_EVIDENCE_STORE_ID     => NULL,
                             P_USER_NAME             => UPPER(P_SIGNER_NAME),
                             P_USER_RESPONSE         => L_RESPONSE_MEANING,
                             P_ORIGINAL_RECIPIENT    => NULL,
                             P_OVERRIDING_COMMENTS   => NULL,
                             P_SIGNATURE_ID          => L_SIGNATURE_ID,
                             P_ERROR                 => L_ERROR_CODE,
                             P_ERROR_MSG             => L_ERROR_MSG);

      --If the error code is not null then an unexpected error has occurred.
      --Hence raise an exception.
      IF L_ERROR_CODE IS NOT NULL THEN
        RAISE UNEXPECTED_ERROR;
      END IF;

    ELSE

      --Update the signer response in EDR_ESIGNATURES table.
      UPDATE EDR_ESIGNATURES
        SET  SIGNATURE_TYPE        = P_SIGNER_TYPE,
             SIGNATURE_TIMESTAMP   = SYSDATE,
             SIGNATURE_STATUS      = P_SIGNER_RESPONSE,
             SIGNER_COMMENTS       = P_SIGNER_COMMENTS,
             SIGNATURE_REASON_CODE = P_SIGNING_REASON

        WHERE SIGNATURE_ID       = L_SIGNATURE_ID;


      --Fetch the signer response meaning from FND LOOKUPS.
      EDR_STANDARD.GET_MEANING('EDR_SIGN_RESPONSE_TYPE', P_SIGNER_RESPONSE,L_RESPONSE_MEANING);

      --Fetch the overring details from edr_esignatures table.
      OPEN FETCH_OVERRIDING_DETAILS;
        FETCH FETCH_OVERRIDING_DETAILS INTO L_ORIGINAL_RECIPIENT,L_OVERRIDING_COMMENTS;
      CLOSE FETCH_OVERRIDING_DETAILS;

      EDR_PSIG.POSTSIGNATURE(P_DOCUMENT_ID           => L_ERECORD_ID,
                             P_EVIDENCE_STORE_ID     => NULL,
                             P_USER_NAME             => upper(P_SIGNER_NAME),
                             P_USER_RESPONSE         => L_RESPONSE_MEANING,
                             P_ORIGINAL_RECIPIENT    => L_ORIGINAL_RECIPIENT,
                             P_OVERRIDING_COMMENTS   => NULL,
                             P_SIGNATURE_ID          => L_SIGNATURE_ID,
                             P_ERROR                 => L_ERROR_CODE,
                             P_ERROR_MSG             => L_ERROR_MSG);

      IF L_ERROR_CODE IS NOT NULL THEN
        RAISE UNEXPECTED_ERROR;
      END IF;
    END IF;

    --Set the signature parameters.
    L_SIGN_PARAMS(1).PARAM_NAME := 'WF_SIGNER_TYPE';
    EDR_STANDARD.GET_MEANING('EDR_SIGNATURE_TYPES',P_SIGNER_TYPE,L_SIGN_PARAMS(1).PARAM_VALUE);
    EDR_STANDARD.GET_MEANING('EDR_SIGN_PARAMS_DISPLAY_TYPE','WF_SIGNER_TYPE',L_SIGN_PARAMS(1).PARAM_DISPLAYNAME);

    L_SIGN_PARAMS(2).PARAM_NAME := 'SIGNERS_COMMENT';
    L_SIGN_PARAMS(2).PARAM_VALUE := P_SIGNER_COMMENTS;
    EDR_STANDARD.GET_MEANING('EDR_SIGN_PARAMS_DISPLAY_TYPE','SIGNERS_COMMENT',L_SIGN_PARAMS(2).PARAM_DISPLAYNAME);

    L_SIGN_PARAMS(3).PARAM_NAME := 'REASON_CODE';
    EDR_STANDARD.GET_MEANING('EDR_SIGN_REASON_TYPE',P_SIGNING_REASON,L_SIGN_PARAMS(3).PARAM_VALUE);
    EDR_STANDARD.GET_MEANING('EDR_SIGN_PARAMS_DISPLAY_TYPE','REASON_CODE',L_SIGN_PARAMS(3).PARAM_DISPLAYNAME);

    --Post the signature parameters into evidence store.
    EDR_PSIG.POSTSIGNATUREPARAMETER(P_SIGNATURE_ID => L_SIGNATURE_ID,
                                    P_PARAMETERS   => L_SIGN_PARAMS,
                                    P_ERROR        => L_ERROR_CODE,
                                    P_ERROR_MSG    => L_ERROR_MSG);
    --If the error code is not null then an unexpected error has occurred.
    --Hence raise an exception.
    IF L_ERROR_CODE IS NOT NULL THEN
      RAISE UNEXPECTED_ERROR;
    END IF;
  END IF;

  X_SIGNER_DISPLAY_NAME := EDR_UTILITIES.GETUSERDISPLAYNAME(UPPER(P_SIGNER_NAME));

  --Commit the transaction.
  COMMIT;

EXCEPTION
  WHEN UNEXPECTED_ERROR THEN
    ROLLBACK;
    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',NVL(L_ERROR_MSG,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_EINITIALS_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','POST_SIGNATURE_DETAILS');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_EINITIALS_PVT.POST_SIGNATURE_DETAILS',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    ROLLBACK;
    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_EINITIALS_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','POST_SIGNATURE_DETAILS');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_EINITIALS_PVT.POST_SIGNATURE_DETAILS',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;

END POST_SIGNATURE_DETAILS;


--This procedure is used to move the workflow blocked activity appropriately to complete the
--signature process.
PROCEDURE COMPLETE_SIGNATURE(P_ITEMTYPE                IN  VARCHAR2,
                             P_ITEMKEY                 IN  VARCHAR2,
                             P_ERECORD_ID              IN  VARCHAR2,
                             P_UPDATE_ORES_TEMP_TABLES IN  VARCHAR2,
                             X_ERECORD_STATUS          OUT NOCOPY VARCHAR2)

IS

PRAGMA AUTONOMOUS_TRANSACTION;

--This variable stores the e-record ID in Number format.
L_ERECORD_ID NUMBER;

--This variable is used to store the event ID in number format.
L_EVENT_ID   NUMBER;

--This cursor is used to fetch the e-record status value for the specified event_id.
CURSOR FETCH_ERECORD_STATUS IS
  SELECT ERECORD_SIGNATURE_STATUS
  FROM   EDR_ERECORDS
  WHERE  EVENT_ID = L_EVENT_ID;

BEGIN

  --Get the e-record ID value in number format.
  L_ERECORD_ID     := TO_NUMBER(P_ERECORD_ID,'999999999999.999999');

  --Get the event ID in number format.
  L_EVENT_ID := TO_NUMBER(P_ITEMKEY,'999999999999.999999');

  --Set the e-record ID in workflow.
  WF_ENGINE.SETITEMATTRNUMBER(P_ITEMTYPE,P_ITEMKEY,'EDR_PSIG_DOC_ID',L_ERECORD_ID);

  --Move the workflow blocked activity as required.
  FND_WF_ENGINE.COMPLETEACTIVITY(P_ITEMTYPE, P_ITEMKEY, 'LITE_MODE', 'DONE');


  --Get the e-record ID value in number format.
  L_ERECORD_ID := TO_NUMBER(P_ERECORD_ID,'999999999999.999999');

  --Obtain the e-record status value.
  OPEN FETCH_ERECORD_STATUS;
    FETCH FETCH_ERECORD_STATUS INTO X_ERECORD_STATUS;
  CLOSE FETCH_ERECORD_STATUS;

  --Update the ORES temp tables based on the flag.
  IF P_UPDATE_ORES_TEMP_TABLES = FND_API.G_TRUE THEN
    UPDATE EDR_PROCESS_ERECORDS_T
      SET STATUS = X_ERECORD_STATUS
      WHERE ERECORD_ID = L_ERECORD_ID;
  END IF;

  --Commit the transaction
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_EINITIALS_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','COMPLETE_SIGNATURE');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_EINITIALS_PVT.COMPLETE_SIGNATURE',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;

END COMPLETE_SIGNATURE;


--This procedure cancels the signature process.
PROCEDURE CANCEL_SIGNATURE(P_ITEMTYPE                IN VARCHAR2,
                           P_ITEMKEY                 IN VARCHAR2,
                           P_ERECORD_ID              IN VARCHAR2,
                           P_UPDATE_ORES_TEMP_TABLES IN VARCHAR2)
IS

L_ERECORD_ID NUMBER;
  -- Bug 5158510 : start
l_signature_mode VARCHAR2(80);
  -- Bug 5158510 : end

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  --Get the e-record ID value in number format.
  L_ERECORD_ID     := TO_NUMBER(P_ERECORD_ID,'999999999999.999999');

  --Set the e-record ID in workflow.
  WF_ENGINE.SETITEMATTRNUMBER(P_ITEMTYPE,P_ITEMKEY,'EDR_PSIG_DOC_ID',L_ERECORD_ID);

  -- Bug 5158510 : start
  l_signature_mode := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,EDR_CONSTANTS_GRP.G_SIGNATURE_MODE);
  IF(EDR_CONSTANTS_GRP.G_ERES_LITE = l_signature_mode) then
   --Cancel the signature process by moving the blocked activity as required.
    FND_WF_ENGINE.COMPLETEACTIVITY(P_ITEMTYPE, P_ITEMKEY, 'LITE_MODE', 'CANCEL');
  ELSIF(EDR_CONSTANTS_GRP.G_ERES_REGULAR = l_signature_mode) then
  --Cancel the signature process by moving the blocked activity as required.
    FND_WF_ENGINE.COMPLETEACTIVITY(P_ITEMTYPE, P_ITEMKEY, 'PSIG_ESIGN_SIGNER_LIST', 'PAGE_CANCEL');
  END IF;


  IF P_UPDATE_ORES_TEMP_TABLES = FND_API.G_TRUE THEN
    UPDATE EDR_PROCESS_ERECORDS_T
      SET STATUS = EDR_CONSTANTS_GRP.G_ERROR_STATUS
    WHERE ERECORD_ID = L_ERECORD_ID;

    UPDATE EDR_ERESMANAGER_T
      SET OVERALL_STATUS = EDR_CONSTANTS_GRP.G_ERROR_STATUS
    WHERE ERES_PROCESS_ID IN (SELECT ERES_PROCESS_ID
                              FROM   EDR_PROCESS_ERECORDS_T
                              WHERE  ERECORD_ID = L_ERECORD_ID);
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_EINITIALS_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','CANCEL_SIGNATURE');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_EINITIALS_PVT.CANCEL_SIGNATURE',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;

END CANCEL_SIGNATURE;


END EDR_EINITIALS_PVT;

/
