--------------------------------------------------------
--  DDL for Package Body OKE_COMMUNICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_COMMUNICATION_PKG" as
/* $Header: OKECMPLB.pls 115.10 2002/11/21 22:44:59 ybchen ship $ */


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
) is

  cursor c is
    select k_header_id,
           communication_num,
           communication_date,
           type,
           reason_code,
           party_location,
           party_role,
           party_contact,
           action_code,
           priority_code,
           owner,
           k_party_id,
           wf_item_type,
           wf_process,
           wf_item_key,
           text,
           funding_ref1,
           funding_ref2,
           funding_ref3,
           funding_source_id,
           chg_request_id,
           k_line_id,
           deliverable_id,
           project_id,
           task_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
      from OKE_K_COMMUNICATIONS
      where k_header_id = X_k_header_id
      and communication_num = X_communication_num
      for update of k_header_id, communication_num nowait;

  recinfo c%rowtype;

begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (
       ((rtrim(recinfo.type) = rtrim(X_type))
           OR ((recinfo.type is null) AND (X_type is null)))
       AND ((recinfo.communication_date = X_communication_date)
           OR ((recinfo.communication_date is null) AND (X_communication_date is null)))
       AND ((rtrim(recinfo.reason_code) = rtrim(X_reason_code))
           OR ((recinfo.reason_code is null) AND (X_reason_code is null)))
       AND ((rtrim(recinfo.party_location) = rtrim(X_party_location))
           OR ((recinfo.party_location is null) AND (X_party_location is null)))
       AND ((rtrim(recinfo.party_role) = rtrim(X_party_role))
           OR ((recinfo.party_role is null) AND (X_party_role is null)))
       AND ((rtrim(recinfo.party_contact) = rtrim(X_party_contact))
           OR ((recinfo.party_contact is null) AND (X_party_contact is null)))
       AND ((rtrim(recinfo.action_code) = rtrim(X_action_code))
           OR ((recinfo.action_code is null) AND (X_action_code is null)))
       AND ((rtrim(recinfo.priority_code) = rtrim(X_priority_code))
           OR ((recinfo.priority_code is null) AND (X_priority_code is null)))
       AND ((rtrim(recinfo.wf_item_type) = rtrim(X_wf_item_type))
           OR ((recinfo.wf_item_type is null) AND (X_wf_item_type is null)))
       AND ((rtrim(recinfo.wf_process) = rtrim(X_wf_process))
           OR ((recinfo.wf_process is null) AND (X_wf_process is null)))
       AND ((rtrim(recinfo.wf_item_key) = rtrim(X_wf_item_key))
           OR ((recinfo.wf_item_key is null) AND (X_wf_item_key is null)))
       AND ((rtrim(recinfo.text) = rtrim(X_text))
           OR ((recinfo.text is null) AND (X_text is null)))
       AND ((rtrim(recinfo.funding_ref1) = rtrim(X_funding_ref1))
           OR ((recinfo.funding_ref1 is null) AND (X_funding_ref1 is null)))
       AND ((rtrim(recinfo.funding_ref2) = rtrim(X_funding_ref2))
           OR ((recinfo.funding_ref2 is null) AND (X_funding_ref2 is null)))
       AND ((rtrim(recinfo.funding_ref3) = rtrim(X_funding_ref3))
           OR ((recinfo.funding_ref3 is null) AND (X_funding_ref3 is null)))
       AND ((rtrim(recinfo.funding_source_id) = rtrim(X_funding_source_id))
           OR ((recinfo.funding_source_id is null) AND (X_funding_source_id is null)))
       AND ((rtrim(recinfo.chg_request_id ) = rtrim(X_chg_request_id ))
           OR ((recinfo.chg_request_id is null) AND (X_chg_request_id is null)))
       AND ((rtrim(recinfo.k_line_id ) = rtrim(X_k_line_id ))
           OR ((recinfo.k_line_id is null) AND (X_k_line_id is null)))
       AND ((rtrim(recinfo.deliverable_id ) = rtrim(X_deliverable_id ))
           OR ((recinfo.deliverable_id is null) AND (X_deliverable_id is null)))
       AND ((rtrim(recinfo.project_id ) = rtrim(X_project_id ))
           OR ((recinfo.project_id is null) AND (X_project_id is null)))
       AND ((rtrim(recinfo.task_id ) = rtrim(X_task_id ))
           OR ((recinfo.task_id is null) AND (X_task_id is null)))
       AND ((rtrim(recinfo.attribute_category) = rtrim(X_Attribute_Category))
           OR ((recinfo.attribute_category is null) AND (X_Attribute_Category is null)))
       AND ((rtrim(recinfo.attribute1) = rtrim(X_Attribute1))
           OR ((recinfo.attribute1 is null) AND (X_Attribute1 is null)))
       AND ((rtrim(recinfo.attribute2) = rtrim(X_Attribute2))
           OR ((recinfo.attribute2 is null) AND (X_Attribute2 is null)))
       AND ((rtrim(recinfo.attribute3) = rtrim(X_Attribute3))
           OR ((recinfo.attribute3 is null) AND (X_Attribute3 is null)))
       AND ((rtrim(recinfo.attribute4) = rtrim(X_Attribute4))
           OR ((recinfo.attribute4 is null) AND (X_Attribute4 is null)))
       AND ((rtrim(recinfo.attribute5) = rtrim(X_Attribute5))
           OR ((recinfo.attribute5 is null) AND (X_Attribute5 is null)))
       AND ((rtrim(recinfo.attribute6) = rtrim(X_Attribute6))
           OR ((recinfo.attribute6 is null) AND (X_Attribute6 is null)))
       AND ((rtrim(recinfo.attribute7) = rtrim(X_Attribute7))
           OR ((recinfo.attribute7 is null) AND (X_Attribute7 is null)))
       AND ((rtrim(recinfo.attribute8) = rtrim(X_Attribute8))
           OR ((recinfo.attribute8 is null) AND (X_Attribute8 is null)))
       AND ((rtrim(recinfo.attribute9) = rtrim(X_Attribute9))
           OR ((recinfo.attribute9 is null) AND (X_Attribute9 is null)))
       AND ((rtrim(recinfo.attribute10) = rtrim(X_Attribute10))
           OR ((recinfo.attribute10 is null) AND (X_Attribute10 is null)))
       AND ((rtrim(recinfo.attribute11) = rtrim(X_Attribute11))
           OR ((recinfo.attribute11 is null) AND (X_Attribute11 is null)))
       AND ((rtrim(recinfo.attribute12) = rtrim(X_Attribute12))
           OR ((recinfo.attribute12 is null) AND (X_Attribute12 is null)))
       AND ((rtrim(recinfo.attribute13) = rtrim(X_Attribute13))
           OR ((recinfo.attribute13 is null) AND (X_Attribute13 is null)))
       AND ((rtrim(recinfo.attribute14) = rtrim(X_Attribute14))
           OR ((recinfo.attribute14 is null) AND (X_Attribute14 is null)))
       AND ((rtrim(recinfo.attribute15) = rtrim(X_Attribute15))
           OR ((recinfo.attribute15 is null) AND (X_Attribute15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end Lock_Row;


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

  ) is

  x_prev_action_code OKE_K_COMMUNICATIONS.action_code%TYPE;

  cursor C is
    select wf_item_type
    ,      wf_process
    ,      wf_item_key
    from   OKE_K_COMMUNICATIONS
    where  k_header_id = X_k_header_id
    and communication_num = X_communication_num;

  cursor C_prev is
    select action_code
    from   OKE_K_COMMUNICATIONS
    where  k_header_id = X_k_header_id
    and communication_num = X_communication_num;

begin
  open c_prev;
  fetch c_prev into X_prev_action_code;
  close c_prev;


  update OKE_K_COMMUNICATIONS
  set
       communication_date  = X_communication_date,
       type                = X_type,
       reason_code         = X_reason_code,
       party_location      = X_party_location,
       party_role          = X_party_role,
       party_contact       = X_party_contact,
       action_code         = X_action_code,
       priority_code       = X_priority_code,
       owner               = X_owner,
       k_party_id          = X_k_party_id,
       wf_item_type        = X_wf_item_type,
       wf_process          = X_wf_process,
       wf_item_key         = X_wf_item_key,
       text                = X_text,
       funding_ref1        = X_funding_ref1,
       funding_ref2        = X_funding_ref2,
       funding_ref3        = X_funding_ref3,
       funding_source_id   = X_funding_source_id,
       k_line_id           = X_k_line_id,
       deliverable_id      = X_deliverable_id,
       chg_request_id      = X_chg_request_id,
       project_id          = X_project_id,
       task_id             = X_task_id,
       Last_Update_Date    = X_Last_Update_Date,
       Last_Updated_By     = X_Last_Updated_By,
       Last_Update_Login   = X_Last_Update_Login,
       attribute_Category  = X_Attribute_Category,
       attribute1          = X_Attribute1,
       attribute2          = X_Attribute2,
       attribute3          = X_Attribute3,
       attribute4          = X_Attribute4,
       attribute5          = X_Attribute5,
       attribute6          = X_Attribute6,
       attribute7          = X_Attribute7,
       attribute8          = X_Attribute8,
       attribute9          = X_Attribute9,
       attribute10         = X_Attribute10,
       attribute11         = X_Attribute11,
       attribute12         = X_Attribute12,
       attribute13         = X_Attribute13,
       attribute14         = X_Attribute14,
       attribute15         = X_Attribute15
  where k_header_id = X_k_header_id
  and communication_num = X_communication_num;

  if NVL(X_prev_action_code, '@' ) <> NVL(X_Action_Code, '@' ) then
    OKE_COMM_ACT_UTILS.Comm_Action
    ( X_K_Header_ID
    , X_K_Line_ID
    , X_Deliverable_ID
    , X_Communication_Num
    , X_Type
    , X_Reason_Code
    , X_K_Party_ID
    , X_Party_Location
    , X_Party_Role
    , X_Party_Contact
    , X_Action_Code
    , X_Owner
    , X_Priority_Code
    , X_Communication_Date
    , X_Text
    , X_Last_Updated_By
    , X_Last_Update_Date
    , X_Last_Update_Login
    , X_WF_ITEM_KEY
    );
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  open c;
  fetch c into X_WF_Item_Type , X_WF_Process , X_WF_Item_Key;
  close c;

end Update_Row;

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
) is

  cursor C is
  select rowid
  ,      wf_item_type
  ,      wf_process
  ,      wf_item_key
  from   OKE_K_COMMUNICATIONS
  where  k_header_id = X_k_header_id
  and communication_num = X_communication_num;

begin

  insert into OKE_K_COMMUNICATIONS(
        k_header_id,
        communication_num,
        communication_date,
        type,
        reason_code,
        party_location,
        party_role,
        party_contact,
        action_code,
        priority_code,
        owner,
        k_party_id,
        wf_item_type,
        wf_process,
        wf_item_key,
        text,
        funding_ref1,
        funding_ref2,
        funding_ref3,
        funding_source_id,
        k_line_id,
        deliverable_id,
        chg_request_id,
        project_id,
        task_id,
        Last_Update_Date,
        Last_Updated_By,
        Creation_Date,
        Created_By,
        Last_Update_Login,
        Attribute_Category,
        Attribute1,
        Attribute2,
        Attribute3,
        Attribute4,
        Attribute5,
        Attribute6,
        Attribute7,
        Attribute8,
        Attribute9,
        Attribute10,
        Attribute11,
        Attribute12,
        Attribute13,
        Attribute14,
        Attribute15
  ) VALUES (
        X_k_header_id,
        X_communication_num,
        X_communication_date,
        X_type,
        X_reason_code,
        X_party_location,
        X_party_role,
        X_party_contact,
        X_action_code,
        X_priority_code,
        X_owner,
        X_k_party_id,
        X_wf_item_type,
        X_wf_process,
        X_wf_item_key,
        X_text,
        X_funding_ref1,
        X_funding_ref2,
        X_funding_ref3,
        X_funding_source_id,
        X_k_line_id,
        X_deliverable_id,
        X_chg_request_id,
        X_project_id,
        X_task_id,
        X_Last_Update_Date,
        X_Last_Updated_By,
        X_Creation_Date,
        X_Created_By,
        X_Last_Update_Login,
        X_Attribute_Category,
        X_Attribute1,
        X_Attribute2,
        X_Attribute3,
        X_Attribute4,
        X_Attribute5,
        X_Attribute6,
        X_Attribute7,
        X_Attribute8,
        X_Attribute9,
        X_Attribute10,
        X_Attribute11,
        X_Attribute12,
        X_Attribute13,
        X_Attribute14,
        X_Attribute15
  );

  OKE_COMM_ACT_UTILS.Comm_Action
  ( X_K_Header_ID
  , X_K_Line_ID
  , X_Deliverable_ID
  , X_Communication_Num
  , X_Type
  , X_Reason_Code
  , X_K_Party_ID
  , X_Party_Location
  , X_Party_Role
  , X_Party_Contact
  , X_Action_Code
  , X_Owner
  , X_Priority_Code
  , X_Communication_Date
  , X_Text
  , X_Last_Updated_By
  , X_Last_Update_Date
  , X_Last_Update_Login
  , X_WF_ITEM_KEY
  );

  open c;
  fetch c into X_Rowid , X_WF_Item_Type , X_WF_Process , X_WF_Item_Key;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end Insert_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN

  DELETE FROM OKE_K_COMMUNICATIONS
  WHERE rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;

EXCEPTION
WHEN OTHERS THEN
  raise;

END Delete_Row;


end OKE_COMMUNICATION_PKG;

/
