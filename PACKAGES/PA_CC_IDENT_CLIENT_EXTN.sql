--------------------------------------------------------
--  DDL for Package PA_CC_IDENT_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_IDENT_CLIENT_EXTN" AUTHID CURRENT_USER AS
--  $Header: PACCIXTS.pls 120.4 2006/07/25 19:40:05 skannoji noship $
/*#
 * This package contains the extensions you can use to implement your business rules for various aspects of cross charge feature.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Cross Charge Processing Method Override
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_IC_TRANSACTION
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * You can use this extension to enforce cross charge rules at a higher level in the organization hierarchy than the level at which
 * you assign resources and projects.
 * @param P_PrvdrOrganizationId Identifier of the provider organization
 * @rep:paraminfo {@rep:required}
 * @param P_PrvdrOrgId Identifier of the provider operating unit
 * @rep:paraminfo {@rep:required}
 * @param P_RecvrOrganizationId Identifier of the receiver organization
 * @rep:paraminfo {@rep:required}
 * @param P_RecvrOrgId Identifier of the receiver operating unit
 * @rep:paraminfo {@rep:required}
 * @param P_TransId Identifier of the transaction
 * @rep:paraminfo {@rep:required}
 * @param P_SysLink Expenditure type class
 * @rep:paraminfo {@rep:required}
 * @param P_calling_mode Number of archive and purge records to be processed before commitment
 * @rep:paraminfo {@rep:required}
 * @param X_Status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param X_PrvdrOrganizationId Output provider organization identifier
 * @rep:paraminfo {@rep:required}
 * @param X_RecvrOrganizationId Output receiver organization identifier
 * @rep:paraminfo {@rep:required}
 * @param X_Error_Stage The point of occurrence of an error
 * @rep:paraminfo {@rep:required}
 * @param X_Error_Code Error handling code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Override Provider Receiver
 * @rep:compatibility S
*/
PROCEDURE OVERRIDE_PRVDR_RECVR (
          P_PrvdrOrganizationId   IN  NUMBER,
          P_PrvdrOrgId            IN  NUMBER,
          P_RecvrOrganizationId   IN  NUMBER,
          P_RecvrOrgId            IN  NUMBER,
          P_TransId               IN  NUMBER,
          P_SysLink               IN  VARCHAR2,
          P_calling_mode          IN  VARCHAR2 default 'TRANSACTION',
          X_Status                IN OUT NOCOPY VARCHAR2,
          X_PrvdrOrganizationId   IN OUT NOCOPY NUMBER,
          X_RecvrOrganizationId   IN OUT NOCOPY NUMBER,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER);

/*#
 * You can use this extension to enforce cross charge rules at a higher level in the organization hierarchy than the level at which
 * you assign resources and projects.
 * @param P_PrvdrOrganizationId Identifier of the provider organization
 * @rep:paraminfo {@rep:required}
 * @param P_RecvrOrganizationId Identifier of the receiver organization
 * @rep:paraminfo {@rep:required}
 * @param P_PrvdrOrgId Identifier of the provider operating unit
 * @rep:paraminfo {@rep:required}
 * @param P_RecvrOrgId Identifier of the receiver operating unit
 * @rep:paraminfo {@rep:required}
 * @param P_PrvdrLEId Identifier of the provider legal entity
 * @rep:paraminfo {@rep:required}
 * @param P_RecvrLEId Identifier of the receiver legal entity
 * @rep:paraminfo {@rep:required}
 * @param P_PersonId Identifier of the employee who charged the transaction
 * @rep:paraminfo {@rep:required}
 * @param P_ProjectId Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param P_TaskId Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param P_SysLink Expenditure type class
 * @rep:paraminfo {@rep:required}
 * @param P_TransDate Transaction date
 * @rep:paraminfo {@rep:required}
 * @param P_TransSource External source of the transaction, if the source was external
 * @rep:paraminfo {@rep:required}
 * @param P_TransId Identifier of the transaction interface
 * @rep:paraminfo {@rep:required}
 * @param P_CrossChargeCode Entered value for cross charge identification. Must
 * be a valid cross charge code from the lookup CC_CROSS_CHARGE_CODE lookup
 * @rep:paraminfo {@rep:required}
 * @param P_CrossChargeType Cross charge type. Must be a valid cross charge type from the lookup CC_CROSS_CHARGE_TYPE lookup
 * @rep:paraminfo {@rep:required}
 * @param P_calling_mode Number of archive and purge records to be processed before commitment
 * @param X_OvrridCrossChargeCode New cross charge code
 * @rep:paraminfo {@rep:required}
 * @param X_Status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param X_Error_Stage The point of occurrence of an error
 * @rep:paraminfo {@rep:required}
 * @param X_Error_Code Error handling code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Cross Charge Processing Method
 * @rep:compatibility S
*/
PROCEDURE OVERRIDE_CC_PROCESSING_METHOD (
          P_PrvdrOrganizationId   IN  NUMBER,
          P_RecvrOrganizationId   IN  NUMBER,
          P_PrvdrOrgId            IN  NUMBER,
          P_RecvrOrgId            IN  NUMBER,
          P_PrvdrLEId             IN  NUMBER,
          P_RecvrLEId             IN  NUMBER,
          P_PersonId              IN  NUMBER,
          P_ProjectId             IN  NUMBER,
          P_TaskId                IN  NUMBER,
          P_SysLink               IN  VARCHAR2,
          P_TransDate             IN  DATE,
          P_TransSource           IN  VARCHAR2,
          P_TransId               IN  NUMBER,
          P_CrossChargeCode       IN  VARCHAR2,
          P_CrossChargeType       IN  VARCHAR2,
          P_calling_mode          IN  VARCHAR2 default 'TRANSACTION',
          X_OvrridCrossChargeCode OUT NOCOPY VARCHAR2,
          X_Status                IN OUT NOCOPY VARCHAR2,
          X_Error_Stage           OUT NOCOPY VARCHAR2,
          X_Error_Code            OUT NOCOPY NUMBER);

END PA_CC_IDENT_CLIENT_EXTN;

 

/
