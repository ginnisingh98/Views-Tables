--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_TYPES_PKG" as
/* $Header: csdtdrtb.pls 120.6.12010000.2 2008/12/20 02:27:09 takwong ship $ */

l_debug        NUMBER := csd_gen_utility_pvt.g_debug_level;

procedure INSERT_ROW (
  X_ROWID              in OUT NOCOPY VARCHAR2,
  X_REPAIR_TYPE_ID     in NUMBER,
  X_WORKFLOW_ITEM_TYPE in VARCHAR2,
  X_START_DATE_ACTIVE  in DATE,
  X_END_DATE_ACTIVE    in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1  in VARCHAR2,
  X_ATTRIBUTE2  in VARCHAR2,
  X_ATTRIBUTE3  in VARCHAR2,
  X_ATTRIBUTE4  in VARCHAR2,
  X_ATTRIBUTE5  in VARCHAR2,
  X_ATTRIBUTE6  in VARCHAR2,
  X_ATTRIBUTE7  in VARCHAR2,
  X_ATTRIBUTE8  in VARCHAR2,
  X_ATTRIBUTE9  in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE     in DATE,
  X_CREATED_BY        in NUMBER,
  X_LAST_UPDATE_DATE  in DATE,
  X_LAST_UPDATED_BY   in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REPAIR_MODE              in Varchar2,
  X_INTERFACE_TO_OM_FLAG     in Varchar2,
  X_BOOK_SALES_ORDER_FLAG    in Varchar2,
  X_RELEASE_SALES_ORDER_FLAG in Varchar2,
  X_SHIP_SALES_ORDER_FLAG    in Varchar2,
  X_AUTO_PROCESS_RMA         in Varchar2,
  X_SEEDED_FLAG              in Varchar2,
  X_REPAIR_TYPE_REF          in Varchar2,
  X_BUSINESS_PROCESS_ID      in NUMBER,
  X_PRICE_LIST_HEADER_ID     in NUMBER,
  X_CPR_TXN_BILLING_TYPE_ID  in NUMBER,
  X_CPS_TXN_BILLING_TYPE_ID  in NUMBER,
  X_LR_TXN_BILLING_TYPE_ID   in NUMBER,
  X_LS_TXN_BILLING_TYPE_ID   in NUMBER,
  X_THIRD_SHIP_TXN_B_TYPE_ID  in NUMBER := null,
  X_THIRD_RMA_TXN_B_TYPE_ID  in NUMBER := null,
  X_MTL_TXN_BILLING_TYPE_ID  in NUMBER,
  X_LBR_TXN_BILLING_TYPE_ID  in NUMBER,
  X_EXP_TXN_BILLING_TYPE_ID  in NUMBER,
  X_INTERNAL_ORDER_FLAG      in Varchar2,
  X_THIRD_PARTY_FLAG      in Varchar2  := null,
  X_OBJECT_VERSION_NUMBER    in Number,
  X_START_FLOW_STATUS_ID     in Number
) is
  cursor C is select ROWID from CSD_REPAIR_TYPES_B
    where REPAIR_TYPE_ID = X_REPAIR_TYPE_ID;
begin
  insert into CSD_REPAIR_TYPES_B (
    REPAIR_TYPE_ID,
    WORKFLOW_ITEM_TYPE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REPAIR_MODE,
    INTERFACE_TO_OM_FLAG,
    BOOK_SALES_ORDER_FLAG,
    RELEASE_SALES_ORDER_FLAG,
    SHIP_SALES_ORDER_FLAG,
    AUTO_PROCESS_RMA,
    SEEDED_FLAG,
    REPAIR_TYPE_REF,
    BUSINESS_PROCESS_ID,
    PRICE_LIST_HEADER_ID,
    CPR_TXN_BILLING_TYPE_ID,
    CPS_TXN_BILLING_TYPE_ID,
    LR_TXN_BILLING_TYPE_ID,
    LS_TXN_BILLING_TYPE_ID,
    THIRD_SHIP_TXN_BILLING_TYPE_ID,
    THIRD_RMA_TXN_BILLING_TYPE_ID,
    MTL_TXN_BILLING_TYPE_ID,
    LBR_TXN_BILLING_TYPE_ID,
    EXP_TXN_BILLING_TYPE_ID,
    INTERNAL_ORDER_FLAG,
    THIRD_PARTY_FLAG,
    OBJECT_VERSION_NUMBER,
    START_FLOW_STATUS_ID
  ) values (
    X_REPAIR_TYPE_ID,
    X_WORKFLOW_ITEM_TYPE,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REPAIR_MODE,
    X_INTERFACE_TO_OM_FLAG,
    X_BOOK_SALES_ORDER_FLAG,
    X_RELEASE_SALES_ORDER_FLAG,
    X_SHIP_SALES_ORDER_FLAG,
    X_AUTO_PROCESS_RMA,
    X_SEEDED_FLAG,
    X_REPAIR_TYPE_REF,
    X_BUSINESS_PROCESS_ID,
    X_PRICE_LIST_HEADER_ID,
    X_CPR_TXN_BILLING_TYPE_ID,
    X_CPS_TXN_BILLING_TYPE_ID,
    X_LR_TXN_BILLING_TYPE_ID,
    X_LS_TXN_BILLING_TYPE_ID,
    X_THIRD_SHIP_TXN_B_TYPE_ID,
    X_THIRD_RMA_TXN_B_TYPE_ID,
    X_MTL_TXN_BILLING_TYPE_ID,
    X_LBR_TXN_BILLING_TYPE_ID,
    X_EXP_TXN_BILLING_TYPE_ID,
    X_INTERNAL_ORDER_FLAG,
    X_THIRD_PARTY_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_START_FLOW_STATUS_ID
  );

  insert into CSD_REPAIR_TYPES_TL (
    REPAIR_TYPE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REPAIR_TYPE_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSD_REPAIR_TYPES_TL T
    where T.REPAIR_TYPE_ID = X_REPAIR_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_REPAIR_TYPE_ID         in NUMBER,
  X_OBJECT_VERSION_NUMBER  in Number
) is

  cursor c is
    select object_version_number
    from CSD_REPAIR_TYPES_B
    where REPAIR_TYPE_ID = X_REPAIR_TYPE_ID
    for update nowait;

  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  IF l_debug > 0 THEN
    csd_gen_utility_pvt.add('CSD_REPAIR_TYPES_PKG recinfo.object_version_number : '||recinfo.object_version_number);
    csd_gen_utility_pvt.add('CSD_REPAIR_TYPES_PKG x_object_version_number : '||x_object_version_number);
  END IF;

  if(recinfo.object_version_number = x_object_version_number) then
    null;
  else
    close c;
    fnd_message.set_name('FND','FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  close c;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_REPAIR_TYPE_ID     in NUMBER,
  X_WORKFLOW_ITEM_TYPE in VARCHAR2,
  X_START_DATE_ACTIVE  in DATE,
  X_END_DATE_ACTIVE    in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1  in VARCHAR2,
  X_ATTRIBUTE2  in VARCHAR2,
  X_ATTRIBUTE3  in VARCHAR2,
  X_ATTRIBUTE4  in VARCHAR2,
  X_ATTRIBUTE5  in VARCHAR2,
  X_ATTRIBUTE6  in VARCHAR2,
  X_ATTRIBUTE7  in VARCHAR2,
  X_ATTRIBUTE8  in VARCHAR2,
  X_ATTRIBUTE9  in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NAME              in VARCHAR2,
  X_LAST_UPDATE_DATE  in DATE,
  X_LAST_UPDATED_BY   in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REPAIR_MODE              in Varchar2,
  X_INTERFACE_TO_OM_FLAG     in Varchar2,
  X_BOOK_SALES_ORDER_FLAG    in Varchar2,
  X_RELEASE_SALES_ORDER_FLAG in Varchar2,
  X_SHIP_SALES_ORDER_FLAG    in Varchar2,
  X_AUTO_PROCESS_RMA         in Varchar2,
  X_SEEDED_FLAG              in Varchar2,
  X_REPAIR_TYPE_REF          in Varchar2,
  X_BUSINESS_PROCESS_ID      in Number,
  X_PRICE_LIST_HEADER_ID     in Number,
  X_CPR_TXN_BILLING_TYPE_ID  in Number,
  X_CPS_TXN_BILLING_TYPE_ID  in Number,
  X_LR_TXN_BILLING_TYPE_ID   in Number,
  X_LS_TXN_BILLING_TYPE_ID   in Number,
  X_THIRD_SHIP_TXN_B_TYPE_ID   in Number,
  X_THIRD_RMA_TXN_B_TYPE_ID   in Number,
  X_MTL_TXN_BILLING_TYPE_ID  in Number,
  X_LBR_TXN_BILLING_TYPE_ID  in Number,
  X_EXP_TXN_BILLING_TYPE_ID  in Number,
  X_INTERNAL_ORDER_FLAG      in Varchar2,
  X_THIRD_PARTY_FLAG      in Varchar2,
  X_OBJECT_VERSION_NUMBER    in Number,
  X_START_FLOW_STATUS_ID     in Number
) is
begin
  update CSD_REPAIR_TYPES_B set
    WORKFLOW_ITEM_TYPE  = X_WORKFLOW_ITEM_TYPE,
    START_DATE_ACTIVE   = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE     = X_END_DATE_ACTIVE,
    ATTRIBUTE_CATEGORY  = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1  = X_ATTRIBUTE1,
    ATTRIBUTE2  = X_ATTRIBUTE2,
    ATTRIBUTE3  = X_ATTRIBUTE3,
    ATTRIBUTE4  = X_ATTRIBUTE4,
    ATTRIBUTE5  = X_ATTRIBUTE5,
    ATTRIBUTE6  = X_ATTRIBUTE6,
    ATTRIBUTE7  = X_ATTRIBUTE7,
    ATTRIBUTE8  = X_ATTRIBUTE8,
    ATTRIBUTE9  = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN,
    REPAIR_MODE           = X_REPAIR_MODE,
    INTERFACE_TO_OM_FLAG  = X_INTERFACE_TO_OM_FLAG,
    BOOK_SALES_ORDER_FLAG = X_BOOK_SALES_ORDER_FLAG,
    RELEASE_SALES_ORDER_FLAG = X_RELEASE_SALES_ORDER_FLAG,
    SHIP_SALES_ORDER_FLAG    = X_SHIP_SALES_ORDER_FLAG,
    AUTO_PROCESS_RMA         = X_AUTO_PROCESS_RMA,
    SEEDED_FLAG              = X_SEEDED_FLAG,
    REPAIR_TYPE_REF          = X_REPAIR_TYPE_REF,
    BUSINESS_PROCESS_ID      = X_BUSINESS_PROCESS_ID,
    PRICE_LIST_HEADER_ID     = X_PRICE_LIST_HEADER_ID,
    CPR_TXN_BILLING_TYPE_ID  = X_CPR_TXN_BILLING_TYPE_ID,
    CPS_TXN_BILLING_TYPE_ID  = X_CPS_TXN_BILLING_TYPE_ID,
    LR_TXN_BILLING_TYPE_ID   = X_LR_TXN_BILLING_TYPE_ID,
    LS_TXN_BILLING_TYPE_ID   = X_LS_TXN_BILLING_TYPE_ID,
    THIRD_SHIP_TXN_BILLING_TYPE_ID   = decode( X_THIRD_SHIP_TXN_B_TYPE_ID, FND_API.G_MISS_NUM, THIRD_SHIP_TXN_BILLING_TYPE_ID, X_THIRD_SHIP_TXN_B_TYPE_ID),
    THIRD_RMA_TXN_BILLING_TYPE_ID   =  decode( X_THIRD_RMA_TXN_B_TYPE_ID, FND_API.G_MISS_NUM, THIRD_RMA_TXN_BILLING_TYPE_ID, X_THIRD_RMA_TXN_B_TYPE_ID),
    MTL_TXN_BILLING_TYPE_ID  = X_MTL_TXN_BILLING_TYPE_ID,
    LBR_TXN_BILLING_TYPE_ID  = X_LBR_TXN_BILLING_TYPE_ID,
    EXP_TXN_BILLING_TYPE_ID  = X_EXP_TXN_BILLING_TYPE_ID,
    INTERNAL_ORDER_FLAG      = X_INTERNAL_ORDER_FLAG,
    THIRD_PARTY_FLAG      = decode( X_THIRD_PARTY_FLAG, FND_API.G_MISS_CHAR, THIRD_PARTY_FLAG, X_THIRD_PARTY_FLAG),
    OBJECT_VERSION_NUMBER    = X_OBJECT_VERSION_NUMBER,
    START_FLOW_STATUS_ID     = X_START_FLOW_STATUS_ID
  where REPAIR_TYPE_ID       = X_REPAIR_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSD_REPAIR_TYPES_TL set
    DESCRIPTION = X_DESCRIPTION,
    NAME = X_NAME,
    LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY    = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG        = userenv('LANG')
  where REPAIR_TYPE_ID = X_REPAIR_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REPAIR_TYPE_ID in NUMBER
) is
begin
  delete from CSD_REPAIR_TYPES_TL
  where REPAIR_TYPE_ID = X_REPAIR_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSD_REPAIR_TYPES_B
  where REPAIR_TYPE_ID = X_REPAIR_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSD_REPAIR_TYPES_TL T
  where not exists
    (select NULL
    from CSD_REPAIR_TYPES_B B
    where B.REPAIR_TYPE_ID = T.REPAIR_TYPE_ID
    );

  update CSD_REPAIR_TYPES_TL T set (
      DESCRIPTION,
      NAME
    ) = (select
      B.DESCRIPTION,
      B.NAME
    from CSD_REPAIR_TYPES_TL B
    where B.REPAIR_TYPE_ID = T.REPAIR_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REPAIR_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REPAIR_TYPE_ID,
      SUBT.LANGUAGE
    from CSD_REPAIR_TYPES_TL SUBB, CSD_REPAIR_TYPES_TL SUBT
    where SUBB.REPAIR_TYPE_ID = SUBT.REPAIR_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.NAME <> SUBT.NAME
  ));

  insert into CSD_REPAIR_TYPES_TL (
    REPAIR_TYPE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.REPAIR_TYPE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSD_REPAIR_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSD_REPAIR_TYPES_TL T
    where T.REPAIR_TYPE_ID = B.REPAIR_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Translate_Row
  (p_repair_type_id       IN  NUMBER
  ,p_name                 IN  VARCHAR2
  ,p_description          IN  VARCHAR2
  ,p_owner                IN  VARCHAR2
  )
IS
--
  l_user_id       NUMBER := 0;
--
BEGIN
--
  if p_owner = 'SEED' then
    l_user_id := 1;
  end if;
--
  UPDATE csd_repair_types_tl
  SET    description = p_description,
        name = p_name,
         last_update_date = SYSDATE,
         last_updated_by = l_user_id,
         last_update_login = 0,
         source_lang = userenv('LANG')
  WHERE  repair_type_id = p_repair_type_id
  AND    userenv('LANG') in (language, source_lang);
--
END Translate_Row;

PROCEDURE Load_Row
  (p_repair_type_id           IN  NUMBER
  ,p_name                     IN  VARCHAR2
  ,p_description              IN  VARCHAR2
  ,p_workflow_item_type       IN  VARCHAR2
  ,p_start_date_active        IN  DATE
  ,p_end_date_active          IN  DATE
  ,p_owner                    IN  VARCHAR2
  ,p_repair_mode              IN  VARCHAR2
  ,p_interface_to_om_flag     IN  VARCHAR2
  ,p_book_sales_order_flag    IN VARCHAR2
  ,p_release_sales_order_flag IN VARCHAR2
  ,p_ship_sales_order_flag    IN VARCHAR2
  ,p_auto_process_rma         IN VARCHAR2
  ,p_seeded_flag              IN VARCHAR2
  ,p_repair_type_ref          IN VARCHAR2
  ,p_business_process_id      IN NUMBER
  ,p_price_list_header_id     IN NUMBER
  ,p_cpr_txn_billing_type_id  IN NUMBER
  ,p_cps_txn_billing_type_id  IN NUMBER
  ,p_lr_txn_billing_type_id   IN NUMBER
  ,p_ls_txn_billing_type_id   IN NUMBER
  --,p_third_ship_txn_b_type_id   IN NUMBER := null
  --,p_third_rma_txn_b_type_id   IN NUMBER := null
  ,p_mtl_txn_billing_type_id  IN NUMBER
  ,p_lbr_txn_billing_type_id  IN NUMBER
  ,p_exp_txn_billing_type_id  IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_internal_order_flag      IN VARCHAR2 := null
--  ,p_third_party_flag     IN VARCHAR2 := null
  )
IS
--
  l_rowid                  ROWID;
  l_user_id                NUMBER := 0;
  l_count                  number := 0;

    CURSOR Cur_repair_type_count(p_repair_type_id IN NUMBER) IS
    select count(*) from CSD_REPAIR_TYPES_B
    where repair_type_id = p_repair_type_id and last_updated_by <> 1;

--
BEGIN
--
  if p_owner = 'SEED' then
    l_user_id := 1;
  end if;
--

    OPEN Cur_repair_type_count(p_repair_type_id);
    FETCH Cur_repair_type_count INTO l_count;
    CLOSE Cur_repair_type_count;

    if (l_count >= 1) then
        return;
    end if;

      Update_Row(
      X_REPAIR_TYPE_ID     => p_repair_type_id,
      X_WORKFLOW_ITEM_TYPE => p_workflow_item_type,
      X_START_DATE_ACTIVE  => p_start_date_active,
      X_END_DATE_ACTIVE    => p_end_date_active,
      X_ATTRIBUTE_CATEGORY => null,
      X_ATTRIBUTE1  => null,
      X_ATTRIBUTE2  => null,
      X_ATTRIBUTE3  => null,
      X_ATTRIBUTE4  => null,
      X_ATTRIBUTE5  => null,
      X_ATTRIBUTE6  => null,
      X_ATTRIBUTE7  => null,
      X_ATTRIBUTE8  => null,
      X_ATTRIBUTE9  => null,
      X_ATTRIBUTE10 => null,
      X_ATTRIBUTE11 => null,
      X_ATTRIBUTE12 => null,
      X_ATTRIBUTE13 => null,
      X_ATTRIBUTE14 => null,
      X_ATTRIBUTE15 => null,
      X_DESCRIPTION => p_description,
      X_NAME => p_name,
      X_LAST_UPDATE_DATE  => sysdate,
      X_LAST_UPDATED_BY   => l_user_id,
      X_LAST_UPDATE_LOGIN => 0,
      X_REPAIR_MODE              => p_repair_mode,
      X_INTERFACE_TO_OM_FLAG     => p_interface_to_om_flag,
      X_BOOK_SALES_ORDER_FLAG    => p_book_sales_order_flag,
      X_RELEASE_SALES_ORDER_FLAG => p_release_sales_order_flag,
      X_SHIP_SALES_ORDER_FLAG    => p_ship_sales_order_flag,
      X_AUTO_PROCESS_RMA         => p_auto_process_rma,
      X_SEEDED_FLAG              => p_seeded_flag,
      X_REPAIR_TYPE_REF          => p_repair_type_ref,
      X_BUSINESS_PROCESS_ID      => p_business_process_id,
      X_PRICE_LIST_HEADER_ID     => p_price_list_header_id,
      X_CPR_TXN_BILLING_TYPE_ID  => p_cpr_txn_billing_type_id,
      X_CPS_TXN_BILLING_TYPE_ID  => p_cps_txn_billing_type_id,
      X_LR_TXN_BILLING_TYPE_ID   => p_lr_txn_billing_type_id,
      X_LS_TXN_BILLING_TYPE_ID   => p_ls_txn_billing_type_id,
    --  X_THIRD_SHIP_TXN_B_TYPE_ID   => p_third_ship_txn_b_type_id,
    --  X_THIRD_RMA_TXN_B_TYPE_ID   => p_third_rma_txn_b_type_id,
      X_MTL_TXN_BILLING_TYPE_ID  => p_mtl_txn_billing_type_id,
      X_LBR_TXN_BILLING_TYPE_ID  => p_lbr_txn_billing_type_id,
      X_EXP_TXN_BILLING_TYPE_ID  => p_exp_txn_billing_type_id,
      X_INTERNAL_ORDER_FLAG      => p_internal_order_flag,
    --  X_THIRD_PARTY_FLAG      => p_third_party_flag,
      X_OBJECT_VERSION_NUMBER    => p_object_version_number,
      X_START_FLOW_STATUS_ID     => null
      );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Insert_Row(
        X_ROWID => l_rowid,
        X_REPAIR_TYPE_ID => p_repair_type_id,
        X_WORKFLOW_ITEM_TYPE => p_workflow_item_type,
        X_START_DATE_ACTIVE => p_start_date_active,
        X_END_DATE_ACTIVE => p_end_date_active,
        X_ATTRIBUTE_CATEGORY => null,
        X_ATTRIBUTE1 => null,
        X_ATTRIBUTE2 => null,
        X_ATTRIBUTE3 => null,
        X_ATTRIBUTE4 => null,
        X_ATTRIBUTE5 => null,
        X_ATTRIBUTE6 => null,
        X_ATTRIBUTE7 => null,
        X_ATTRIBUTE8 => null,
        X_ATTRIBUTE9 => null,
        X_ATTRIBUTE10 => null,
        X_ATTRIBUTE11 => null,
        X_ATTRIBUTE12 => null,
        X_ATTRIBUTE13 => null,
        X_ATTRIBUTE14 => null,
        X_ATTRIBUTE15 => null,
        X_DESCRIPTION => p_description,
        X_NAME => p_name,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY    => l_user_id,
        X_LAST_UPDATE_DATE  => sysdate,
        X_LAST_UPDATED_BY   => l_user_id,
        X_LAST_UPDATE_LOGIN => 0,
        X_REPAIR_MODE              => p_repair_mode,
        X_INTERFACE_TO_OM_FLAG     => p_interface_to_om_flag,
        X_BOOK_SALES_ORDER_FLAG    => p_book_sales_order_flag,
        X_RELEASE_SALES_ORDER_FLAG => p_release_sales_order_flag,
        X_SHIP_SALES_ORDER_FLAG    => p_ship_sales_order_flag,
        X_AUTO_PROCESS_RMA         => p_auto_process_rma,
        X_SEEDED_FLAG              => p_seeded_flag,
        X_REPAIR_TYPE_REF          => p_repair_type_ref,
        X_BUSINESS_PROCESS_ID      => p_business_process_id,
        X_PRICE_LIST_HEADER_ID     => p_price_list_header_id,
        X_CPR_TXN_BILLING_TYPE_ID  => p_cpr_txn_billing_type_id,
        X_CPS_TXN_BILLING_TYPE_ID  => p_cps_txn_billing_type_id,
        X_LR_TXN_BILLING_TYPE_ID   => p_lr_txn_billing_type_id,
        X_LS_TXN_BILLING_TYPE_ID   => p_ls_txn_billing_type_id,
    --    X_THIRD_SHIP_TXN_B_TYPE_ID   => p_third_ship_txn_b_type_id,
    --    X_THIRD_RMA_TXN_B_TYPE_ID   => p_third_rma_txn_b_type_id,
        X_MTL_TXN_BILLING_TYPE_ID  => p_mtl_txn_billing_type_id,
        X_LBR_TXN_BILLING_TYPE_ID  => p_lbr_txn_billing_type_id,
        X_EXP_TXN_BILLING_TYPE_ID  => p_exp_txn_billing_type_id,
        X_INTERNAL_ORDER_FLAG      => p_internal_order_flag,
    --    X_THIRD_PARTY_FLAG      => p_third_party_flag,
        X_OBJECT_VERSION_NUMBER    => p_object_version_number,
        X_START_FLOW_STATUS_ID     => null
        );
--
END Load_Row;
--
end CSD_REPAIR_TYPES_PKG;

/
