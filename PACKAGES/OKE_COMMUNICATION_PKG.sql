--------------------------------------------------------
--  DDL for Package OKE_COMMUNICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_COMMUNICATION_PKG" AUTHID CURRENT_USER as
/* $Header: OKECMPLS.pls 115.7 2002/11/21 22:45:35 ybchen ship $ */


  PROCEDURE Lock_Row(
             X_k_header_id                NUMBER,
             X_communication_num          VARCHAR2,
             X_communication_date         DATE,
             X_type                       VARCHAR2,
             X_reason_code                VARCHAR2,
             X_party_location             VARCHAR2,
             X_party_role                 VARCHAR2,
             X_party_contact              VARCHAR2,
             X_action_code                VARCHAR2,
             X_priority_code              VARCHAR2,
             X_owner                      NUMBER,
             X_k_party_id                 NUMBER,
             X_wf_item_type               VARCHAR2,
             X_wf_process                 VARCHAR2,
             X_wf_item_key                VARCHAR2,
             X_text                       LONG,
             X_funding_ref1               VARCHAR2,
             X_funding_ref2               VARCHAR2,
             X_funding_ref3               VARCHAR2,
             X_funding_source_id          NUMBER,
             X_k_line_id                  NUMBER,
             X_deliverable_id             NUMBER,
             X_chg_request_id             NUMBER,
             X_project_id                 NUMBER,
             X_task_id                    NUMBER,
             X_Attribute_Category         VARCHAR2,
             X_Attribute1                 VARCHAR2,
             X_Attribute2                 VARCHAR2,
             X_Attribute3                 VARCHAR2,
             X_Attribute4                 VARCHAR2,
             X_Attribute5                 VARCHAR2,
             X_Attribute6                 VARCHAR2,
             X_Attribute7                 VARCHAR2,
             X_Attribute8                 VARCHAR2,
             X_Attribute9                 VARCHAR2,
             X_Attribute10                VARCHAR2,
             X_Attribute11                VARCHAR2,
             X_Attribute12                VARCHAR2,
             X_Attribute13                VARCHAR2,
             X_Attribute14                VARCHAR2,
             X_Attribute15                VARCHAR2
             );



  PROCEDURE Update_Row(
             X_k_header_id                NUMBER,
             X_communication_num          VARCHAR2,
             X_communication_date         DATE,
             X_type                       VARCHAR2,
             X_reason_code                VARCHAR2,
             X_party_location             VARCHAR2,
             X_party_role                 VARCHAR2,
             X_party_contact              VARCHAR2,
             X_action_code                VARCHAR2,
             X_priority_code              VARCHAR2,
             X_owner                      NUMBER,
             X_k_party_id                 NUMBER,
             X_wf_item_type        IN OUT NOCOPY VARCHAR2,
             X_wf_process          IN OUT NOCOPY VARCHAR2,
             X_wf_item_key         IN OUT NOCOPY VARCHAR2,
             X_text                       LONG,
             X_funding_ref1               VARCHAR2,
             X_funding_ref2               VARCHAR2,
             X_funding_ref3               VARCHAR2,
             X_funding_source_id          NUMBER,
             X_k_line_id                  NUMBER,
             X_deliverable_id             NUMBER,
             X_chg_request_id             NUMBER,
             X_project_id                 NUMBER,
             X_task_id                    NUMBER,
             X_Last_Update_Date           DATE,
             X_Last_Updated_By            NUMBER,
             X_Last_Update_Login          NUMBER,
             X_Attribute_Category         VARCHAR2,
             X_Attribute1                 VARCHAR2,
             X_Attribute2                 VARCHAR2,
             X_Attribute3                 VARCHAR2,
             X_Attribute4                 VARCHAR2,
             X_Attribute5                 VARCHAR2,
             X_Attribute6                 VARCHAR2,
             X_Attribute7                 VARCHAR2,
             X_Attribute8                 VARCHAR2,
             X_Attribute9                 VARCHAR2,
             X_Attribute10                VARCHAR2,
             X_Attribute11                VARCHAR2,
             X_Attribute12                VARCHAR2,
             X_Attribute13                VARCHAR2,
             X_Attribute14                VARCHAR2,
             X_Attribute15                VARCHAR2
             );

  PROCEDURE Insert_Row(
             X_Rowid               IN OUT NOCOPY VARCHAR2,
             X_k_header_id                NUMBER,
             X_communication_num          VARCHAR2,
             X_communication_date         DATE,
             X_type                       VARCHAR2,
             X_reason_code                VARCHAR2,
             X_party_location             VARCHAR2,
             X_party_role                 VARCHAR2,
             X_party_contact              VARCHAR2,
             X_action_code                VARCHAR2,
             X_priority_code              VARCHAR2,
             X_owner                      NUMBER,
             X_k_party_id                 NUMBER,
             X_wf_item_type        IN OUT NOCOPY VARCHAR2,
             X_wf_process          IN OUT NOCOPY VARCHAR2,
             X_wf_item_key         IN OUT NOCOPY VARCHAR2,
             X_text                       LONG,
             X_funding_ref1               VARCHAR2,
             X_funding_ref2               VARCHAR2,
             X_funding_ref3               VARCHAR2,
             X_funding_source_id          NUMBER,
             X_k_line_id                  NUMBER,
             X_deliverable_id             NUMBER,
             X_chg_request_id             NUMBER,
             X_project_id                 NUMBER,
             X_task_id                    NUMBER,
             X_Last_Update_Date           DATE,
             X_Last_Updated_By            NUMBER,
             X_Creation_Date              DATE,
             X_Created_By                 NUMBER,
             X_Last_Update_Login          NUMBER,
             X_Attribute_Category         VARCHAR2,
             X_Attribute1                 VARCHAR2,
             X_Attribute2                 VARCHAR2,
             X_Attribute3                 VARCHAR2,
             X_Attribute4                 VARCHAR2,
             X_Attribute5                 VARCHAR2,
             X_Attribute6                 VARCHAR2,
             X_Attribute7                 VARCHAR2,
             X_Attribute8                 VARCHAR2,
             X_Attribute9                 VARCHAR2,
             X_Attribute10                VARCHAR2,
             X_Attribute11                VARCHAR2,
             X_Attribute12                VARCHAR2,
             X_Attribute13                VARCHAR2,
             X_Attribute14                VARCHAR2,
             X_Attribute15                VARCHAR2
             );

    PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END OKE_COMMUNICATION_PKG;

 

/