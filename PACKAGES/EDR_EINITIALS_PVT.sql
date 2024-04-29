--------------------------------------------------------
--  DDL for Package EDR_EINITIALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_EINITIALS_PVT" AUTHID CURRENT_USER AS
/*$Header: EDRVINTS.pls 120.3.12000000.1 2007/01/18 05:56:18 appldev ship $ */

-- Start of comments
-- API name             : GET_WF_ATTRIBUTES
-- Type                 : Private.
-- Function             : This procedure is primarily used to fetch the values of the specified
--                        workflow attributes.
-- Pre-reqs             : None
--
-- IN                   : P_ITEMTYPE     - The workflow item type.
--                      : P_ITEMKEY      - The workflow item key.
--                      : P_PARAM_NAMES  - The parameter names whose values are required.
--
-- OUT                  : X_PARAM_VALUES - The corresponding parameter values.
PROCEDURE GET_WF_ATTRIBUTES(P_ITEMTYPE     IN         VARCHAR2,
                            P_ITEMKEY      IN         VARCHAR2,
                            P_PARAM_NAMES  IN         FND_TABLE_OF_VARCHAR2_255,
                            X_PARAM_VALUES OUT NOCOPY FND_TABLE_OF_VARCHAR2_255);



-- Start of comments
-- API name             : GET_ERECORD_DETAILS
-- Type                 : Private.
-- Function             : This procedure would return the values of the specified workflow attributes and also
--                        the e-record text associated with the workflow item type and item key.
-- Pre-reqs             : None
--
-- IN                   : P_ITEMTYPE     - The workflow item type.
--                      : P_ITEMKEY      - The workflow item key.
--                      : P_PARAM_NAMES  - The parameter names whose values are required.
--
-- OUT                  : X_PARAM_VALUES - The corresponding parameter values.
--                      : X_ERECORD_TEXT - The e-record text.
PROCEDURE GET_ERECORD_DETAILS(P_ITEMTYPE     IN         VARCHAR2,
                              P_ITEMKEY      IN         VARCHAR2,
                              P_PARAM_NAMES  IN         FND_TABLE_OF_VARCHAR2_255,
                              X_PARAM_VALUES OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
                              X_ERECORD_TEXT OUT NOCOPY CLOB);

-- Start of comments
-- API name             : GET_ERECORD_DETAILS
-- Type                 : Private.
-- Function             : This procedure would return the values of the specified workflow attributes and also
--                        the e-record text associated with the ERES process ID.
-- Pre-reqs             : None
--
-- IN                   : P_PROCESS_ID     - The ERES process ID.
--                      : P_PARAM_NAMES    - The parameter names whose values are required.
--
-- OUT                  : X_ITEMTYPE        - The workflow item type associated with the process ID.
--                      : X_ITEMKEY         - The workflow item key associated with the process ID.
--                      : X_PARAM_VALUES    - The workflow attribute values.
--                      : X_ERECORD_COUNT   - The number of e-records associated with the process ID.
--                      : X_ESIGN_COMPLETED - A flag indicating if e-signature is already completed for the e-record
--                                            associated with the process ID.
--                      : X_ERECORD_TEXT    - The e-record text.

PROCEDURE GET_ERECORD_DETAILS(P_PROCESS_ID      IN         VARCHAR2,
                              P_PARAM_NAMES     IN         FND_TABLE_OF_VARCHAR2_255,
                              X_ITEMTYPE        OUT NOCOPY VARCHAR2,
                              X_ITEMKEY         OUT NOCOPY VARCHAR2,
                              X_PARAM_VALUES    OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
                              X_ERECORD_COUNT   OUT NOCOPY NUMBER,
                              X_ESIGN_COMPLETED OUT NOCOPY VARCHAR2,
                              X_ERECORD_TEXT    OUT NOCOPY CLOB);


-- Start of comments
-- API name             : POST_SIGNATURE_DETAILS
-- Type                 : Private.
-- Function             : This procedure posts the signature details as specified in the API parameters.
--                        A return flag would indicate if the signature process was successful for the approver
--                        specified in the API parameters.

-- Pre-reqs             : None
--
-- IN                   : P_ERECORD_ID              - The ERES process ID.
--                      : P_ITEMTYPE                - The workflow item type.
--                      : P_ITEMKEY                 - The workflow item key.
--                      : P_SIGNATURE_ID            - The signature ID.
--                      : P_ROLE_NAME               - The role names associated with the approver.
--                      : P_SIGNER_NAME             - The signer name.
--                      : P_SIGNER_PASSWORD         - The password used to sign the transaction.
--                      : P_SIGNATURE_SEQUENCE      - The signature sequence.
--                      : P_SIGNER_RESPONSE         - The signer response value.
--                      : P_SIGNER_TYPE             - The signer type value.
--                      : P_SIGNER_COMMENTS         - The signer comments value.
--                      : P_SIGNING_REASON          - The signing reason value.

-- OUT                  : X_IS_APPROVER_VALID - A flag indicating if the approver details are valid.
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
				 X_SIGNER_DISPLAY_NAME     OUT NOCOPY VARCHAR2);


-- Start of comments
-- API name             : COMPLETE_SIGNATURE
-- Type                 : Private.
-- Function             : This procedure completes the signature process for the specified on the workflow item type and item key.
--                        It returns the final e-record status for the specified e-record ID.

-- Pre-reqs             : None
--
-- IN                   : P_ITEMTYPE                - The workflow item type.
--                      : P_ITEMKEY                 - The workflow item key.
--                      : P_ERECORD_ID              - The e-record ID whose signature is to be canceled.
--                      : P_UPDATE_ORES_TEMP_TABLES - A flag indicating if the ORES temp tables should be updated.
--                      : X_ERECORD_STATUS          -  The final e-record status for the specified e-record ID.

PROCEDURE COMPLETE_SIGNATURE(P_ITEMTYPE                IN  VARCHAR2,
                             P_ITEMKEY                 IN  VARCHAR2,
                             P_ERECORD_ID              IN  VARCHAR2,
                             P_UPDATE_ORES_TEMP_TABLES IN  VARCHAR2,
			     X_ERECORD_STATUS          OUT NOCOPY VARCHAR2);






-- Start of comments
-- API name             : CANCEL_SIGNATURE
-- Type                 : Private.
-- Function             : This procedure cancels the signature process based on the workflow item type and item key.
-- Pre-reqs             : None
--
-- IN                   : P_ITEMTYPE                - The workflow item type.
--                      : P_ITEMKEY                 - The workflow item key.
--                      : P_ERECORD_ID              - The e-record ID whose signature is to be canceled.
--                      : P_UPDATE_ORES_TEMP_TABLES - A flag indicating if the ORES temp tables should be updated.
PROCEDURE CANCEL_SIGNATURE(P_ITEMTYPE                IN VARCHAR2,
                           P_ITEMKEY                 IN VARCHAR2,
                           P_ERECORD_ID              IN VARCHAR2,
                           P_UPDATE_ORES_TEMP_TABLES IN VARCHAR2);


END EDR_EINITIALS_PVT;

 

/
