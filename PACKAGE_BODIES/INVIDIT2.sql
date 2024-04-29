--------------------------------------------------------
--  DDL for Package Body INVIDIT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVIDIT2" AS
/* $Header: INVIDI2B.pls 120.5.12010000.2 2008/09/09 11:41:39 appldev ship $ */

  -- After inserting an item:
  --  insert into mtl_pending_item_status
  --  insert into mtl_item_revisions
  --  insert into mtl_item_categories
  --  call CSTPIICI to insert into cst_item_costs
  --  insert into mtl_uom_conversions
  -- Call other procedures passing event='INSERT'

  -- After updating an item:
  --  insert into mtl_pending_item_status
  --  insert into mtl_item_categories
  --  insert into mtl_uom_conversions
  -- Call other procedures passing event = 'UPDATE'

  -- After assigning the item to a child org:
  --  delete from mtl_item_categories
  --  insert into mtl_item_categories
  --  insert into mtl_pending_item_status
  --  insert into mtl_item_revisions
  --  call CSTPIICI to insert into cst_item_costs
  -- Call other procedures passing event = 'ORG_ASSIGN'

  -- After updating item/org attributes:
  --  insert into mtl_pending_item_status
  --  insert into mtl_item_categories
  --  insert into mtl_uom_conversions
  -- Call other procedures passing event = 'ITEM_ORG'

l_cat_ins_upd  BOOLEAN := FALSE; --* Added for Bug 4491340

PROCEDURE Table_Inserts
(
   X_event                       VARCHAR2
,  X_item_id                     NUMBER
,  X_org_id                      NUMBER
,  X_master_org_id               NUMBER
,  X_status_code                 VARCHAR2    DEFAULT  NULL
,  X_inventory_item_flag         VARCHAR2
,  X_purchasing_item_flag        VARCHAR2
,  X_internal_order_flag         VARCHAR2
,  X_mrp_planning_code           NUMBER
,  X_serviceable_product_flag    VARCHAR2
,  X_costing_enabled_flag        VARCHAR2
,  X_eng_item_flag               VARCHAR2
,  X_customer_order_flag         VARCHAR2
,  X_eam_item_type               NUMBER
,  X_contract_item_type_code     VARCHAR2
,  p_Folder_Category_Set_id      IN   NUMBER
,  p_Folder_Item_Category_id     IN   NUMBER
,  X_allowed_unit_code           NUMBER      DEFAULT  0
,  X_primary_uom                 VARCHAR2    DEFAULT  NULL
,  X_primary_uom_code            VARCHAR2    DEFAULT  NULL
,  X_primary_uom_class           VARCHAR2    DEFAULT  NULL
,  X_inv_install                 NUMBER      DEFAULT  0
,  X_last_updated_by             NUMBER      DEFAULT  0
,  X_last_update_login           NUMBER      DEFAULT  0
,  X_item_catalog_group_id       NUMBER
,  P_Default_Move_Order_Sub_Inv  VARCHAR2 -- Item Transaction Defaults for 11.5.9
,  P_Default_Receiving_Sub_Inv   VARCHAR2
,  P_Default_Shipping_Sub_Inv    VARCHAR2
,  P_Lifecycle_Id                NUMBER      DEFAULT  NULL
,  P_Current_Phase_Id            NUMBER      DEFAULT  NULL
)
IS
BEGIN

  if ( X_event = 'INSERT' ) then

     Insert_Pending_Status('INSERT', X_item_id, X_org_id, X_master_org_id,
      X_status_code,P_Lifecycle_Id,P_Current_Phase_Id);

     Insert_Revision('INSERT', X_item_id, X_org_id, X_last_updated_by,
      X_last_update_login);

     Insert_Categories
     (
        X_event                     =>  'INSERT'
     ,  X_item_id                   =>  X_item_id
     ,  X_org_id                    =>  X_org_id
     ,  X_master_org_id             =>  X_master_org_id
     ,  X_inventory_item_flag       =>  X_inventory_item_flag
     ,  X_purchasing_item_flag      =>  X_purchasing_item_flag
     ,  X_internal_order_flag       =>  X_internal_order_flag
     ,  X_mrp_planning_code         =>  X_mrp_planning_code
     ,  X_serviceable_product_flag  =>  X_serviceable_product_flag
     ,  X_costing_enabled_flag      =>  X_costing_enabled_flag
     ,  X_eng_item_flag             =>  X_eng_item_flag
     ,  X_customer_order_flag       =>  X_customer_order_flag
     ,  X_eam_item_type             =>  X_eam_item_type
     ,  X_contract_item_type_code   =>  X_contract_item_type_code
     ,  p_Folder_Category_Set_id    =>  p_Folder_Category_Set_id
     ,  p_Folder_Item_Category_id   =>  p_Folder_Item_Category_id
     ,  X_last_updated_by           =>  X_last_updated_by
     );

     Insert_Cost_Row(X_item_id, X_master_org_id, X_inv_install,
      X_last_updated_by);

     Insert_Uom_Conversion(X_item_id, X_allowed_unit_code, X_primary_uom,
      X_primary_uom_code, X_primary_uom_class);

  elsif ( X_event = 'UPDATE' ) then

     -- If X_status_code is null, then the status was not changed in the
     -- form, so don't insert another row into mtl_pending_item_status.

     if ( X_status_code is not null ) then
        Insert_Pending_Status('UPDATE', X_item_id, X_org_id, X_master_org_id,
      X_status_code,P_Lifecycle_Id,P_Current_Phase_Id);
     end if;

     Insert_Categories
     (
        X_event                     =>  'UPDATE'
     ,  X_item_id                   =>  X_item_id
     ,  X_org_id                    =>  X_org_id
     ,  X_master_org_id             =>  X_master_org_id
     ,  X_inventory_item_flag       =>  X_inventory_item_flag
     ,  X_purchasing_item_flag      =>  X_purchasing_item_flag
     ,  X_internal_order_flag       =>  X_internal_order_flag
     ,  X_mrp_planning_code         =>  X_mrp_planning_code
     ,  X_serviceable_product_flag  =>  X_serviceable_product_flag
     ,  X_costing_enabled_flag      =>  X_costing_enabled_flag
     ,  X_eng_item_flag             =>  X_eng_item_flag
     ,  X_customer_order_flag       =>  X_customer_order_flag
     ,  X_eam_item_type             =>  X_eam_item_type
     ,  X_contract_item_type_code   =>  X_contract_item_type_code
     ,  p_Folder_Category_Set_id    =>  p_Folder_Category_Set_id
     ,  p_Folder_Item_Category_id   =>  p_Folder_Item_Category_id
     ,  X_last_updated_by           =>  X_last_updated_by
     );

     Insert_Uom_Conversion(X_item_id, X_allowed_unit_code, X_primary_uom,
      X_primary_uom_code, X_primary_uom_class);

    -- Sync item catalog group. item across all orgs should have only one
    -- catalog group. checks to see if same item in some other org has a
    -- different item catalog and if so, syncs up.

    update mtl_system_items_b
    set
       item_catalog_group_id = X_item_catalog_group_id
    where
           inventory_item_id = X_item_id
       and organization_id  <> X_org_id
       and exists
           ( select 1 from mtl_system_items_b
             where inventory_item_id = X_item_id and
                 organization_id <> X_org_id and
                 nvl (item_catalog_group_id, -1) <>
                 nvl (X_item_catalog_group_id, -1)
           )
    ;

  elsif ( X_event = 'ITEM_ORG' ) then

     -- If X_status_code is null, then the status was not changed in the
     -- form, so don't insert another row into mtl_pending_item_status.

     if ( X_status_code is not null ) then
        Insert_Pending_Status('ITEM_ORG', X_item_id, X_org_id, X_master_org_id,
      X_status_code,P_Lifecycle_Id,P_Current_Phase_Id);
     end if;

     Insert_Categories
     (
        X_event                     =>  'ITEM_ORG'
     ,  X_item_id                   =>  X_item_id
     ,  X_org_id                    =>  X_org_id
     ,  X_master_org_id             =>  X_master_org_id
     ,  X_inventory_item_flag       =>  X_inventory_item_flag
     ,  X_purchasing_item_flag      =>  X_purchasing_item_flag
     ,  X_internal_order_flag       =>  X_internal_order_flag
     ,  X_mrp_planning_code         =>  X_mrp_planning_code
     ,  X_serviceable_product_flag  =>  X_serviceable_product_flag
     ,  X_costing_enabled_flag      =>  X_costing_enabled_flag
     ,  X_eng_item_flag             =>  X_eng_item_flag
     ,  X_customer_order_flag       =>  X_customer_order_flag
     ,  X_eam_item_type             =>  X_eam_item_type
     ,  X_contract_item_type_code   =>  X_contract_item_type_code
     ,  p_Folder_Category_Set_id    =>  p_Folder_Category_Set_id
     ,  p_Folder_Item_Category_id   =>  p_Folder_Item_Category_id
     ,  X_last_updated_by           =>  X_last_updated_by
     );

     Insert_Uom_Conversion(X_item_id, X_allowed_unit_code, X_primary_uom,
      X_primary_uom_code, X_primary_uom_class);

  elsif ( X_event = 'ORG_ASSIGN' ) then

     Delete_Categories(X_item_id, X_org_id);

     Insert_Categories
     (
        X_event                     =>  'ORG_ASSIGN'
     ,  X_item_id                   =>  X_item_id
     ,  X_org_id                    =>  X_org_id
     ,  X_master_org_id             =>  X_master_org_id
     ,  X_inventory_item_flag       =>  X_inventory_item_flag
     ,  X_purchasing_item_flag      =>  X_purchasing_item_flag
     ,  X_internal_order_flag       =>  X_internal_order_flag
     ,  X_mrp_planning_code         =>  X_mrp_planning_code
     ,  X_serviceable_product_flag  =>  X_serviceable_product_flag
     ,  X_costing_enabled_flag      =>  X_costing_enabled_flag
     ,  X_eng_item_flag             =>  X_eng_item_flag
     ,  X_customer_order_flag       =>  X_customer_order_flag
     ,  X_eam_item_type             =>  X_eam_item_type
     ,  X_contract_item_type_code   =>  X_contract_item_type_code
     ,  p_Folder_Category_Set_id    =>  p_Folder_Category_Set_id
     ,  p_Folder_Item_Category_id   =>  p_Folder_Item_Category_id
     ,  X_last_updated_by           =>  X_last_updated_by
     );

     Insert_Pending_Status('ORG_ASSIGN', X_item_id, X_org_id, X_master_org_id,
      X_status_code,P_Lifecycle_Id,P_Current_Phase_Id);

     Insert_Revision('ORG_ASSIGN', X_item_id, X_org_id, X_last_updated_by,
      X_last_update_login);

     Insert_Cost_Row(X_item_id, X_org_id, X_inv_install, X_last_updated_by);

  end if;  -- event

  -- Insert Item Transaction Default SubInventories

  if ( X_event IN ('INSERT','UPDATE','ITEM_ORG') ) then

     Insert_Default_SubInventories ( X_event       => X_event
               , X_item_id                     => X_item_id
               , X_org_id                      => X_org_id
               , P_Default_Move_Order_Sub_Inv  => P_Default_Move_Order_Sub_Inv
               , P_Default_Receiving_Sub_Inv   => P_Default_Receiving_Sub_Inv
               , P_Default_Shipping_Sub_Inv    => P_Default_Shipping_Sub_Inv
     );

  end if;

END Table_Inserts;


PROCEDURE Insert_Pending_Status
(
   X_event             varchar2,
   X_item_id              number,
   X_org_id            number,
   X_master_org_id         number,
   X_status            varchar2,
   X_Lifecycle_Id          number default null,
   X_Current_Phase_Id      number default null
)
IS
   status_level    number;
   attr_name     varchar2(50);
   l_user_id    NUMBER  :=  NVL(FND_GLOBAL.User_Id, 0);
--   l_debug       NUMBER  :=  NVL(FND_PROFILE.Value('INV_DEBUG_TRACE'), 0);
BEGIN

  if (X_event = 'INSERT') then

    -- X_org_id will be the master org

    insert into mtl_pending_item_status
            (inventory_item_id,
       organization_id,
            status_code,
            effective_date,
       implemented_date,
            pending_flag,
       lifecycle_id,
       phase_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
          values(X_item_id,
          X_org_id,
             X_status,
             sysdate,
       sysdate,
             'N',
       x_lifecycle_id,
       x_current_phase_id,
             sysdate,
             l_user_id,
             sysdate,
             l_user_id);

  elsif (X_event = 'UPDATE') then

    attr_name := 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

    select control_level
    into status_level
    from mtl_item_attributes
    where attribute_name = attr_name;

    if (status_level = 2) then

-- Use this same sql if called from Update Item form
-- pass in current org instead of master org
      insert into mtl_pending_item_status
        (inventory_item_id,
         organization_id,
         status_code,
         effective_date,
    implemented_date,
         pending_flag,
    lifecycle_id,
    phase_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
      values
        (X_item_id,
             X_org_id,
             X_status,
             sysdate,
        sysdate,
             'N',
        x_lifecycle_id,
        x_current_phase_id,
             sysdate,
             l_user_id,
             sysdate,
             l_user_id);

    elsif (status_level = 1) then

      insert into mtl_pending_item_status
        (inventory_item_id,
         organization_id,
         status_code,
         effective_date,
    implemented_date,
         pending_flag,
    lifecycle_id,
    phase_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
      select
         X_item_id,
         p.organization_id,
         X_status,
         sysdate,
    sysdate,
         'N',
    x_lifecycle_id,
    x_current_phase_id,
         sysdate,
         l_user_id,
         sysdate,
         l_user_id
       from     mtl_parameters p
       where    p.master_organization_id = X_master_org_id
       and      exists (select 'x' from mtl_system_items_B i
                 where i.inventory_item_id =
                        X_item_id
                 and   p.organization_id = i.organization_id);
    end if;

  elsif (X_event = 'ITEM_ORG') then

    insert into mtl_pending_item_status
        (inventory_item_id,
         organization_id,
         status_code,
         effective_date,
    implemented_date,
         pending_flag,
    lifecycle_id,
    phase_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    values
        (X_item_id,
             X_org_id,
             X_status,
             sysdate,
        sysdate,
             'N',
        x_lifecycle_id,
        x_current_phase_id,
             sysdate,
             l_user_id,
             sysdate,
             l_user_id);

  elsif (X_event = 'ORG_ASSIGN') then

    insert into mtl_pending_item_status
        (inventory_item_id,
         organization_id,
         status_code,
         effective_date,
    implemented_date,
         pending_flag,
    lifecycle_id,
    phase_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    values
        (X_item_id,
             X_org_id,
             X_status,
             sysdate,
        sysdate,
             'N',
        x_lifecycle_id,
           x_current_phase_id,
             sysdate,
             l_user_id,
             sysdate,
             l_user_id);

  end if;  -- event

END Insert_Pending_Status;


PROCEDURE Insert_Revision
(  X_event          varchar2,
   X_item_id           number,
   X_org_id         number,
   X_last_updated_by number,
   X_last_update_login  number)
IS
   l_sys_date     DATE := SYSDATE;
   l_revision_id  mtl_item_revisions_b.revision_id%TYPE;
BEGIN
   if (X_event = 'INSERT') then

      select mtl_item_revisions_b_s.nextval
      into l_revision_id from dual;

      insert into mtl_item_revisions_b
          (inventory_item_id,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      effectivity_date,
      implementation_date,
      revision,
      revision_label,-- Bug: 3017253
      revision_id,
      object_version_number)
      select    X_item_id,
                X_org_id,
                l_sys_date,
                X_last_updated_by,
                l_sys_date,
                X_last_updated_by,
                -1,
                l_sys_date,
                l_sys_date,
                starting_revision,
                starting_revision,-- Bug:3017253
           l_revision_id,
           1
      from  mtl_parameters
      where organization_id = X_org_id;

      INSERT INTO MTL_ITEM_REVISIONS_TL (
         INVENTORY_ITEM_ID,
         ORGANIZATION_ID,
         REVISION_ID,
         DESCRIPTION,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         LANGUAGE,
         SOURCE_LANG
         ) SELECT X_item_id,
             X_org_id,
                  l_revision_id,
                  NULL,
                l_sys_date,
                X_last_updated_by,
             l_sys_date,
                   X_last_updated_by,
             -1,
             L.LANGUAGE_CODE,
             USERENV('LANG')
             FROM FND_LANGUAGES L
             WHERE L.INSTALLED_FLAG in ('I', 'B')
             AND NOT EXISTS (SELECT NULL
           FROM MTL_ITEM_REVISIONS_TL T
           WHERE T.INVENTORY_ITEM_ID = X_item_id
           AND   T.ORGANIZATION_ID   = X_org_id
           AND   T.REVISION_ID       = l_revision_id
           AND   T.LANGUAGE          = L.LANGUAGE_CODE);

   elsif (X_event = 'ORG_ASSIGN') then

      select mtl_item_revisions_b_s.nextval
      into l_revision_id from dual;

      insert into mtl_item_revisions_b
   (inventory_item_id,
     organization_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login,
     effectivity_date,
     implementation_date,
     revision,
     revision_label,-- Bug: 3017253
     revision_id,
     object_version_number)
      select X_item_id,
             X_org_id,
             l_sys_date,
             X_last_updated_by,
             l_sys_date,
             X_last_updated_by,
             X_last_update_login,
             l_sys_date,
             l_sys_date,
             starting_revision,
             starting_revision,-- Bug:3017253
        l_revision_id,
        1
      from mtl_parameters
      where organization_id = X_org_id;

      INSERT INTO MTL_ITEM_REVISIONS_TL (
         INVENTORY_ITEM_ID,
         ORGANIZATION_ID,
         REVISION_ID,
         DESCRIPTION,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         LANGUAGE,
         SOURCE_LANG
         ) SELECT X_item_id,
             X_org_id,
                  l_revision_id,
                  NULL,
                l_sys_date,
                X_last_updated_by,
             l_sys_date,
                   X_last_updated_by,
             X_last_update_login,
             L.LANGUAGE_CODE,
             USERENV('LANG')
             FROM FND_LANGUAGES L
             WHERE L.INSTALLED_FLAG in ('I', 'B')
             AND NOT EXISTS (SELECT NULL
           FROM MTL_ITEM_REVISIONS_TL T
           WHERE T.INVENTORY_ITEM_ID = X_item_id
           AND   T.ORGANIZATION_ID   = X_org_id
           AND   T.REVISION_ID       = l_revision_id
           AND   T.LANGUAGE          = L.LANGUAGE_CODE);

   end if;  -- event

   --Bug 5525199 BE for implicit revision creation
   IF (X_event = 'ORG_ASSIGN' OR X_event = 'INSERT') THEN
      BEGIN
         INV_ITEM_EVENTS_PVT.Raise_Events(
           p_event_name        => 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT'
          ,p_dml_type          => 'CREATE'
          ,p_inventory_item_id => X_item_id
          ,p_organization_id   => X_org_id
          ,p_revision_id       => l_revision_id);
        EXCEPTION
          WHEN OTHERS THEN
             NULL;
      END;
   END IF;

END Insert_Revision;

PROCEDURE Insert_Categories
(
   X_event                       VARCHAR2
,  X_item_id                     NUMBER
,  X_org_id                      NUMBER
,  X_master_org_id               NUMBER
,  X_inventory_item_flag         VARCHAR2
,  X_purchasing_item_flag        VARCHAR2
,  X_internal_order_flag         VARCHAR2
,  X_mrp_planning_code           NUMBER
,  X_serviceable_product_flag    VARCHAR2
,  X_costing_enabled_flag        VARCHAR2
,  X_eng_item_flag               VARCHAR2
,  X_customer_order_flag         VARCHAR2
,  X_eam_item_type               NUMBER
,  X_contract_item_type_code     VARCHAR2
,  p_Folder_Category_Set_id      IN   NUMBER
,  p_Folder_Item_Category_id     IN   NUMBER
,  X_last_updated_by             NUMBER
)
IS
   TYPE ORG_LISTS    IS TABLE OF MTL_ITEM_CATEGORIES.ORGANIZATION_ID%TYPE;
   TYPE CATSET_LISTS IS TABLE OF MTL_ITEM_CATEGORIES.CATEGORY_SET_ID%TYPE;
   TYPE CAT_LISTS    IS TABLE OF MTL_ITEM_CATEGORIES.CATEGORY_ID%TYPE;

   l_organizations_rec    ORG_LISTS;
   l_category_sets_rec CATSET_LISTS;
   l_categories_rec    CAT_LISTS;

   l_the_item_assign_count    NUMBER;
   l_the_cat_assign_count     NUMBER;

   Cat_Set_No_Default_Cat    EXCEPTION;
   l_Func_Area               Varchar2(80);
   l_Cat_Set_Name            Varchar2(30);

   CURSOR Func_Area_csr IS
   SELECT
      mdcs.functional_area_id
   ,  FUNCTIONAL_AREA_DESC, mcs.category_set_name
   FROM
      mtl_category_sets_vl            mcs
   ,  mtl_default_category_sets_fk_v  mdcs
   WHERE
           mcs.category_set_id = mdcs.category_set_id
      AND  mcs.default_category_id IS NULL;

   CURSOR item_cat_assign_count_csr
   (  p_inventory_item_id    NUMBER
   ,  p_organization_id      NUMBER
   ,  p_category_set_id      NUMBER
   ,  p_category_id          NUMBER
   ) IS
      SELECT  COUNT( category_id ), COUNT( DECODE(category_id, p_category_id, 1, NULL) )
      FROM  mtl_item_categories
      WHERE
              inventory_item_id  =  p_inventory_item_id
         AND  organization_id    =  p_organization_id
         AND  category_set_id  =  p_category_set_id;

   CURSOR get_item_categories(cp_org_id  NUMBER
                             ,cp_item_id NUMBER)
   IS
      SELECT category_set_id
            ,category_id
      FROM   mtl_item_categories
      WHERE  organization_id   = cp_org_id
      AND    inventory_item_id = cp_item_id;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);

BEGIN
  -- Check if default category id is defined.

  BEGIN

     FOR Funct_Val IN Func_Area_csr LOOP
        IF ( (Funct_Val.functional_area_id = 1 and X_inventory_item_flag = 'Y' )
         Or (Funct_Val.functional_area_id = 2 and X_purchasing_item_flag = 'Y')
         Or (Funct_Val.functional_area_id = 2 and X_internal_order_flag = 'Y')
         Or (Funct_Val.functional_area_id = 3 and X_mrp_planning_code <> 6)
         Or (Funct_Val.functional_area_id = 4 and X_serviceable_product_flag ='Y
')
         Or (Funct_Val.functional_area_id = 5 and X_costing_enabled_flag = 'Y')
         Or (Funct_Val.functional_area_id = 6 and X_eng_item_flag = 'Y')
         Or (Funct_Val.functional_area_id = 7 and X_customer_order_flag = 'Y')
         Or (Funct_Val.functional_area_id = 9 and X_eam_item_type is NOT NULL)
         Or (Funct_Val.functional_area_id = 10 and X_contract_item_type_code is NOT NULL)
--Bug: 2433351
/**Bug: 2801594 Commented No need to check for Product Functional Area.
         Or (Funct_Val.functional_area_id = 11 and X_customer_order_flag = 'Y')
         Or (Funct_Val.functional_area_id = 11 and X_internal_order_flag = 'Y')
**/
        )THEN
           l_Func_Area := Funct_Val.FUNCTIONAL_AREA_DESC;
           l_Cat_Set_Name := Funct_Val.CATEGORY_SET_NAME;
           RAISE Cat_Set_No_Default_Cat;
        END IF;
     END LOOP;

     IF ( Func_Area_csr%ISOPEN ) THEN
        CLOSE Func_Area_csr;
     END IF;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
        IF ( Func_Area_csr%ISOPEN ) THEN
           CLOSE Func_Area_csr;
        END IF;

     WHEN Cat_Set_No_Default_Cat THEN
        IF ( Func_Area_csr%ISOPEN ) THEN
           CLOSE Func_Area_csr;
        END IF;
        FND_MESSAGE.SET_NAME ('INV', 'INV_CAT_SET_NO_DEFAULT_CAT');
        FND_MESSAGE.SET_TOKEN ('ENTITY1', l_Func_Area);
        FND_MESSAGE.SET_TOKEN ('ENTITY2', l_Cat_Set_Name);
        APP_EXCEPTION.Raise_Exception;

  END;  -- Check of default category


   -- Get the folder item all category assignments count,
   -- and the folder item new category (passed in as a parameter) assignments count.

   IF (     p_Folder_Category_Set_id  IS NOT NULL
        AND p_Folder_Item_Category_id IS NOT NULL ) THEN

      OPEN item_cat_assign_count_csr
      (  p_inventory_item_id  =>  X_item_id
      ,  p_organization_id    =>  X_org_id
      ,  p_category_set_id    =>  p_Folder_Category_Set_id
      ,  p_category_id        =>  p_Folder_Item_Category_id
      );

      FETCH item_cat_assign_count_csr
      INTO l_the_item_assign_count, l_the_cat_assign_count;

      CLOSE item_cat_assign_count_csr;

   END IF;  -- Folder category id IS NOT NULL

  ---------------------------------
  -- Insert Master or Org Update --
  ---------------------------------

  if ( X_event in ('INSERT', 'ITEM_ORG') ) then

     -- Insert/Update folder item category assignment.
     -- Since this in effect superceedes a default assignment, do this
     -- before a functional area default category assignment.
     IF (     p_Folder_Category_Set_id  IS NOT NULL
          AND p_Folder_Item_Category_id IS NOT NULL ) THEN
        -- INSERT or UPDATE folder item category assignment, depending
        -- on the item current assignments.

        IF ( l_the_item_assign_count = 0 ) THEN

           INSERT INTO mtl_item_categories
           (
              inventory_item_id
           ,  organization_id
           ,  category_set_id
           ,  category_id
           ,  last_update_date
           ,  last_updated_by
           ,  creation_date
           ,  created_by
           ,   last_update_login,
               program_application_id,
               program_id,
               program_update_date,
               request_id
           )
           SELECT
              X_item_id
           ,  X_org_id
           ,  p_Folder_Category_Set_id
           ,  p_Folder_Item_Category_id
           ,  SYSDATE
           ,  X_last_updated_by
           ,  SYSDATE
           ,  X_last_updated_by
           ,        -1,
                    -1,
                    -1,
                    SYSDATE,
                    -1
           FROM
              dual;

           --* Added for Bug 4491340
           IF SQL%ROWCOUNT  > 0 THEN
              l_cat_ins_upd := TRUE;
              INV_ITEM_EVENTS_PVT.Raise_Events(
                      p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
                     ,p_dml_type          => 'CREATE'
                     ,p_inventory_item_id => X_item_id
                     ,p_organization_id   => X_org_id
                     ,p_category_set_id   => p_Folder_Category_Set_id
                     ,p_category_id       => p_Folder_Item_Category_id);
           END IF;

/*
           WHERE
              -- Check if the item already has a category assignment in this category set
              NOT EXISTS
                  ( SELECT  'x'
                    FROM  mtl_item_categories  mic
                    WHERE
                            mic.inventory_item_id  =  X_item_id
                       AND  mic.organization_id    =  X_org_id
                       AND  mic.category_set_id  =  p_Folder_Category_Set_id
                  )
           ;
*/
           --* End of Bug 4491340

        ELSIF ( l_the_item_assign_count = 1
                AND l_the_cat_assign_count = 0 ) THEN

           UPDATE mtl_item_categories
           SET
              category_id  =  p_Folder_Item_Category_id
           ,  last_update_date  =  SYSDATE
           ,  last_updated_by   =  X_last_updated_by
           ,  last_update_login =  -1
           WHERE
                   inventory_item_id  =  X_item_id
              AND  organization_id    =  X_org_id
              AND  category_set_id  =  p_Folder_Category_Set_id
              AND  category_id =
                   ( SELECT  mic.category_id
                     FROM  mtl_item_categories  mic
                     WHERE
                             mic.inventory_item_id  =  X_item_id
                        AND  mic.organization_id    =  X_org_id
                        AND  mic.category_set_id  =  p_Folder_Category_Set_id
                   )
           ;

           --* Added for Bug 4491340
           IF SQL%ROWCOUNT  > 0 THEN
              l_cat_ins_upd := TRUE;
              INV_ITEM_EVENTS_PVT.Raise_Events(
  	              p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
                     ,p_dml_type          => 'UPDATE'
                     ,p_inventory_item_id => X_item_id
                     ,p_organization_id   => X_org_id
                     ,p_category_set_id   => p_Folder_Category_Set_id
                     ,p_category_id       => p_Folder_Item_Category_id);
           END IF;
           --* End of Bug 4491340

        END IF;  -- insert/update

     END IF;  -- Folder category id IS NOT NULL

     -- Default category assignment for a functional area.
     -- Use the same statement if called from either Define or Update Item form.

-- Bug:2433351 an org item update belonging to the Product Reporting functional area

    if ( X_event = 'ITEM_ORG') then

     SELECT
        p.organization_id
       ,s.category_set_id
       ,s.default_category_id
     BULK COLLECT INTO
       l_organizations_rec
      ,l_category_sets_rec
      ,l_categories_rec
     FROM
        mtl_category_sets_b  s
     ,  mtl_parameters       p
     WHERE
             p.master_organization_id = X_master_org_id
        AND  s.default_category_id IS NOT NULL --Bug: 2801594
        AND  s.category_set_id =
        ( SELECT  d.category_set_id
          FROM  mtl_default_category_sets  d
          WHERE
            d.functional_area_id = DECODE( X_customer_order_flag, 'Y', 11, 0 )
           OR d.functional_area_id = DECODE( X_internal_order_flag, 'Y', 11, 0 )
        )
        AND EXISTS
        ( SELECT 'x'
          FROM  mtl_system_items_b  i
          WHERE
                 i.inventory_item_id = X_item_id
             AND i.organization_id   = p.organization_id
        )
        -- Check if the item already has any category assignment
        AND NOT EXISTS
            ( SELECT  'x'
              FROM  mtl_item_categories  mic
              WHERE
                      mic.inventory_item_id = X_item_id
                 AND  mic.organization_id   = p.organization_id
                 AND  mic.category_set_id = s.category_set_id);

     FORALL I in l_organizations_rec.FIRST .. l_organizations_rec.LAST
        INSERT INTO mtl_item_categories(
	   inventory_item_id
          ,organization_id
          ,category_set_id
	  ,category_id
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,program_application_id
          ,program_id
          ,program_update_date
          ,request_id)
        VALUES(
           x_item_id
	  ,l_organizations_rec(i)
	  ,l_category_sets_rec(i)
	  ,l_categories_rec(i)
          ,sysdate
          ,X_last_updated_by
          ,sysdate
          ,X_last_updated_by
          ,-1
          ,-1
          ,-1
          ,sysdate
          ,-1);

     IF l_organizations_rec.COUNT > 0 THEN
          --* Added for Bug 4491340
        l_cat_ins_upd := TRUE;

     FOR I IN l_organizations_rec.FIRST .. l_organizations_rec.LAST
     LOOP
        INV_ITEM_EVENTS_PVT.Raise_Events(
              p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
             ,p_dml_type          => 'CREATE'
             ,p_inventory_item_id => X_item_id
             ,p_organization_id   => l_organizations_rec(i)
             ,p_category_set_id   => l_category_sets_rec(i)
             ,p_category_id       => l_categories_rec(i) );
     END LOOP;
     END IF;


   end if;

     SELECT
         s.category_set_id
        ,s.default_category_id
     BULK COLLECT INTO
         l_category_sets_rec
	,l_categories_rec
     FROM
        mtl_category_sets_b  s
     WHERE
        s.category_set_id IN
        ( SELECT  d.category_set_id
          FROM  mtl_default_category_sets  d
          WHERE
              d.functional_area_id = DECODE( X_inventory_item_flag, 'Y', 1, 0 )
           OR d.functional_area_id = DECODE( X_purchasing_item_flag, 'Y', 2, 0 )
           OR d.functional_area_id = DECODE( X_internal_order_flag, 'Y', 2, 0 )
           OR d.functional_area_id = DECODE( X_mrp_planning_code, 6, 0, 3 )
           OR d.functional_area_id = DECODE( X_serviceable_product_flag, 'Y', 4, 0 )
           OR d.functional_area_id = DECODE( X_costing_enabled_flag, 'Y', 5, 0 )
           OR d.functional_area_id = DECODE( X_eng_item_flag, 'Y', 6, 0 )
           OR d.functional_area_id = DECODE( X_customer_order_flag, 'Y', 7, 0 )
           OR d.functional_area_id = DECODE( NVL(X_eam_item_type, 0), 0, 0, 9 )
           OR d.functional_area_id =
                 DECODE( X_contract_item_type_code,
                         'SERVICE'      , 10,
                         'WARRANTY'     , 10,
                         'SUBSCRIPTION' , 10,
                         'USAGE'        , 10, 0 )
           -- These Contract Item types also imply an item belonging to the Service functional area
           OR d.functional_area_id =
                 DECODE( X_contract_item_type_code,
                         'SERVICE'      , 4,
                         'WARRANTY'     , 4, 0 )
--Bug:2433351
           OR d.functional_area_id = DECODE( X_customer_order_flag, 'Y', 11, 0 )
           OR d.functional_area_id = DECODE( X_internal_order_flag, 'Y', 11, 0 )
        )
        AND  s.default_category_id IS NOT NULL --Bug: 2801594
        -- Check if the item already has any category assignment
        AND NOT EXISTS
            ( SELECT  'x'
              FROM  mtl_item_categories mic
              WHERE
                     mic.inventory_item_id = X_item_id
                 AND mic.organization_id   = X_org_id
                 AND mic.category_set_id = s.category_set_id
            );


     FORALL I IN l_categories_rec.FIRST .. l_categories_rec.LAST
        INSERT INTO mtl_item_categories(
        inventory_item_id
       ,organization_id
       ,category_set_id,
        category_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id)
      VALUES(
              X_item_id
             ,X_org_id
             ,l_category_sets_rec(i),
              l_categories_rec(i),
              sysdate,
              X_last_updated_by,
              sysdate,
              X_last_updated_by,
              -1,
              -1,
              -1,
              sysdate,
              -1);


     IF l_categories_rec.COUNT > 0 THEN
     --* Added for Bug 4491340
        l_cat_ins_upd := TRUE;
     FOR I IN l_categories_rec.FIRST .. l_categories_rec.LAST
     LOOP
        INV_ITEM_EVENTS_PVT.Raise_Events(
              p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
             ,p_dml_type          => 'CREATE'
             ,p_inventory_item_id => X_item_id
             ,p_organization_id   => X_org_id
             ,p_category_set_id   => l_category_sets_rec(i)
             ,p_category_id       => l_categories_rec(i) );
     END LOOP;
     END IF;


  -------------------
  -- Update Master --
  -------------------

  elsif ( X_event = 'UPDATE' ) then

     -- Insert folder item category assignment.
     -- Since this in effect superceedes a default assignment, do this
     -- before a functional area default category assignment.

     IF (     p_Folder_Category_Set_id  IS NOT NULL
          AND p_Folder_Item_Category_id IS NOT NULL ) THEN

        -- INSERT or UPDATE category assignment, depending on the item
        -- current assignments.

        IF ( l_the_item_assign_count = 0 ) THEN

           SELECT
             p.organization_id
           BULK COLLECT INTO
	     l_organizations_rec
           FROM
              mtl_parameters  p
           WHERE
                  p.master_organization_id = X_master_org_id
              AND EXISTS
              ( SELECT 'x'
                FROM  mtl_system_items_b  i
                WHERE
                       i.inventory_item_id = X_item_id
                   AND i.organization_id   = p.organization_id
              )
              -- Check if org item already has a category assignment in this category set
              AND NOT EXISTS
                  ( SELECT  'x'
                    FROM  mtl_item_categories  mic
                    WHERE
                            mic.inventory_item_id  =  X_item_id
                       AND  mic.organization_id    =  p.organization_id
                       AND  mic.category_set_id  =  p_Folder_Category_Set_id
                  );

           FORALL I in l_organizations_rec.FIRST .. l_organizations_rec.LAST
              INSERT INTO mtl_item_categories(
              inventory_item_id
             ,organization_id
             ,category_set_id
             ,category_id
             ,last_update_date
             ,last_updated_by
             ,creation_date
             ,created_by
             ,last_update_login,
              program_application_id,
              program_id,
              program_update_date,
              request_id
           )
           VALUES(
              X_item_id
             ,l_organizations_rec(i)
             ,p_Folder_Category_Set_id
             ,p_Folder_Item_Category_id
             ,SYSDATE
             ,X_last_updated_by
             ,SYSDATE
             ,X_last_updated_by
             ,-1,
              -1,
              -1,
              SYSDATE,
              -1);

           IF l_organizations_rec.COUNT > 0 THEN
           --* Added for Bug 4491340
             l_cat_ins_upd := TRUE;
           FOR I IN l_organizations_rec.FIRST .. l_organizations_rec.LAST
	   LOOP
              INV_ITEM_EVENTS_PVT.Raise_Events(
                      p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
                     ,p_dml_type          => 'CREATE'
                     ,p_inventory_item_id => X_item_id
                     ,p_organization_id   => l_organizations_rec(i)
                     ,p_category_set_id   => p_Folder_Category_Set_id
                     ,p_category_id       => p_Folder_Item_Category_id);
           END LOOP;
	   END IF;

        ELSIF ( l_the_item_assign_count = 1
                AND l_the_cat_assign_count = 0 ) THEN

           UPDATE mtl_item_categories
           SET
              category_id  =  p_Folder_Item_Category_id
           ,  last_update_date  =  SYSDATE
           ,  last_updated_by   =  X_last_updated_by
           ,  last_update_login  =  -1
           WHERE
                   inventory_item_id  =  X_item_id
              AND  organization_id IN
                   ( SELECT  p.organization_id
                     FROM  mtl_parameters  p
                     WHERE
                        p.master_organization_id = X_master_org_id
                   )
              AND  category_set_id  =  p_Folder_Category_Set_id
	      RETURNING ORGANIZATION_ID
	      BULK COLLECT INTO l_organizations_rec
           ;

           IF l_organizations_rec.COUNT > 0 THEN
           --* Added for Bug 4491340
              l_cat_ins_upd := TRUE;

           FOR I IN l_organizations_rec.FIRST .. l_organizations_rec.LAST
	   LOOP
              INV_ITEM_EVENTS_PVT.Raise_Events(
                      p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
                     ,p_dml_type          => 'UPDATE'
                     ,p_inventory_item_id => X_item_id
                     ,p_organization_id   => l_organizations_rec(i)
                     ,p_category_set_id   => p_Folder_Category_Set_id
                     ,p_category_id       => p_Folder_Item_Category_id);
           END LOOP;
	   END IF;

        END IF;  -- insert/update

     END IF;  -- Folder category id IS NOT NULL

     -- Default category assignment for a functional area.

     SELECT
        p.organization_id
       ,s.category_set_id
       ,s.default_category_id
     BULK COLLECT INTO
        l_organizations_rec
       ,l_category_sets_rec
       ,l_categories_rec
     FROM
        mtl_category_sets_b  s
     ,  mtl_parameters       p
     WHERE
             p.master_organization_id = X_master_org_id
        AND  s.default_category_id IS NOT NULL --Bug: 2801594
        AND  s.category_set_id IN
        ( SELECT  d.category_set_id
          FROM  mtl_default_category_sets  d
          WHERE
              d.functional_area_id = DECODE( X_inventory_item_flag, 'Y', 1, 0 )
           OR d.functional_area_id = DECODE( X_purchasing_item_flag, 'Y', 2, 0 )
           OR d.functional_area_id = DECODE( X_internal_order_flag, 'Y', 2, 0 )
           OR d.functional_area_id = DECODE( X_mrp_planning_code, 6, 0, 3 )
           OR d.functional_area_id = DECODE( X_serviceable_product_flag, 'Y', 4, 0 )
           OR d.functional_area_id = DECODE( X_costing_enabled_flag, 'Y', 5, 0 )
           OR d.functional_area_id = DECODE( X_eng_item_flag, 'Y', 6, 0 )
           OR d.functional_area_id = DECODE( X_customer_order_flag, 'Y', 7, 0 )
           OR d.functional_area_id = DECODE( NVL(X_eam_item_type, 0), 0, 0, 9 )
           OR d.functional_area_id =
                 DECODE( X_contract_item_type_code,
                         'SERVICE'      , 10,
                         'WARRANTY'     , 10,
                         'SUBSCRIPTION' , 10,
                         'USAGE'        , 10, 0 )
           -- These Contract Item types also imply an item belonging to the Service functional area
           OR d.functional_area_id =
                 DECODE( X_contract_item_type_code,
                         'SERVICE'      , 4,
                         'WARRANTY'     , 4, 0 )
--Bug:2433351
           OR d.functional_area_id = DECODE( X_customer_order_flag, 'Y', 11, 0 )
           OR d.functional_area_id = DECODE( X_internal_order_flag, 'Y', 11, 0 )
        )
        AND EXISTS
        ( SELECT 'x'
          FROM  mtl_system_items_b  i
          WHERE
                 i.inventory_item_id = X_item_id
             AND i.organization_id   = p.organization_id
        )
        -- Check if the item already has any category assignment
        AND NOT EXISTS
            ( SELECT  'x'
              FROM  mtl_item_categories  mic
              WHERE
                      mic.inventory_item_id = X_item_id
                 AND  mic.organization_id   = p.organization_id
                 AND  mic.category_set_id = s.category_set_id
            )
         /* Bug 2666280 */
        AND  EXISTS
            --Replaced org_organizations_definitions view
            ( SELECT 'x'
              FROM   hr_organization_information
              WHERE  organization_id = p.organization_id
                AND  org_information1 = 'INV' -- Inventory Enabled flag.
                AND  org_information2 = 'Y'
                AND  org_information_context || '' = 'CLASS');

     FORALL I IN l_categories_rec.FIRST .. l_categories_rec.LAST
        INSERT INTO mtl_item_categories
        (
        inventory_item_id
       ,organization_id
       ,category_set_id,
        category_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id)
     VALUES(
        X_item_id
       ,l_organizations_rec(i)
       ,l_category_sets_rec(i),
        l_categories_rec(i),
        sysdate,
        X_last_updated_by,
        sysdate,
        X_last_updated_by,
        -1,
        -1,
        -1,
        sysdate,
        -1);

     IF l_organizations_rec.COUNT > 0 THEN
      --* Added for Bug 4491340
         l_cat_ins_upd := TRUE;

     FOR I IN l_categories_rec.FIRST .. l_categories_rec.LAST
     LOOP
        INV_ITEM_EVENTS_PVT.Raise_Events(
              p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
             ,p_dml_type          => 'CREATE'
             ,p_inventory_item_id => X_item_id
             ,p_organization_id   => l_organizations_rec(i)
             ,p_category_set_id   => l_category_sets_rec(i)
             ,p_category_id       => l_categories_rec(i) );
     END LOOP;
     END IF;

  --------------------
  -- Org Assignment --
  --------------------

  elsif ( X_event = 'ORG_ASSIGN' ) then

     -- Insert folder item category assignment.
     -- Since this in effect superceedes a default assignment, do this
     -- before a functional area default category assignment.

     IF (     p_Folder_Category_Set_id  IS NOT NULL
          AND p_Folder_Item_Category_id IS NOT NULL ) THEN

        -- INSERT or UPDATE folder item category assignment, depending

        INSERT INTO mtl_item_categories(
           inventory_item_id
          ,organization_id
          ,category_set_id
          ,category_id
          ,last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           program_application_id,
           program_id,
           program_update_date,
           request_id)
        SELECT
           X_item_id
          ,X_org_id
          ,p_Folder_Category_Set_id
          ,p_Folder_Item_Category_id
          ,sysdate,
           X_last_updated_by,
           sysdate,
           X_last_updated_by,
           -1,
           -1,
           -1,
           sysdate,
           -1
        FROM
           mtl_category_sets_b  s
        ,  mtl_item_categories  c
        WHERE
                c.inventory_item_id = X_item_id
           AND  c.organization_id   = X_master_org_id
           AND  c.category_set_id  = p_Folder_Category_Set_id
           AND  c.category_id      = p_Folder_Item_Category_id
           AND  s.category_set_id = p_Folder_Category_Set_id
           AND  s.control_level   = 1
           -- Check if the item already has a category assignment in this category set
           AND NOT EXISTS
               ( SELECT  'x'
                 FROM  mtl_item_categories mic
                 WHERE
                         mic.inventory_item_id = X_item_id
                    AND  mic.organization_id   = X_org_id
                    AND  mic.category_set_id = p_Folder_Category_Set_id
               )
        ;

       --* Added for Bug 4491340
       IF SQL%ROWCOUNT  > 0 THEN
          INV_ITEM_EVENTS_PVT.Raise_Events(
                      p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
                     ,p_dml_type          => 'CREATE'
                     ,p_inventory_item_id => X_item_id
                     ,p_organization_id   => X_org_id
                     ,p_category_set_id   => p_Folder_Category_Set_id
                     ,p_category_id       => p_Folder_Item_Category_id);
          l_cat_ins_upd := TRUE;
       END IF;
       --* End of Bug 4491340

     END IF;  -- Folder category id IS NOT NULL

     -- Default category assignment for a functional area.

     SELECT
       c.category_set_id
      ,c.category_id
     BULK COLLECT INTO
       l_category_sets_rec
      ,l_categories_rec
     FROM
        mtl_category_sets_b  s
     ,  mtl_item_categories  c
     WHERE
            c.inventory_item_id = X_item_id
        AND c.organization_id   = X_master_org_id
        AND s.category_set_id = c.category_set_id
        AND ( s.control_level = 1
              OR EXISTS
                 ( SELECT 'x'
                   FROM  mtl_default_category_sets  d
                   WHERE
                          d.category_set_id = s.category_set_id
                      AND
              (d.functional_area_id = DECODE( X_inventory_item_flag, 'Y', 1, 0 )
           OR d.functional_area_id = DECODE( X_purchasing_item_flag, 'Y', 2, 0 )
           OR d.functional_area_id = DECODE( X_internal_order_flag, 'Y', 2, 0 )
           OR d.functional_area_id = DECODE( X_mrp_planning_code, 6, 0, 3 )
           OR d.functional_area_id = DECODE( X_serviceable_product_flag, 'Y', 4, 0 )
           OR d.functional_area_id = DECODE( X_costing_enabled_flag, 'Y', 5, 0 )
           OR d.functional_area_id = DECODE( X_eng_item_flag, 'Y', 6, 0 )
           OR d.functional_area_id = DECODE( X_customer_order_flag, 'Y', 7, 0 )
           OR d.functional_area_id = DECODE( NVL(X_eam_item_type, 0), 0, 0, 9 )
           OR d.functional_area_id =
                 DECODE( X_contract_item_type_code,
                         'SERVICE'      , 10,
                         'WARRANTY'     , 10,
                         'SUBSCRIPTION' , 10,
                         'USAGE'        , 10, 0 )
           -- These Contract Item types also imply an item belonging to the Service functional area
           OR d.functional_area_id =
                 DECODE( X_contract_item_type_code,
                         'SERVICE'      , 4,
                         'WARRANTY'     , 4, 0 )
--Bug:2433351
           OR d.functional_area_id = DECODE( X_customer_order_flag, 'Y', 11, 0 )
           OR d.functional_area_id = DECODE( X_internal_order_flag, 'Y', 11, 0 ))
            ))
        -- Check if the item already has any category assignment
        -- Bug #1814719.
        AND NOT EXISTS
            ( SELECT  'x'
              FROM  mtl_item_categories mic
              WHERE
                     mic.inventory_item_id = X_item_id
                 AND mic.organization_id   = X_org_id
                 AND mic.category_set_id = s.category_set_id
            );

     FORALL I IN l_categories_rec.FIRST .. l_categories_rec.LAST
     INSERT INTO mtl_item_categories
     (
        inventory_item_id
       ,organization_id
       ,category_set_id,
        category_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id)
     Values(
        X_item_id
       ,X_org_id
       ,l_category_sets_rec(i),
        l_categories_rec(i),
        sysdate,
        X_last_updated_by,
        sysdate,
        X_last_updated_by,
        -1,
        -1,
        -1,
        sysdate,
        -1);

     IF l_categories_rec.COUNT > 0 THEN
     --* Added for Bug 4491340
        l_cat_ins_upd := TRUE;

     FOR I IN l_categories_rec.FIRST .. l_categories_rec.LAST
     LOOP
        INV_ITEM_EVENTS_PVT.Raise_Events(
              p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
             ,p_dml_type          => 'CREATE'
             ,p_inventory_item_id => X_item_id
             ,p_organization_id   => X_org_id
             ,p_category_set_id   => l_category_sets_rec(i)
             ,p_category_id       => l_categories_rec(i) );
     END LOOP;
     END IF;

  end if;  -- X_event

   --
   -- Sync item category assignment with item record in STAR table.
   --
   --Bug: 2718703 checking for ENI product before calling their package

  --* Added IF condition for Bug 4491340
  IF l_cat_ins_upd THEN
   -- Start Bug: 3185516
   FOR cr IN get_item_categories(X_org_id,X_item_id)
   LOOP
           INV_ENI_ITEMS_STAR_PKG.Sync_Category_Assignments(
         p_api_version         => 1.0
             ,p_init_msg_list       => FND_API.g_TRUE
             ,p_inventory_item_id   => X_item_id
             ,p_organization_id     => X_org_id
             ,p_category_set_id     => cr.category_set_id
             ,p_old_category_id     => NULL
             ,p_new_category_id     => cr.category_id
             ,x_return_status       => l_return_Status
             ,x_msg_count           => l_msg_count
             ,x_msg_data            => l_msg_data);

      IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
         FND_MESSAGE.Set_Encoded (l_msg_data);
            APP_EXCEPTION.Raise_Exception;
           ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
         FND_MESSAGE.Set_Encoded (l_msg_data);
         APP_EXCEPTION.Raise_Exception;
           END IF;
   END LOOP;
   -- End Bug: 3185516
   l_cat_ins_upd := FALSE; --* Added for Bug 4491340

  END IF;
END Insert_Categories;


PROCEDURE Insert_Costing_Category
(
   X_item_id      number
,  X_org_id    number
)
IS
   l_user_id    NUMBER  :=  NVL(FND_GLOBAL.User_Id, 0);
BEGIN
   insert into mtl_item_categories
        (inventory_item_id,
         category_set_id,
         category_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id,
         organization_id)
   select
        X_item_id,
        s.category_set_id,
        s.default_category_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        -1,
        -1,
        -1,
        NULL,
        -1,
        X_org_id
    from    mtl_category_sets_B s
    where   s.category_set_id in
        (select d.category_set_id
        from    mtl_default_category_sets d
        where   d.functional_area_id = 5)
    and not exists
       ( select  'x'
         from    mtl_item_categories c
         where   c.inventory_item_id = X_item_id
         and     c.organization_id = X_org_id
         and     c.category_set_id = s.category_set_id
       );

     --* Added for Bug 4491340
     IF SQL%ROWCOUNT  > 0 THEN
        l_cat_ins_upd := TRUE;
     END IF;
     --* End of Bug 4491340

END Insert_Costing_Category;


PROCEDURE Insert_Cost_Row
(
   X_item_id   number
,  X_org_id number
,  X_inv_install  number
,  X_last_updated_by number
)
IS
  cst_return   number;
  cst_error varchar2(50);

-- if org_assign, use org_assign.last_updated_by

BEGIN

  if (X_inv_install = 401) then

    CSTPIICC.CSTPIICI(X_item_id,
        X_org_id,
        X_last_updated_by,
        cst_return,
        cst_error);

-- how to handle if error returned

  end if;

END Insert_Cost_Row;


-- This procedure should be called only if inventory_asset_flag is
--  updated to Y and costing_enabled_flag = Y.
-- Check in the form if that condition is true before calling this
--  procedure.

PROCEDURE Insert_Cost_Details
(
   X_item_id      number
,  X_org_id    number
,  X_inv_install  number
,  X_last_updated_by number
,  X_cst_item_type   number
)
IS
  cost_method     number;
  cst_lot_size    number;
  cst_shrink_rate number;
  cst_return      number;
  cst_error    varchar2(50);
BEGIN

  if (X_inv_install = 401) then

    INVIDIT2.Insert_Costing_Category(X_item_id, X_org_id);

    select primary_cost_method
    into cost_method
    from mtl_parameters
    where organization_id = X_org_id;

    begin

    select lot_size, shrinkage_rate
    into cst_lot_size, cst_shrink_rate
    from cst_item_costs
    where inventory_item_id = X_item_id
    and organization_id = X_org_id
    and cost_type_id = cost_method; --Bug#7149985 : Changed from cost_type_id = 1;

    exception
      when NO_DATA_FOUND then
   cst_lot_size := null;
   cst_shrink_rate := null;
    end;

    CSTPIDIC.CSTPIDIO(X_item_id,
           X_org_id,
        X_last_updated_by,
        cost_method,
        X_cst_item_type,
        cst_lot_size,
        cst_shrink_rate,
        cst_return,
        cst_error);

--    if (cst_return <> 0) then
--      show error
--    end if;

  end if;

END Insert_Cost_Details;


PROCEDURE Insert_Uom_Conversion
(
   X_item_id                number
,  X_allowed_unit_code      number
,  X_primary_uom            varchar2
,  X_primary_uom_code       varchar2
,  X_primary_uom_class      varchar2
)
IS
   v_rate    number;
BEGIN

  -- Only insert if conversion is item-specific (= 1)
  --
  if (X_allowed_unit_code = 1) then

    begin
      select conversion_rate
      into v_rate
      from mtl_uom_conversions
      where inventory_item_id = 0
        and uom_code = X_primary_uom_code;

      --and unit_of_measure = X_primary_uom;

    exception
    when NO_DATA_FOUND then
      v_rate := null;
    end;

    insert into mtl_uom_conversions
    (  unit_of_measure,
       uom_code,
       uom_class,
      inventory_item_id,
      conversion_rate,
      default_conversion_flag,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by
    ) select
       unit_of_measure,
       uom_code,
       uom_class,
      X_item_id,
      decode(base_uom_flag, 'Y', 1, v_rate),
      'N',
      sysdate,
      0,
      sysdate,
      0
    from mtl_units_of_measure_vl
    where uom_code = X_primary_uom_code
      and not exists
          ( select 'x'
            from mtl_uom_conversions
            where inventory_item_id = X_item_id
              and uom_code = X_primary_uom_code
          );

  end if;

END Insert_Uom_Conversion;


PROCEDURE Delete_Categories
(
   X_item_id   number
,  X_org_id number
)
IS

   CURSOR get_item_categories(cp_org_id  NUMBER
                             ,cp_item_id NUMBER
              ,cp_cat_set NUMBER)
   IS
      SELECT category_set_id
            ,category_id
      FROM   mtl_item_categories
      WHERE  organization_id   =  cp_org_id
      AND    inventory_item_id =  cp_item_id
      AND    category_set_id   <> cp_cat_set;

   -- Product Family Category Set ID
   G_PF_Category_Set_ID    CONSTANT NUMBER  := 3;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);


BEGIN

   -- Start Bug: 3185516
   FOR cr IN get_item_categories(X_org_id,X_item_id,G_PF_Category_Set_ID)
   LOOP
      INV_ENI_ITEMS_STAR_PKG.Sync_Category_Assignments(
                p_api_version         => 1.0
               ,p_init_msg_list       => FND_API.g_TRUE
               ,p_inventory_item_id   => X_item_id
          ,p_organization_id     => X_org_id
          ,p_category_set_id     => cr.category_set_id
          ,p_old_category_id     => NULL
          ,p_new_category_id     => cr.category_id
          ,x_return_status       => l_return_Status
          ,x_msg_count           => l_msg_count
          ,x_msg_data            => l_msg_data);

      IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
         FND_MESSAGE.Set_Encoded (l_msg_data);
         APP_EXCEPTION.Raise_Exception;
      ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
         FND_MESSAGE.Set_Encoded (l_msg_data);
         APP_EXCEPTION.Raise_Exception;
      END IF;
   END LOOP;
   -- End Bug: 3185516

  delete from mtl_item_categories
  where inventory_item_id = X_item_id
  and organization_id = X_org_id
  and CATEGORY_SET_ID <> G_PF_Category_Set_ID;

END Delete_Categories;


PROCEDURE Match_Catalog_Descr_Elements
(
   X_item_id             number
,  X_catalog_group_id    number
)
IS
BEGIN

  -- First, delete old descriptive element values for this item.
  -- Then insert new elements for new catalog group.

  delete from mtl_descr_element_values
  where inventory_item_id = X_item_id;

  insert into mtl_descr_element_values
  (  inventory_item_id,
    element_name,
    default_element_flag,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    element_sequence
  )
  select
    X_item_id,
      element_name,
      default_element_flag,
      sysdate,
      0,
      sysdate,
      0,
      element_sequence
  from mtl_descriptive_elements
  where item_catalog_group_id = X_catalog_group_id;

END Match_Catalog_Descr_Elements;


-- Procedure to insert Item Transaction Default SubInventories.

PROCEDURE Insert_Default_SubInventories ( X_Event       VARCHAR2
               , X_item_id    NUMBER
               , X_org_id     NUMBER
               , P_Default_Move_Order_Sub_Inv  VARCHAR2
               , P_Default_Receiving_Sub_Inv   VARCHAR2
               , P_Default_Shipping_Sub_Inv    VARCHAR2
               )
IS
   l_user_id    NUMBER  :=  NVL(FND_GLOBAL.User_Id, 0);

  l_process_code      VARCHAR2(30);
  x_return_status     VARCHAR2(100);
  x_msg_count         NUMBER;
  x_msg_data          VARCHAR2(2000);
  l_success           VARCHAR2(100) := fnd_api.g_ret_sts_success;
BEGIN

   IF ( X_Event = 'INSERT' ) THEN
     l_process_code := 'INSERT';
   ELSE
     l_process_code := 'SYNC';
   END IF;

   IF ( X_Event = 'INSERT' AND P_Default_Move_Order_Sub_Inv IS NULL )THEN
      NULL;

   ELSIF ( NVL(P_Default_Move_Order_Sub_Inv,'x') <> '!' ) THEN

     INV_ITEM_SUB_DEFAULT_PKG.INSERT_UPD_ITEM_SUB_DEFAULTS
     (
       p_organization_id       => x_org_id
     , p_inventory_item_id     => x_item_id
     , p_subinventory_code     => P_Default_Move_Order_Sub_Inv
     , p_default_type          => 3
     , p_creation_date         => sysdate
     , p_created_by            => l_user_id
     , p_last_update_date      => sysdate
     , p_last_updated_by       => l_user_id
     , p_process_code          => l_process_code
     , p_commit                => fnd_api.g_true
     , x_return_status         => x_return_status
     , x_msg_count             => x_msg_count
     , x_msg_data              => x_msg_data);

     IF NOT (x_return_status = l_success) THEN
       APP_EXCEPTION.Raise_Exception;
     END IF;

   END IF;

   IF ( X_Event = 'INSERT' AND P_Default_Receiving_Sub_Inv IS NULL )THEN
      NULL;

   ELSIF ( NVL(P_Default_Receiving_Sub_Inv,'x') <> '!' ) THEN

     INV_ITEM_SUB_DEFAULT_PKG.INSERT_UPD_ITEM_SUB_DEFAULTS
     (
       p_organization_id       => x_org_id
     , p_inventory_item_id     => x_item_id
     , p_subinventory_code     => P_Default_Receiving_Sub_Inv
     , p_default_type          => 2
     , p_creation_date         => sysdate
     , p_created_by            => l_user_id
     , p_last_update_date      => sysdate
     , p_last_updated_by       => l_user_id
     , p_process_code          => l_process_code
     , p_commit                => fnd_api.g_true
     , x_return_status         => x_return_status
     , x_msg_count             => x_msg_count
     , x_msg_data              => x_msg_data);

     IF NOT (x_return_status = l_success) THEN
       APP_EXCEPTION.Raise_Exception;
     END IF;

   END IF;

   IF ( X_Event = 'INSERT' AND P_Default_Shipping_Sub_Inv IS NULL )THEN
      NULL;

   ELSIF ( NVL(P_Default_Shipping_Sub_Inv,'x') <> '!' ) THEN

     INV_ITEM_SUB_DEFAULT_PKG.INSERT_UPD_ITEM_SUB_DEFAULTS
     (
       p_organization_id       => x_org_id
     , p_inventory_item_id     => x_item_id
     , p_subinventory_code     => P_Default_Shipping_Sub_Inv
     , p_default_type          => 1
     , p_creation_date         => sysdate
     , p_created_by            => l_user_id
     , p_last_update_date      => sysdate
     , p_last_updated_by       => l_user_id
     , p_process_code          => l_process_code
     , p_commit                => fnd_api.g_true
     , x_return_status         => x_return_status
     , x_msg_count             => x_msg_count
     , x_msg_data              => x_msg_data);

     IF NOT (x_return_status = l_success) THEN
       APP_EXCEPTION.Raise_Exception;
     END IF;

   END IF;

END Insert_Default_SubInventories;

END INVIDIT2;

/
