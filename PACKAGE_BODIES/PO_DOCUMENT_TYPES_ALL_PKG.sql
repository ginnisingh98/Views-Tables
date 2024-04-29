--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_TYPES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_TYPES_ALL_PKG" as
/* $Header: POXSTDTB.pls 120.7 2008/03/25 08:40:40 lgoyal ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2,
  X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
  X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
  X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
  X_FORWARDING_MODE_CODE in VARCHAR2,
  X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
  X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
  X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
  X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
  X_QUOTATION_CLASS_CODE in VARCHAR2,
  X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_LEVEL_CODE in VARCHAR2,
  X_ACCESS_LEVEL_CODE in VARCHAR2,
  X_DISABLED_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
  X_WF_APPROVAL_PROCESS in VARCHAR2,
  X_WF_CREATEDOC_PROCESS in VARCHAR2,
  p_ame_transaction_type IN VARCHAR2, -- Bug 3028744 New column
  X_TYPE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  P_DOCUMENT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
  P_CONTRACT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
  p_use_contract_for_sourcing IN VARCHAR2,-- <Contract AutoSourcing FPJ>
  p_include_noncatalog_flag IN VARCHAR2  ,     -- <Contract AutoSourcing FPJ>
  p_org_id IN NUMBER
  )
 is
  X_ORG_ID   NUMBER;
  cursor C is select ROWID from PO_DOCUMENT_TYPES_ALL_B
    where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
    and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
    ;
begin

  X_ORG_ID := p_org_id;

  insert into PO_DOCUMENT_TYPES_ALL_B (
    ORG_ID,
    WF_CREATEDOC_ITEMTYPE,
    DOCUMENT_TYPE_CODE,
    DOCUMENT_SUBTYPE,
    ARCHIVE_EXTERNAL_REVISION_CODE,
    CAN_PREPARER_APPROVE_FLAG,
    FORWARDING_MODE_CODE,
    CAN_CHANGE_FORWARD_FROM_FLAG,
    CAN_APPROVER_MODIFY_DOC_FLAG,
    CAN_CHANGE_APPROVAL_PATH_FLAG,
    CAN_CHANGE_FORWARD_TO_FLAG,
    QUOTATION_CLASS_CODE,
    DEFAULT_APPROVAL_PATH_ID,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    SECURITY_LEVEL_CODE,
    ACCESS_LEVEL_CODE,
    DISABLED_FLAG,
    REQUEST_ID,
    WF_APPROVAL_ITEMTYPE,
    WF_APPROVAL_PROCESS,
    WF_CREATEDOC_PROCESS,
    AME_TRANSACTION_TYPE, -- Bug 3028744 New column
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DOCUMENT_TEMPLATE_CODE,
    CONTRACT_TEMPLATE_CODE,
    USE_CONTRACT_FOR_SOURCING_FLAG, -- <Contract AutoSourcing FPJ>
    INCLUDE_NONCATALOG_FLAG   	    -- <Contract AutoSourcing FPJ>
  ) values (
    X_ORG_ID,
    X_WF_CREATEDOC_ITEMTYPE,
    X_DOCUMENT_TYPE_CODE,
    X_DOCUMENT_SUBTYPE,
    X_ARCHIVE_EXTERNAL_REVISION_CO,
    X_CAN_PREPARER_APPROVE_FLAG,
    X_FORWARDING_MODE_CODE,
    X_CAN_CHANGE_FORWARD_FROM_FLAG,
    X_CAN_APPROVER_MODIFY_DOC_FLAG,
    X_CAN_CHANGE_APPROVAL_PATH_FLA,
    X_CAN_CHANGE_FORWARD_TO_FLAG,
    X_QUOTATION_CLASS_CODE,
    X_DEFAULT_APPROVAL_PATH_ID,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_SECURITY_LEVEL_CODE,
    X_ACCESS_LEVEL_CODE,
    X_DISABLED_FLAG,
    X_REQUEST_ID,
    X_WF_APPROVAL_ITEMTYPE,
    X_WF_APPROVAL_PROCESS,
    X_WF_CREATEDOC_PROCESS,
    p_ame_transaction_type, -- Bug 3028744 New column
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    P_DOCUMENT_TEMPLATE_CODE , -- POC FPJ
    P_CONTRACT_TEMPLATE_CODE , -- POC FPJ
    p_use_contract_for_sourcing, -- <Contract AutoSourcing FPJ>
    p_include_noncatalog_flag);       -- <Contract AutoSourcing FPJ>

  insert into PO_DOCUMENT_TYPES_ALL_TL (
    ORG_ID,
    DOCUMENT_TYPE_CODE,
    DOCUMENT_SUBTYPE,
    TYPE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ORG_ID,
    X_DOCUMENT_TYPE_CODE,
    X_DOCUMENT_SUBTYPE,
    X_TYPE_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PO_DOCUMENT_TYPES_ALL_TL T
    where T.DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
    and T.DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
    and T.LANGUAGE = L.LANGUAGE_CODE
    and T.ORG_ID = X_ORG_ID) ; -- <R12 MOAC> added

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2,
  X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
  X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
  X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
  X_FORWARDING_MODE_CODE in VARCHAR2,
  X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
  X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
  X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
  X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
  X_QUOTATION_CLASS_CODE in VARCHAR2,
  X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_LEVEL_CODE in VARCHAR2,
  X_ACCESS_LEVEL_CODE in VARCHAR2,
  X_DISABLED_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
  X_WF_APPROVAL_PROCESS in VARCHAR2,
  X_WF_CREATEDOC_PROCESS in VARCHAR2,
  p_ame_transaction_type IN VARCHAR2, -- Bug 3028744 New column
  X_TYPE_NAME in VARCHAR2,
  P_DOCUMENT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
  P_CONTRACT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
  p_use_contract_for_sourcing IN VARCHAR2, -- <Contract AutoSourcing FPJ>
  p_include_noncatalog_flag IN VARCHAR2        -- <Contract AutoSourcing FPJ>
 )
 is
  X_ORG_ID   NUMBER;    -- <R12 MOAC>
  cursor c is select
      WF_CREATEDOC_ITEMTYPE,
      ARCHIVE_EXTERNAL_REVISION_CODE,
      CAN_PREPARER_APPROVE_FLAG,
      FORWARDING_MODE_CODE,
      CAN_CHANGE_FORWARD_FROM_FLAG,
      CAN_APPROVER_MODIFY_DOC_FLAG,
      CAN_CHANGE_APPROVAL_PATH_FLAG,
      CAN_CHANGE_FORWARD_TO_FLAG,
      QUOTATION_CLASS_CODE,
      DEFAULT_APPROVAL_PATH_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      SECURITY_LEVEL_CODE,
      ACCESS_LEVEL_CODE,
      DISABLED_FLAG,
      REQUEST_ID,
      WF_APPROVAL_ITEMTYPE,
      WF_APPROVAL_PROCESS,
      WF_CREATEDOC_PROCESS,
      AME_TRANSACTION_TYPE, -- Bug 3028744 New column
      DOCUMENT_TEMPLATE_CODE, -- Bug # 3274065
      CONTRACT_TEMPLATE_CODE,  -- Bug # 3274065
      USE_CONTRACT_FOR_SOURCING_FLAG, -- <Contract AutoSourcing FPJ>
      INCLUDE_NONCATALOG_FLAG         -- <Contract AutoSourcing FPJ>
    from PO_DOCUMENT_TYPES_ALL_B
    where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
    and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
    and org_id = X_ORG_ID          -- <R12 MOAC>
    for update of DOCUMENT_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TYPE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PO_DOCUMENT_TYPES_ALL_TL
    where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
    and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    and ORG_ID = X_ORG_ID          -- <R12 MOAC>
    for update of DOCUMENT_TYPE_CODE nowait;
begin
  X_ORG_ID := PO_MOAC_UTILS_PVT.get_current_org_id ;       -- <R12 MOAC>
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.WF_CREATEDOC_ITEMTYPE = X_WF_CREATEDOC_ITEMTYPE)
           OR ((recinfo.WF_CREATEDOC_ITEMTYPE is null) AND (X_WF_CREATEDOC_ITEMTYPE is null)))
      AND ((recinfo.ARCHIVE_EXTERNAL_REVISION_CODE = X_ARCHIVE_EXTERNAL_REVISION_CO)
           OR ((recinfo.ARCHIVE_EXTERNAL_REVISION_CODE is null) AND (X_ARCHIVE_EXTERNAL_REVISION_CO is null)))
      AND ((recinfo.CAN_PREPARER_APPROVE_FLAG = X_CAN_PREPARER_APPROVE_FLAG)
           OR ((recinfo.CAN_PREPARER_APPROVE_FLAG is null) AND (X_CAN_PREPARER_APPROVE_FLAG is null)))

      AND ((recinfo.FORWARDING_MODE_CODE = X_FORWARDING_MODE_CODE)
           OR ((recinfo.FORWARDING_MODE_CODE is null) AND (X_FORWARDING_MODE_CODE is null)))

      AND ((recinfo.CAN_CHANGE_FORWARD_FROM_FLAG = X_CAN_CHANGE_FORWARD_FROM_FLAG)
           OR ((recinfo.CAN_CHANGE_FORWARD_FROM_FLAG is null) AND (X_CAN_CHANGE_FORWARD_FROM_FLAG is null)))
      AND ((recinfo.CAN_APPROVER_MODIFY_DOC_FLAG = X_CAN_APPROVER_MODIFY_DOC_FLAG)
           OR ((recinfo.CAN_APPROVER_MODIFY_DOC_FLAG is null) AND (X_CAN_APPROVER_MODIFY_DOC_FLAG is null)))
      AND ((recinfo.CAN_CHANGE_APPROVAL_PATH_FLAG = X_CAN_CHANGE_APPROVAL_PATH_FLA)
           OR ((recinfo.CAN_CHANGE_APPROVAL_PATH_FLAG is null) AND (X_CAN_CHANGE_APPROVAL_PATH_FLA is null)))
      AND ((recinfo.CAN_CHANGE_FORWARD_TO_FLAG = X_CAN_CHANGE_FORWARD_TO_FLAG)
           OR ((recinfo.CAN_CHANGE_FORWARD_TO_FLAG is null) AND (X_CAN_CHANGE_FORWARD_TO_FLAG is null)))
      AND ((recinfo.QUOTATION_CLASS_CODE = X_QUOTATION_CLASS_CODE)
           OR ((recinfo.QUOTATION_CLASS_CODE is null) AND (X_QUOTATION_CLASS_CODE is null)))
      AND ((recinfo.DEFAULT_APPROVAL_PATH_ID = X_DEFAULT_APPROVAL_PATH_ID)
           OR ((recinfo.DEFAULT_APPROVAL_PATH_ID is null) AND (X_DEFAULT_APPROVAL_PATH_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.SECURITY_LEVEL_CODE = X_SECURITY_LEVEL_CODE)
           OR ((recinfo.SECURITY_LEVEL_CODE is null) AND (X_SECURITY_LEVEL_CODE is null)))
      AND ((recinfo.ACCESS_LEVEL_CODE = X_ACCESS_LEVEL_CODE)
           OR ((recinfo.ACCESS_LEVEL_CODE is null) AND (X_ACCESS_LEVEL_CODE is null)))
      AND (recinfo.DISABLED_FLAG = X_DISABLED_FLAG)
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.WF_APPROVAL_ITEMTYPE = X_WF_APPROVAL_ITEMTYPE)
           OR ((recinfo.WF_APPROVAL_ITEMTYPE is null) AND (X_WF_APPROVAL_ITEMTYPE is null)))
      AND ((recinfo.WF_APPROVAL_PROCESS = X_WF_APPROVAL_PROCESS)
           OR ((recinfo.WF_APPROVAL_PROCESS is null) AND (X_WF_APPROVAL_PROCESS is null)))
      AND ((recinfo.WF_CREATEDOC_PROCESS = X_WF_CREATEDOC_PROCESS)
           OR ((recinfo.WF_CREATEDOC_PROCESS is null) AND (X_WF_CREATEDOC_PROCESS is null)))
      -- Bug 3028744 START - New column
      AND ((recinfo.ame_transaction_type = p_ame_transaction_type)
           OR ((recinfo.ame_transaction_type IS NULL) AND (p_ame_transaction_type IS NULL)))
      -- Bug 3028744 END
      -- Bug 3274065 START - New columns
      AND ((recinfo.DOCUMENT_TEMPLATE_CODE = P_DOCUMENT_TEMPLATE_CODE)
           OR ((recinfo.DOCUMENT_TEMPLATE_CODE IS NULL) AND (P_DOCUMENT_TEMPLATE_CODE IS NULL)))
      AND ((recinfo.CONTRACT_TEMPLATE_CODE = P_CONTRACT_TEMPLATE_CODE)
           OR ((recinfo.CONTRACT_TEMPLATE_CODE IS NULL) AND (P_CONTRACT_TEMPLATE_CODE IS NULL)))
      -- Bug 3274065 End - New columns
      -- <Contract AutoSourcing FPJ Start>
      AND ((recinfo.USE_CONTRACT_FOR_SOURCING_FLAG = P_USE_CONTRACT_FOR_SOURCING)
           OR ((recinfo.USE_CONTRACT_FOR_SOURCING_FLAG IS NULL)
                AND (P_USE_CONTRACT_FOR_SOURCING IS NULL)))
      AND ((recinfo.INCLUDE_NONCATALOG_FLAG = P_INCLUDE_NONCATALOG_FLAG)
           OR ((recinfo.INCLUDE_NONCATALOG_FLAG IS NULL)
                AND (P_INCLUDE_NONCATALOG_FLAG IS NULL)))
      -- <Contract AutoSourcing FPJ End>
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TYPE_NAME = X_TYPE_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2,
  X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
  X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
  X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
  X_FORWARDING_MODE_CODE in VARCHAR2,
  X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
  X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
  X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
  X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
  X_QUOTATION_CLASS_CODE in VARCHAR2,
  X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_LEVEL_CODE in VARCHAR2,
  X_ACCESS_LEVEL_CODE in VARCHAR2,
  X_DISABLED_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
  X_WF_APPROVAL_PROCESS in VARCHAR2,
  X_WF_CREATEDOC_PROCESS in VARCHAR2,
  p_ame_transaction_type IN VARCHAR2, -- Bug 3028744 New column
  X_TYPE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  P_DOCUMENT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
  P_CONTRACT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
  p_use_contract_for_sourcing IN VARCHAR2,-- <Contract AutoSourcing FPJ>
  p_include_noncatalog_flag IN VARCHAR2,       -- <Contract AutoSourcing FPJ>
  p_org_id IN NUMBER
 )
is
  X_ORG_ID   NUMBER;    -- <R12 MOAC>
begin
  -- Bug 5081289: Passed org id instead of using session context
  X_ORG_ID := p_org_id;

  update PO_DOCUMENT_TYPES_ALL_B set
    WF_CREATEDOC_ITEMTYPE = X_WF_CREATEDOC_ITEMTYPE,
    ARCHIVE_EXTERNAL_REVISION_CODE = X_ARCHIVE_EXTERNAL_REVISION_CO,
    CAN_PREPARER_APPROVE_FLAG = X_CAN_PREPARER_APPROVE_FLAG,
    FORWARDING_MODE_CODE = X_FORWARDING_MODE_CODE,
    CAN_CHANGE_FORWARD_FROM_FLAG = X_CAN_CHANGE_FORWARD_FROM_FLAG,
    CAN_APPROVER_MODIFY_DOC_FLAG = X_CAN_APPROVER_MODIFY_DOC_FLAG,
    CAN_CHANGE_APPROVAL_PATH_FLAG = X_CAN_CHANGE_APPROVAL_PATH_FLA,
    CAN_CHANGE_FORWARD_TO_FLAG = X_CAN_CHANGE_FORWARD_TO_FLAG,
    QUOTATION_CLASS_CODE = X_QUOTATION_CLASS_CODE,
    DEFAULT_APPROVAL_PATH_ID = X_DEFAULT_APPROVAL_PATH_ID,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    SECURITY_LEVEL_CODE = X_SECURITY_LEVEL_CODE,
    ACCESS_LEVEL_CODE = X_ACCESS_LEVEL_CODE,
    DISABLED_FLAG = X_DISABLED_FLAG,
    REQUEST_ID = X_REQUEST_ID,
    WF_APPROVAL_ITEMTYPE = X_WF_APPROVAL_ITEMTYPE,
    WF_APPROVAL_PROCESS = X_WF_APPROVAL_PROCESS,
    WF_CREATEDOC_PROCESS = X_WF_CREATEDOC_PROCESS,
    ame_transaction_type = p_ame_transaction_type, -- Bug 3028744 New column
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    DOCUMENT_TEMPLATE_CODE = P_DOCUMENT_TEMPLATE_CODE, -- POC FPJ
    CONTRACT_TEMPLATE_CODE = P_CONTRACT_TEMPLATE_CODE,  -- POC FPJ
    -- <Contract AutoSourcing FPJ Start>
    USE_CONTRACT_FOR_SOURCING_FLAG = p_use_contract_for_sourcing,
    INCLUDE_NONCATALOG_FLAG = p_include_noncatalog_flag
    -- <Contract AutoSourcing FPJ End>
  where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
  and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
  and ORG_ID= X_ORG_ID ;           -- <R12 MOAC>

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PO_DOCUMENT_TYPES_ALL_TL set
    TYPE_NAME = X_TYPE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
  and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  and ORG_ID = X_ORG_ID ;          -- <R12 MOAC>

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2
 )
is
  X_ORG_ID   NUMBER;    -- <R12 MOAC>
begin
  X_ORG_ID := PO_MOAC_UTILS_PVT.get_current_org_id ;       -- <R12 MOAC>
  delete from PO_DOCUMENT_TYPES_ALL_TL
  where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
  and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
  and ORG_ID = X_ORG_ID ;            -- <R12 MOAC>

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PO_DOCUMENT_TYPES_ALL_B
  where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
  and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
  and ORG_ID = X_ORG_ID ;            -- <R12 MOAC>

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
  -- Bug# 4899490: Removing X_ORG_ID, as there is no MOAC context needed
begin
  -- Bug# 4899490: Removing X_ORG_ID, as there is no MOAC context needed
  delete from PO_DOCUMENT_TYPES_ALL_TL T
  where not exists
    (select NULL
    from PO_DOCUMENT_TYPES_ALL_B B
    where B.DOCUMENT_TYPE_CODE = T.DOCUMENT_TYPE_CODE
    and B.DOCUMENT_SUBTYPE = T.DOCUMENT_SUBTYPE
     and B.ORG_ID = T.ORG_ID -- Bug# 4899490: Retaining 11.5.10 behavior
    );

  update PO_DOCUMENT_TYPES_ALL_TL T set (
      TYPE_NAME
    ) = (select
      B.TYPE_NAME
    from PO_DOCUMENT_TYPES_ALL_TL B
    where B.DOCUMENT_TYPE_CODE = T.DOCUMENT_TYPE_CODE
    and B.DOCUMENT_SUBTYPE = T.DOCUMENT_SUBTYPE
    and B.LANGUAGE = T.SOURCE_LANG
    and B.ORG_ID = T.ORG_ID -- Bug# 4899490: Retaining 11.5.10 behavior
        )
  where (
      T.DOCUMENT_TYPE_CODE,
      T.DOCUMENT_SUBTYPE,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_TYPE_CODE,
      SUBT.DOCUMENT_SUBTYPE,
      SUBT.LANGUAGE
    from PO_DOCUMENT_TYPES_ALL_TL SUBB, PO_DOCUMENT_TYPES_ALL_TL SUBT
    where SUBB.DOCUMENT_TYPE_CODE = SUBT.DOCUMENT_TYPE_CODE
    and SUBB.DOCUMENT_SUBTYPE = SUBT.DOCUMENT_SUBTYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and SUBB.ORG_ID = SUBT.ORG_ID -- Bug# 4899490: Retaining 11.5.10 behavior
    and (SUBB.TYPE_NAME <> SUBT.TYPE_NAME
      or (SUBB.TYPE_NAME is null and SUBT.TYPE_NAME is not null)
      or (SUBB.TYPE_NAME is not null and SUBT.TYPE_NAME is null)
  ));

  insert into PO_DOCUMENT_TYPES_ALL_TL (
    ORG_ID,
    DOCUMENT_TYPE_CODE,
    DOCUMENT_SUBTYPE,
    TYPE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.DOCUMENT_TYPE_CODE,
    B.DOCUMENT_SUBTYPE,
    B.TYPE_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PO_DOCUMENT_TYPES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PO_DOCUMENT_TYPES_ALL_TL T
    where T.DOCUMENT_TYPE_CODE = B.DOCUMENT_TYPE_CODE
    and T.DOCUMENT_SUBTYPE = B.DOCUMENT_SUBTYPE
    and T.LANGUAGE = L.LANGUAGE_CODE
    and T.ORG_ID = B.ORG_ID -- Bug# 4899490: Retaining 11.5.10 behavior
    );
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (X_DOCUMENT_TYPE_CODE in VARCHAR2,
                         X_DOCUMENT_SUBTYPE in VARCHAR2,
                         X_TYPE_NAME in VARCHAR2,
                         X_ORG_ID  in NUMBER,
                         X_OWNER     in VARCHAR2,
                         X_LAST_UPDATE_DATE in VARCHAR2,
                         X_CUSTOM_MODE in VARCHAR2) IS

f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db

begin
  f_luby := fnd_load_util.owner_id(X_OWNER);
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);

  -- bug3703523
  -- for old see data we have last_updated_by as -1.
  -- upload_test procedure will consider the record as being customized,
  -- which is not the case here. Therefore we need to update
  -- last_updated_by to 1 when it is -1 so that the record can be updated.

  select DECODE(LAST_UPDATED_BY, -1, 1, LAST_UPDATED_BY), LAST_UPDATE_DATE
  into  db_luby, db_ludate
  from PO_DOCUMENT_TYPES_ALL_TL
  where document_type_code  = X_DOCUMENT_TYPE_CODE
  and  document_subtype   = X_DOCUMENT_SUBTYPE
  and  ( (X_ORG_ID is null and org_id = -3113 )
       or (X_ORG_ID is not null and org_id = X_ORG_ID))
  and  language = userenv('LANG') ;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then

   update PO_DOCUMENT_TYPES_ALL_TL set
       type_name = X_TYPE_NAME ,
       last_update_date  = f_ludate,
       last_updated_by   = f_luby,
       last_update_login = 0,
       source_lang       = userenv('LANG')
  where document_type_code  = X_DOCUMENT_TYPE_CODE
   and  document_subtype   = X_DOCUMENT_SUBTYPE
   and  userenv('LANG') in (language, source_lang);

  end if;

exception
 when no_data_found then
    -- Do not insert missing translations, skip this row
    null;
end TRANSLATE_ROW;

procedure LOAD_ROW (X_DOCUMENT_TYPE_CODE in VARCHAR2,
                    X_DOCUMENT_SUBTYPE in VARCHAR2,
                    X_ORG_ID in NUMBER,
                    X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
                    X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
                    X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
                    X_FORWARDING_MODE_CODE in VARCHAR2,
                    X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
                    X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
                    X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
                    X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
                    X_QUOTATION_CLASS_CODE in VARCHAR2,
                    X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
                    X_ATTRIBUTE_CATEGORY in VARCHAR2,
                    X_ATTRIBUTE1 in VARCHAR2,
                    X_ATTRIBUTE2 in VARCHAR2,
                    X_ATTRIBUTE3 in VARCHAR2,
                    X_ATTRIBUTE4 in VARCHAR2,
                    X_ATTRIBUTE5 in VARCHAR2,
                    X_ATTRIBUTE6 in VARCHAR2,
                    X_ATTRIBUTE7 in VARCHAR2,
                    X_ATTRIBUTE8 in VARCHAR2,
                    X_ATTRIBUTE9 in VARCHAR2,
                    X_ATTRIBUTE10 in VARCHAR2,
                    X_ATTRIBUTE11 in VARCHAR2,
                    X_ATTRIBUTE12 in VARCHAR2,
                    X_ATTRIBUTE13 in VARCHAR2,
                    X_ATTRIBUTE14 in VARCHAR2,
                    X_ATTRIBUTE15 in VARCHAR2,
                    X_SECURITY_LEVEL_CODE in VARCHAR2,
                    X_ACCESS_LEVEL_CODE in VARCHAR2,
                    X_DISABLED_FLAG in VARCHAR2,
                    X_REQUEST_ID in NUMBER,
                    X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
                    X_WF_APPROVAL_PROCESS in VARCHAR2,
                    X_WF_CREATEDOC_PROCESS in VARCHAR2,
                    p_ame_transaction_type IN VARCHAR2, -- Bug 3028744
                    X_TYPE_NAME in VARCHAR2,
                    X_OWNER             in VARCHAR2,
                    X_LAST_UPDATE_DATE in VARCHAR2,
                    X_CUSTOM_MODE in VARCHAR2,
		    P_DOCUMENT_TEMPLATE_CODE in VARCHAR2,  -- POC FPJ
 	            P_CONTRACT_TEMPLATE_CODE in VARCHAR2) IS


    l_row_id	varchar2(64);
    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db

	--Bug 6810625 Start
	/*	Changed table in query from PO_DOCUMENT_TYPES_ALL_B to PO_DOCUMENT_TYPES_ALL_VL
		because table PO_DOCUMENT_TYPES_ALL_B doesnot contain TYPE_NAME Column.
		This column is in table PO_DOCUMENT_TYPES_ALL_TL.
		but view PO_DOCUMENT_TYPES_ALL_VL contains this column as its queries from both
		the tables PO_DOCUMENT_TYPES_ALL_B and PO_DOCUMENT_TYPES_ALL_TL. */

	--rec      PO_DOCUMENT_TYPES_ALL_B%Rowtype;   -- Bug6086648  FP:Bug 5985709
	rec		PO_DOCUMENT_TYPES_ALL_VL%Rowtype;
	--End Bug 6810625

  begin

	-- Bug6910423 Moved these statements before Select statement.
     	f_luby := fnd_load_util.owner_id(X_OWNER);
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);
	--End Bug6910423

	-- Bug6086648  FP:Bug 5985709. Query added to get the existing data.
	-- Bug 6810625
	SELECT * into rec FROM  PO_DOCUMENT_TYPES_ALL_VL
      where DOCUMENT_TYPE_CODE = X_DOCUMENT_TYPE_CODE
      and DOCUMENT_SUBTYPE = X_DOCUMENT_SUBTYPE
      and NVL(X_ORG_ID, -99) = NVL(ORG_ID, -99) ;
	-- End Bug 6810625

     -- bug3703523
     -- for old see data we have last_updated_by as -1.
     -- upload_test procedure will consider the record as being customized,
     -- which is not the case here. Therefore we need to update
     -- last_updated_by to 1 when it is -1 so that the record can be updated.

     select DECODE(LAST_UPDATED_BY, -1, 1, LAST_UPDATED_BY), LAST_UPDATE_DATE
     into  db_luby, db_ludate
     from PO_DOCUMENT_TYPES_ALL_TL
     where document_type_code  = X_DOCUMENT_TYPE_CODE
     and  document_subtype   = X_DOCUMENT_SUBTYPE
     and  ( (X_ORG_ID is null and org_id = -3113 )
          or (X_ORG_ID is not null and org_id = X_ORG_ID))
     and  language = userenv('LANG');

   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
 /* Bug6086648  FP:Bug 5985709 Start.
 Modified the parameters in call to UPDATE_ROW to prioritise the
 existing values, using NVL, over the seed values. */

/*     UPDATE_ROW (X_DOCUMENT_TYPE_CODE ,
                 X_DOCUMENT_SUBTYPE ,
                 X_WF_CREATEDOC_ITEMTYPE ,
                 X_ARCHIVE_EXTERNAL_REVISION_CO ,
                 X_CAN_PREPARER_APPROVE_FLAG ,
                 X_FORWARDING_MODE_CODE ,
                 X_CAN_CHANGE_FORWARD_FROM_FLAG ,
                 X_CAN_APPROVER_MODIFY_DOC_FLAG ,
                 X_CAN_CHANGE_APPROVAL_PATH_FLA ,
                 X_CAN_CHANGE_FORWARD_TO_FLAG ,
                 X_QUOTATION_CLASS_CODE ,
                 X_DEFAULT_APPROVAL_PATH_ID ,
                 X_ATTRIBUTE_CATEGORY ,
                 X_ATTRIBUTE1 ,
                 X_ATTRIBUTE2 ,
                 X_ATTRIBUTE3 ,
                 X_ATTRIBUTE4 ,
                 X_ATTRIBUTE5 ,
                 X_ATTRIBUTE6 ,
                 X_ATTRIBUTE7 ,
                 X_ATTRIBUTE8 ,
                 X_ATTRIBUTE9 ,
                 X_ATTRIBUTE10 ,
                 X_ATTRIBUTE11 ,
                 X_ATTRIBUTE12 ,
                 X_ATTRIBUTE13 ,
                 X_ATTRIBUTE14 ,
                 X_ATTRIBUTE15 ,
                 X_SECURITY_LEVEL_CODE ,
                 X_ACCESS_LEVEL_CODE ,
                 X_DISABLED_FLAG ,
                 X_REQUEST_ID ,
                 X_WF_APPROVAL_ITEMTYPE ,
                 X_WF_APPROVAL_PROCESS ,
                 X_WF_CREATEDOC_PROCESS ,
                 p_ame_transaction_type, -- Bug 3028744 New column
                 X_TYPE_NAME ,
                 f_ludate ,
                 f_luby,
                 0,
                 P_DOCUMENT_TEMPLATE_CODE , --POC FPJ
                 P_CONTRACT_TEMPLATE_CODE , --POC FPJ
		 --<Contract AutoSourcing FPJ Start>
		 -- Pass NULL to use_contract_for_sourcing_flag and include_noncatalog_flag
                 -- so that they do not need to be defaulted from Seed data
      		 NULL,
      		 NULL ,
		 --<Contract AutoSourcing FPJ End>
                 X_ORG_ID
                );*/
	 UPDATE_ROW (X_DOCUMENT_TYPE_CODE ,
                 X_DOCUMENT_SUBTYPE ,
                 NVL( rec.WF_CREATEDOC_ITEMTYPE , X_WF_CREATEDOC_ITEMTYPE   ) ,
                 NVL( rec.ARCHIVE_EXTERNAL_REVISION_CODE ,X_ARCHIVE_EXTERNAL_REVISION_CO ) ,
                 NVL( rec.CAN_PREPARER_APPROVE_FLAG ,X_CAN_PREPARER_APPROVE_FLAG ) ,
                 NVL( rec.FORWARDING_MODE_CODE , X_FORWARDING_MODE_CODE ) ,
                 NVL( rec.CAN_CHANGE_FORWARD_FROM_FLAG ,X_CAN_CHANGE_FORWARD_FROM_FLAG ) ,
                 NVL( rec.CAN_APPROVER_MODIFY_DOC_FLAG ,X_CAN_APPROVER_MODIFY_DOC_FLAG ) ,
                 NVL( rec.CAN_CHANGE_APPROVAL_PATH_FLAG ,X_CAN_CHANGE_APPROVAL_PATH_FLA ) ,
                 NVL( rec.CAN_CHANGE_FORWARD_TO_FLAG ,X_CAN_CHANGE_FORWARD_TO_FLAG ) ,
                 NVL( rec.QUOTATION_CLASS_CODE , X_QUOTATION_CLASS_CODE ) ,
                 NVL( rec.DEFAULT_APPROVAL_PATH_ID , X_DEFAULT_APPROVAL_PATH_ID) ,
                 NVL( rec.ATTRIBUTE_CATEGORY , X_ATTRIBUTE_CATEGORY ) ,
                 NVL( rec.ATTRIBUTE1 , X_ATTRIBUTE1 ) ,
                 NVL( rec.ATTRIBUTE2 , X_ATTRIBUTE2 ) ,
                 NVL( rec.ATTRIBUTE3 , X_ATTRIBUTE3 ) ,
                 NVL( rec.ATTRIBUTE4 , X_ATTRIBUTE4 ) ,
                 NVL( rec.ATTRIBUTE5 , X_ATTRIBUTE5 ) ,
                 NVL( rec.ATTRIBUTE6 , X_ATTRIBUTE6 ) ,
                 NVL( rec.ATTRIBUTE7 , X_ATTRIBUTE7 ) ,
                 NVL( rec.ATTRIBUTE8 , X_ATTRIBUTE8 ) ,
                 NVL( rec.ATTRIBUTE9 , X_ATTRIBUTE9 ) ,
                 NVL( rec.ATTRIBUTE10 , X_ATTRIBUTE10 ) ,
                 NVL( rec.ATTRIBUTE11 , X_ATTRIBUTE11 ) ,
                 NVL( rec.ATTRIBUTE12 , X_ATTRIBUTE12 ) ,
                 NVL( rec.ATTRIBUTE13 , X_ATTRIBUTE13 ) ,
                 NVL( rec.ATTRIBUTE14 , X_ATTRIBUTE14 ) ,
                 NVL( rec.ATTRIBUTE15 , X_ATTRIBUTE15 ) ,
                 NVL( rec.SECURITY_LEVEL_CODE , X_SECURITY_LEVEL_CODE  ) ,
                 NVL( rec.ACCESS_LEVEL_CODE , X_ACCESS_LEVEL_CODE  ) ,
                 NVL( rec.DISABLED_FLAG , X_DISABLED_FLAG ) ,
                 NVL( rec.REQUEST_ID , X_REQUEST_ID ) ,
                 NVL( rec.WF_APPROVAL_ITEMTYPE , X_WF_APPROVAL_ITEMTYPE ) ,
                 NVL( rec.WF_APPROVAL_PROCESS , X_WF_APPROVAL_PROCESS ) ,
                 NVL( rec.WF_CREATEDOC_PROCESS , X_WF_CREATEDOC_PROCESS ) ,
                 NVL( rec.ame_transaction_type , p_ame_transaction_type ) , --Bug 3028744 New column
                 NVL( rec.TYPE_NAME , X_TYPE_NAME ) ,
                 f_ludate ,
		 f_luby,
                 0,
 		 NVL( rec.DOCUMENT_TEMPLATE_CODE , P_DOCUMENT_TEMPLATE_CODE ) ,--POC FPJ
                 NVL( rec.CONTRACT_TEMPLATE_CODE , P_CONTRACT_TEMPLATE_CODE ) ,--POC FPJ
                 --<Contract AutoSourcing FPJ Start>
                 -- Pass NULL to use_contract_for_sourcing_flag and include_noncatalog_flag
                 -- so that they do not need to be defaulted from Seed data
                 NULL,
                 NULL,
                 --<Contract AutoSourcing FPJ End>
		 X_ORG_ID
                );

        /* Bug6086648  FP:Bug 5985709 End. */

     end if;

  exception
     when NO_DATA_FOUND then
          INSERT_ROW (l_row_id ,
                      X_DOCUMENT_TYPE_CODE ,
                      X_DOCUMENT_SUBTYPE ,
                      X_WF_CREATEDOC_ITEMTYPE ,
                      X_ARCHIVE_EXTERNAL_REVISION_CO ,
                      X_CAN_PREPARER_APPROVE_FLAG ,
                      X_FORWARDING_MODE_CODE ,
                      X_CAN_CHANGE_FORWARD_FROM_FLAG ,
                      X_CAN_APPROVER_MODIFY_DOC_FLAG ,
                      X_CAN_CHANGE_APPROVAL_PATH_FLA ,
                      X_CAN_CHANGE_FORWARD_TO_FLAG ,
                      X_QUOTATION_CLASS_CODE ,
                      X_DEFAULT_APPROVAL_PATH_ID ,
                      X_ATTRIBUTE_CATEGORY ,
                      X_ATTRIBUTE1 ,
                      X_ATTRIBUTE2 ,
                      X_ATTRIBUTE3 ,
                      X_ATTRIBUTE4 ,
                      X_ATTRIBUTE5 ,
                      X_ATTRIBUTE6 ,
                      X_ATTRIBUTE7 ,
                      X_ATTRIBUTE8 ,
                      X_ATTRIBUTE9 ,
                      X_ATTRIBUTE10 ,
                      X_ATTRIBUTE11 ,
                      X_ATTRIBUTE12 ,
                      X_ATTRIBUTE13 ,
                      X_ATTRIBUTE14 ,
                      X_ATTRIBUTE15 ,
                      X_SECURITY_LEVEL_CODE ,
                      X_ACCESS_LEVEL_CODE ,
                      X_DISABLED_FLAG ,
                      X_REQUEST_ID ,
                      X_WF_APPROVAL_ITEMTYPE ,
                      X_WF_APPROVAL_PROCESS ,
                      X_WF_CREATEDOC_PROCESS ,
                      p_ame_transaction_type, -- Bug 3028744 New column
                      X_TYPE_NAME ,
                      f_ludate ,
                      f_luby ,
                      f_ludate ,
                      f_luby ,
                      0,
       	              P_DOCUMENT_TEMPLATE_CODE , --POC FPJ
                      P_CONTRACT_TEMPLATE_CODE , --POC FPJ
	 	      --<Contract AutoSourcing FPJ Start>
		      -- Pass NULL to use_contract_for_sourcing_flag and include_noncatalog_flag
                      -- so that they do not need to be defaulted from Seed data
      		      NULL,
      		      NULL,
		      --<Contract AutoSourcing FPJ End>
                      X_ORG_ID
                     );

end LOAD_ROW;

-------------------------------------------------------------------------------
--Start of Comments
--Name: insert_lookup_row
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOOKUP_VALUES
--Locks:
--  None.
--Function:
--  This procedure acts as a pl/sql wrapper over the existing fnd api
--  FND_LOOKUP_VALUES_PKG.INSERT_ROW. It is used to insert the user
--  defined document subtype into fnd_lookup_values.It defaults the
--  values and limits the input parameters to a minimum.
--Parameters:
--IN:
--p_lookup_type
--  The lookup type for the row to be inserted in fnd_lookup_values.
--  This value is derived from the document type as explained in comments below.
--p_lookup_code
--  The lookup code for the row to be inserted in fnd_lookup_values.
--  This is equal to the document subtype entered by the user. The same
--  value is stored as the meaning and description for the row in fnd lookups.
--p_creation_date
--  Standard who column.
--p_created_by
--  Standard who column.
--p_last_update_date
--  Standard who column.
--p_last_updated_by
--  Standard who column.
--p_last_update_login
--  Standard who column.
--Notes:
--  This wrapper has been added as a part of the R12 HTML Setup enhancement
--  for inserting the user defined document subtypes into fnd lookups. This
--  api is essentially called via a jdbc call from the Document Types Helper.
--  The lookup type is determined based on the document type. It equals 'RFQ
--  SUBTYPE' for RFQ Document Types and 'QUOTATION SUBTYPE' for QUOTATION
--  Document Types.
--Testing:
--  On creating a new Document Type from the setup page, check that a record
--  has been inserted in fnd_lookup_values table (or the po_lookup_codes
--  view based on it). The lookup type would depend on the Document Type as
--  explained above. The lookup code, description and meaning (or displayed
--  field) should be equal to the user entered document subtype value.
--End of Comments
-------------------------------------------------------------------------------
procedure INSERT_LOOKUP_ROW (P_LOOKUP_TYPE in VARCHAR2,
                             P_LOOKUP_CODE in VARCHAR2,
                             P_CREATION_DATE in DATE,
                             P_CREATED_BY in NUMBER,
                             P_LAST_UPDATE_DATE in DATE,
                             P_LAST_UPDATED_BY in NUMBER,
                             P_LAST_UPDATE_LOGIN in NUMBER) IS
          l_rowid varchar2(64);
begin
FND_LOOKUP_VALUES_PKG.INSERT_ROW(l_rowid,
                                 P_LOOKUP_TYPE,
                                 0, --security group id
                                 201, --view application id
                                 P_LOOKUP_CODE,
                                 null, --tag
                                 null, --attribute_category
                                 null, --attribute1
                                 null, --attribute2
                                 null, --attribute3
                                 null, --attribute4
                                 'Y',  --enabled_flag
                                 null, --start_date_active
                                 null, --end_date_active
                                 null, --territory_code
                                 null, --attribute5
                                 null, --attribute6
                                 null, --attribute7
                                 null, --attribute8
                                 null, --attribute9
                                 null, --attribute10
                                 null, --attribute11
                                 null, --attribute12
                                 null, --attribute13
                                 null, --attribute14
                                 null, --attribute15
                                 P_LOOKUP_CODE, --meaning
                                 P_LOOKUP_CODE, --description
                                 P_CREATION_DATE,
                                 P_CREATED_BY,
                                 P_LAST_UPDATE_DATE,
                                 P_LAST_UPDATED_BY,
                                 P_LAST_UPDATE_LOGIN);
end INSERT_LOOKUP_ROW;

-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_lookup_row
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOOKUP_VALUES
--Locks:
--  None.
--Function:
--  This procedure acts as a pl/sql wrapper over the existing fnd api
--  FND_LOOKUP_VALUES_PKG.DELETE_ROW. It is used to delete the user
--  defined document subtype from fnd_lookup_values.It defaults the
--  values and limits the input parameters to a minimum.
--Parameters:
--IN:
--p_lookup_type
--  The lookup type for the row to be deleted from fnd_lookup_values.
--  This value is derived from the document type as explained in comments below.
--p_lookup_code
--  The lookup code for the row to be deleted from fnd_lookup_values.
--  This is equal to the document subtype entered by the user.
--Notes:
--  This wrapper has been added as a part of the R12 HTML Setup enhancement
--  for deleting the user defined document subtypes from fnd lookups. This
--  api is essentially called via a jdbc call from the Document Types Helper.
--  The lookup type is determined based on the document type. It equals 'RFQ
--  SUBTYPE' for RFQ Document Types and 'QUOTATION SUBTYPE' for QUOTATION
--  Document Types.
--Testing:
--  On deleting the Document Type from the setup page, check that the
--  corresponding record has been deleted from fnd_lookup_values
--  (or po_lookup_codes).
--End of Comments
-------------------------------------------------------------------------------
procedure DELETE_LOOKUP_ROW (P_LOOKUP_TYPE in VARCHAR2,
                             P_LOOKUP_CODE in VARCHAR2) IS
begin
FND_LOOKUP_VALUES_PKG.DELETE_ROW(P_LOOKUP_TYPE,
                                 0, --security group id
                                 201, --view application id
                                 P_LOOKUP_CODE);
end DELETE_LOOKUP_ROW;

end PO_DOCUMENT_TYPES_ALL_PKG;

/
