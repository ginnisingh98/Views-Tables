--------------------------------------------------------
--  DDL for Package Body EDR_PSIG_MSCA_PAGE_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_PSIG_MSCA_PAGE_FLOW" AS
/* $Header: EDRVMPFB.pls 120.1.12000000.1 2007/01/18 05:56:26 appldev ship $ */


--Process the signature response

PROCEDURE PROCESS_RESPONSE( p_event_id                IN NUMBER,
                            p_erecord_id              IN NUMBER,
                            p_user_name               IN VARCHAR2,
                            p_action_code             IN VARCHAR2,
                            p_action_meaning          IN VARCHAR2,
                            p_sign_sequence           IN NUMBER,
                            p_signature_param_names   IN FND_TABLE_OF_VARCHAR2_255,
                            p_signature_param_values  IN FND_TABLE_OF_VARCHAR2_255,
                            p_sig_param_display_names IN FND_TABLE_OF_VARCHAR2_255,
                            x_error_code              OUT NOCOPY NUMBER,
                            x_error_msg               OUT NOCOPY VARCHAR2)
IS
       l_signer_code            VARCHAR2(30) ;
       l_signing_reason_code    VARCHAR2(32) ;
       l_signer_comment         VARCHAR2(4000);
       l_sign_sequence          NUMBER;
       l_count                  NUMBER;
       l_error_num              NUMBER;
       l_error_msg              VARCHAR2(1000);
       l_sig_id                 NUMBER;
       l_param_table            EDR_PSIG.params_table;
       POST_SIGNATURE_ERROR     EXCEPTION;
       EDR_PSIG_DOC_ERR         EXCEPTION;
       EDR_PSIG_OUT_OF_SEQUENCE EXCEPTION;
       l_status VARCHAR2(20);

       pragma AUTONOMOUS_TRANSACTION;

BEGIN

  --Validate the signature sequence
  SELECT min(signature_sequence) into l_sign_sequence
  FROM   edr_esignatures
  WHERE  EVENT_ID = p_event_id
  and    SIGNATURE_STATUS = 'PENDING';

  --If the sequence is out of order, then raise an error.
  IF l_sign_sequence <> p_sign_sequence THEN
    raise EDR_PSIG_OUT_OF_SEQUENCE;
  END IF;

  --Loop through each signature parameter.
  FOR i IN p_signature_param_names.first..p_signature_param_names.last LOOP
    l_param_table(i).param_name := p_signature_param_names(i);
    l_param_table(i).param_value := p_signature_param_values(i);

    IF l_param_table(i).param_name = 'WF_SIGNER_TYPE' THEN
      --We need both the signer code and meaning
      --Code is required for Workflow action history region.
      --Meaning is required for evidence store.
      l_signer_code := l_param_table(i).param_value;
      EDR_STANDARD.GET_MEANING('EDR_SIGNATURE_TYPES', l_signer_code,  l_param_table(i).param_value);

    ELSIF  l_param_table(i).param_name = 'REASON_CODE' THEN
      --We need both signing reason code and meaning.
      --Code is required for workflow action history region.
      --Meaning is required for evidence store.
      l_signing_reason_code := l_param_table(i).param_value;
      EDR_STANDARD.GET_MEANING('EDR_SIGNING_REASONS', l_signing_reason_code,  l_param_table(i).param_value);

    ELSIF  l_param_table(i).param_name = 'SIGNERS_COMMENT' THEN
      l_signer_comment := l_param_table(i).param_value;
    END IF;

    l_param_table(i).Param_displayname := p_sig_param_display_names(i);
  END LOOP;

  --Update EDR_ESIGNATURES table with the signature details.
  --As this table is associated with workflow, the signer code and signer reason
  --code is passed.
  UPDATE EDR_ESIGNATURES
    SET SIGNATURE_STATUS      = p_action_code ,
        SIGNATURE_TYPE        = l_SIGNER_code,
        SIGNATURE_REASON_CODE = l_signing_reason_code,
        SIGNATURE_TIMESTAMP   = SYSDATE,
        SIGNER_COMMENTS       = l_signer_comment
   WHERE         EVENT_ID = p_event_id
   AND          user_name = p_user_name
   AND SIGNATURE_SEQUENCE = p_sign_sequence;


  --Post the signature details into the evidence store for the e-record.
  -- Bug 4190358 : Start
  -- The Evidence store id should be passed as Null as this is not the document id we maintain.

  EDR_PSIG.postSignature(P_DOCUMENT_ID =>p_erecord_id,
                         P_EVIDENCE_STORE_ID => null,
                         P_USER_NAME => p_user_name,
                         P_USER_RESPONSE => p_action_meaning,
                         P_SIGNATURE_ID => l_sig_id,
                         P_ERROR => l_error_num,
                         P_ERROR_MSG => l_error_msg);


  -- Bug 4190358 : End
  --Raise an error based on the value of l_error_num
  if l_error_num is not null then
    raise POST_SIGNATURE_ERROR;
  end if;

  --Post the signature parameters to the evidence store.
  --The signature parameters would contain the signer meaning
  --and the signining reason meaning.
  EDR_PSIG.postSignatureParameter(P_SIGNATURE_ID => l_sig_id,
                          				P_PARAMETERS   => l_param_table,
       				                    P_ERROR        => l_error_num,
                           			  P_ERROR_MSG    => l_error_msg);

  if l_error_num is not null then
    raise POST_SIGNATURE_ERROR;
  end if;

  --Update the document status in evidence store based on the action code.
  IF (p_erecord_id IS NOT NULL AND p_action_code = 'REJECTED')  THEN
    EDR_PSIG.changeDocumentStatus(P_DOCUMENT_ID       => p_erecord_id,
                                  P_STATUS            => p_action_code,
                                  P_ERROR             => l_error_num,
                                  P_ERROR_MSG         => l_error_msg);
    IF l_ERROR_NUM IS NOT NULL THEN
      RAISE EDR_PSIG_DOC_ERR;
    END IF;

  END IF;

  COMMIT;

  EXCEPTION
    WHEN EDR_PSIG_OUT_OF_SEQUENCE THEN
      ROLLBACK;
      x_error_code := SQLCODE;
      FND_MESSAGE.SET_NAME('EDR','EDR_MSCA_SIG_OUT_OF_SEQUENCE');
      x_error_msg := FND_MESSAGE.get;
    WHEN OTHERS THEN
       ROLLBACK;
       x_error_msg := l_error_msg;
       x_error_code := l_error_num;
       APP_EXCEPTION.RAISE_EXCEPTION;
  END PROCESS_RESPONSE;



--This procedure is used to process the cancel response in pageflow.
PROCEDURE PROCESS_CANCEL(p_erecord_id IN NUMBER,
                         p_itemtype   IN VARCHAR2,
                         p_itemkey    IN VARCHAR2,
                         x_error_code OUT NOCOPY NUMBER,
                         x_error_msg OUT NOCOPY VARCHAR2)
IS

pragma AUTONOMOUS_TRANSACTION;

BEGIN

  --Update the document status in evidence store for the e-record.
  EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID => p_erecord_id,
	                               P_STATUS      => 'CANCEL' ,
	                               P_ERROR       => x_error_code,
	                               P_ERROR_MSG   => x_error_msg);

  --Complete the pageflow block activity.
  PROCESS_MSCA_BLOCKED_ACTIVITY(p_itemtype => p_itemtype,
                                p_itemkey => p_itemkey,
                                p_action => 'DONE',
                                x_error_code => x_error_code ,
                                x_error_msg => x_error_msg);

  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      x_error_code := SQLCODE;
      x_error_msg := SQLERRM;
      APP_EXCEPTION.RAISE_EXCEPTION;
END PROCESS_CANCEL;


--This procedure is used to process the 'DEFER' response in pageflow.
PROCEDURE PROCESS_DEFER(p_erecord_id IN NUMBER,
                        p_itemtype   IN VARCHAR2,
                        p_itemkey    IN VARCHAR2,
                        x_error_code OUT NOCOPY NUMBER,
                        x_error_msg OUT NOCOPY VARCHAR2)
is

pragma AUTONOMOUS_TRANSACTION;

BEGIN

  --Update the evidence store document status to 'PENDING'
  EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID => p_erecord_id,
	                               P_STATUS      => 'PENDING' ,
                                 P_ERROR       => x_error_code,
                                 P_ERROR_MSG   => x_error_msg);

  --Process the MSCA Block activity for "DEFER" response.
  PROCESS_MSCA_BLOCKED_ACTIVITY(p_itemtype   => p_itemtype,
                                p_itemkey    => p_itemkey,
                                p_action     => 'DEFER',
                                x_error_code => x_error_code ,
                                x_error_msg  => x_error_msg);

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      x_error_code := SQLCODE;
      x_error_msg := SQLERRM;
    APP_EXCEPTION.RAISE_EXCEPTION;
END PROCESS_DEFER;


--This procedure is used to process the pageflow block activity defined for MSCA.
PROCEDURE PROCESS_MSCA_BLOCKED_ACTIVITY(p_itemtype   IN VARCHAR2,
                                        p_itemkey    IN VARCHAR2,
                                        p_action     IN VARCHAR2,
                                        x_error_code OUT NOCOPY NUMBER,
                                        x_error_msg  OUT NOCOPY VARCHAR2)

IS

BEGIN

  --Move pageflow to MSCA Block activity.
  FND_WF_ENGINE.COMPLETEACTIVITY(p_itemtype, p_itemkey, 'MSCA', p_action);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      x_error_msg := SQLERRM;
    APP_EXCEPTION.RAISE_EXCEPTION;

END PROCESS_MSCA_BLOCKED_ACTIVITY;


--Wrapper procedure over EDR_PSIG.CLOSEDOCUMENT
PROCEDURE CLOSE_DOCUMENT(P_DOCUMENT_ID          IN  NUMBER,
                         X_ERROR                OUT NOCOPY NUMBER,
                         X_ERROR_MSG            OUT NOCOPY VARCHAR2
                        )

is

  pragma AUTONOMOUS_TRANSACTION;

BEGIN

  EDR_PSIG.ClOSEDOCUMENT(P_DOCUMENT_ID          => P_DOCUMENT_ID,
                         P_ERROR                => X_ERROR,
                         P_ERROR_MSG            => X_ERROR_MSG
                        );
  COMMIT;

EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  x_error := SQLCODE;
  x_error_msg := SQLERRM;

APP_EXCEPTION.RAISE_EXCEPTION;

END CLOSE_DOCUMENT;

END EDR_PSIG_MSCA_PAGE_FLOW;

/
