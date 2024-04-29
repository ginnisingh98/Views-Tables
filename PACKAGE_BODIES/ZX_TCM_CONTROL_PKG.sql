--------------------------------------------------------
--  DDL for Package Body ZX_TCM_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_CONTROL_PKG" AS
/* $Header: zxccontrolb.pls 120.82.12010000.3 2009/02/05 01:57:27 pla ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_TCM_CONTROL_PKG.';
  -- Logging Infra

   C_TAX_REGIME_CODE_DUMMY 	CONSTANT VARCHAR2(30) :=  '@#$%^&';
   C_TAX_DUMMY 			CONSTANT VARCHAR2(30) :=  '@#$%^&';
   C_JURISDICTION_CODE_DUMMY    CONSTANT VARCHAR2(30) := '@#$%^&';

PROCEDURE GET_FISCAL_CLASSIFICATION(
            p_fsc_rec           IN OUT NOCOPY ZX_TCM_CONTROL_PKG.ZX_FISCAL_CLASS_INFO_REC,
            p_return_status     OUT NOCOPY VARCHAR2) IS

 /* ------------------------------------------------------------------------------

   A Procedure to return Fiscal Classifications allocated to a Party,Party Site,
   Product or Transaction
   Parameter p_fsc_rec is a record structure.

 */

  l_status                   varchar2(1);
  l_db_status                varchar2(1);
  l_reg_fscType_flag         varchar2(1);
  l_inventory_set            varchar2(1);
  l_category_set_id          mtl_category_sets_b.category_set_id%type;
  l_category_id              mtl_categories_b.category_id%type;
  l_structure_id             mtl_category_sets_b.structure_id%type;
  l_allocated_flag           varchar2(15);
  l_tca_class_category_code  hz_class_categories.class_category%type;
  l_party_tax_profile_id     zx_party_tax_profile.party_tax_profile_id%type;
  l_party_id                 zx_party_tax_profile.party_id%type;
  l_table_owner              zx_fc_types_b.Owner_Table_Code%type;
  l_table_id                 zx_fc_types_b.owner_id_char%type;
  l_class_code               fnd_lookup_values.lookup_code%type;
  l_classification_type_code zx_fc_types_b.classification_type_code%type;
  l_effective_from           date;
  l_effective_to             date;
  l_Party_Type_Code          zx_party_tax_profile.Party_Type_Code%type;
  l_le_status                varchar2(30);
  l_le_other_fc_status       varchar2(30);
  l_xle_legal_entity         xle_utilities_grp.Legal_Entity_Tbl_Type;
  l_xle_establishment        xle_utilities_grp.Establishment_Tbl_Type;

  l_RETURN_STATUS            VARCHAR2(30);
  l_MSG_COUNT                NUMBER(15);
  l_MSG_DATA                 VARCHAR2(30);


  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'get_fiscal_classification';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  l_ptp_id    NUMBER;

  -- Validate if Fiscal Type has been associated to regime
   cursor c_regime_assoc is
   select 'Y'
   from zx_fc_types_reg_assoc
   where classification_type_code = p_fsc_rec.classification_type
   and   tax_regime_code = p_fsc_rec.tax_regime_code;

  -- Check also for regimes above.
   cursor c_parent_regime_assoc is
   select unique 'Y'
   from zx_fc_types_reg_assoc
   where classification_type_code = p_fsc_rec.classification_type
   and   tax_regime_code IN (
   select regime_code
   from zx_regime_relations
   connect by prior parent_regime_code = regime_code
   start with regime_code = p_fsc_rec.tax_regime_code );

 /* Cursors for Inventory Categories related */
 -- get category set id
   cursor c_inventory_set is
   Select owner_id_num
   from zx_fc_types_b
   where classification_type_code = p_fsc_rec.classification_type;

 -- get structure id for the category set
   cursor c_inventory_structure is
   select structure_id
   from mtl_category_sets_b
   where category_set_id =  l_category_set_id;

  -- get the category id for the category code
   cursor c_category is
   select mtl.category_id
   from mtl_categories_b_kfv mtl,
        fnd_id_flex_structures flex
   where mtl.structure_id = l_structure_id
   and flex.ID_FLEX_NUM = mtl.STRUCTURE_ID
   and flex.APPLICATION_ID = 401
   and flex.ID_FLEX_CODE = 'MCAT'
   and replace (mtl.concatenated_segments,flex.concatenated_segment_delimiter,'')= p_fsc_rec.condition_value;


 -- get the allocation
   cursor c_item_category is
   select 'ALLOCATED'
   from mtl_item_categories
   where category_set_id = l_category_set_id
   and   category_id = l_category_id
   and   organization_id = p_fsc_rec.item_org_id
   and   inventory_item_id = p_fsc_rec.classified_entity_id;

 -- get allocation for a child when rule is on a parent level
   cursor c_item_category_child is
   select 'ALLOCATED'
   from mtl_item_categories mit
   where mit.category_set_id = l_category_set_id
   and   mit.organization_id = p_fsc_rec.item_org_id
   and   mit.inventory_item_id = p_fsc_rec.classified_entity_id
   and   exists (
          select mtl.category_id
          from mtl_categories_b_kfv mtl,
               fnd_id_flex_structures flex,
               ( select start_position, num_characters
                 from zx_fc_types_b
                 where classification_type_code = p_fsc_rec.classification_type) fc
          where mtl.structure_id = l_structure_id
          and flex.ID_FLEX_NUM = mtl.STRUCTURE_ID
          and flex.APPLICATION_ID = 401
          and flex.ID_FLEX_CODE = 'MCAT'
          and mtl.category_id  = mit.category_id
          and substr(replace (mtl.concatenated_segments,flex.concatenated_segment_delimiter,''),fc.start_position,fc.num_characters) = p_fsc_rec.condition_value);

 /* Cursors for TCA Classification related */

 -- get TCA Class Category id
   cursor c_tca_class_category is
   Select owner_id_char
   from zx_fc_types_b
   where classification_type_code = p_fsc_rec.classification_type;

   cursor c_party_tax_profile_id  is
   Select party_id ,Party_Type_Code
   from zx_party_tax_profile
   where party_tax_profile_id = p_fsc_rec.classified_entity_id;

   cursor c_class_code is
   select class_code
   from hz_class_code_denorm
   where class_category = l_tca_class_category_code
   and concat_class_code = p_fsc_rec.condition_value;

   cursor c_party_category is
   select 'ALLOCATED',start_date_active,end_date_active
   from hz_code_assignments
   where class_category = l_tca_class_category_code
   and class_code = l_class_code
   and owner_table_name = l_table_owner
   and owner_table_id = l_table_id
   and p_fsc_rec.tax_determine_date between start_date_active and nvl(end_date_active,p_fsc_rec.tax_determine_date);

-- Begin Bug Fix 5528805

   cursor c_party_category_multi_level is
   select 'ALLOCATED',start_date_active,end_date_active
   from hz_code_assignments
   where class_category = l_tca_class_category_code
   and owner_table_name = l_table_owner
   and owner_table_id = l_table_id
   and p_fsc_rec.tax_determine_date between start_date_active and nvl(end_date_active,p_fsc_rec.tax_determine_date)
   and class_code in (select class_code from hz_class_code_denorm
                      where class_category = l_tca_class_category_code
                      and SUBSTR(concat_class_code , 0, LENGTH(p_fsc_rec.condition_value)) = p_fsc_rec.condition_value
                     );

   l_c_party_category_not_found  VARCHAR2(1) := 'N';

-- End Bug Fix 5528805

   cursor c_pty_fc_assgn_exists is
   select 'EXISTS'
   from hz_code_assignments
   where class_category = l_tca_class_category_code
   and owner_table_name = l_table_owner
   and owner_table_id = l_table_id
   and p_fsc_rec.tax_determine_date between start_date_active and nvl(end_date_active,p_fsc_rec.tax_determine_date)
   and rownum = 1;

 -- Cursors used for Transaction Fiscal Classification
   cursor c_classification_type_code is
   Select classification_type_code
   from zx_fc_types_b
   where classification_type_code = p_fsc_rec.classification_type;

/*
  Cursor c_trxbizcat_fiscalclass is
   select 'ALLOCATED',effective_from, effective_to
   from zx_fc_codes_categ_assoc
  where classification_type_code =   NVL(FcType.OWNER_ID_CHAR,p_fsc_rec.classification_type)
   and  FcType
   and  Classification_Code_Concat = p_fsc_rec.condition_value
   and  trans_business_categ_type_code = 'TRX_BUSINESS_CATEGORY'
   and  Trans_Business_Categ_Concat = p_fsc_rec.event_class_code
   and  p_fsc_rec.tax_determine_date between effective_from and nvl(effective_to,p_fsc_rec.tax_determine_date);
*/

  Cursor c_trxbizcat_fiscalclass is
   select 'ALLOCATED',assoc.effective_from, assoc.effective_to
   from zx_fc_codes_categ_assoc assoc,
        zx_fc_types_b fctypes,
        zx_fc_codes_denorm_b denorm
   where assoc.classification_type_code =  nvl(fctypes.owner_id_char,p_fsc_rec.classification_type)
   and  fctypes.classification_type_code =  p_fsc_rec.classification_type
   and  assoc.Classification_Code_Concat = p_fsc_rec.condition_value
   and  assoc.trans_business_categ_type_code = 'TRX_BUSINESS_CATEGORY'
   and  denorm.CONCAT_CLASSIF_CODE = p_fsc_rec.condition_value
   and  denorm.CLASSIFICATION_CODE_LEVEL = fctypes.CLASSIFICATION_TYPE_LEVEL_CODE
   and  denorm.LANGUAGE = USERENV('LANG')
   and  assoc.Trans_Business_Categ_Concat = p_fsc_rec.event_class_code
   and  p_fsc_rec.tax_determine_date between assoc.effective_from and nvl(assoc.effective_to,p_fsc_rec.tax_determine_date);


  -- Traverse to check for association to higher levels on Trx Biz Category
/*
   Cursor c_parent_trxbizcat_fiscalclass is
   select 'ALLOCATED',effective_from, effective_to
   from zx_fc_codes_categ_assoc
   where classification_type_code =  p_fsc_rec.classification_type
   and  Classification_Code_Concat = p_fsc_rec.condition_value
   and  trans_business_categ_type_code = 'TRX_BUSINESS_CATEGORY'
   and  instr(p_fsc_rec.event_class_code,Trans_Business_Categ_Concat) <> 0
   and  p_fsc_rec.tax_determine_date between effective_from and nvl(effective_to,p_fsc_rec.tax_determine_date);
*/

 Cursor c_parent_trxbizcat_fiscalclass is
   select 'ALLOCATED',assoc.effective_from, assoc.effective_to
   from zx_fc_codes_categ_assoc assoc,
        zx_fc_types_b fctypes,
        zx_fc_codes_denorm_b denorm
   where assoc.classification_type_code =  nvl(fctypes.owner_id_char,p_fsc_rec.classification_type)
   and  fctypes.classification_type_code =  p_fsc_rec.classification_type
   and  assoc.Classification_Code_Concat = p_fsc_rec.condition_value
   and  denorm.CONCAT_CLASSIF_CODE = p_fsc_rec.condition_value
   and  denorm.CLASSIFICATION_CODE_LEVEL = fctypes.CLASSIFICATION_TYPE_LEVEL_CODE
   and  denorm.LANGUAGE = USERENV('LANG')
   and  assoc.trans_business_categ_type_code = 'TRX_BUSINESS_CATEGORY'
   and  instr(p_fsc_rec.event_class_code,assoc.Trans_Business_Categ_Concat ) <> 0
   and  p_fsc_rec.tax_determine_date between assoc.effective_from and nvl(assoc.effective_to,p_fsc_rec.tax_determine_date);



 -- Cursor for LE information
   CURSOR c_xle_activity_code IS
   SELECT 'ALLOCATED', le_effective_from, le_effective_to
   FROM  xle_firstparty_information_v
   WHERE party_id = l_party_id
   AND activity_category = l_tca_class_category_code
   AND activity_code = l_class_code
--   AND p_fsc_rec.tax_determine_date between le_effective_from and nvl(le_effective_to,p_fsc_rec.tax_determine_date);
   AND p_fsc_rec.tax_determine_date between NVL(le_effective_from,p_fsc_rec.tax_determine_date) and nvl(le_effective_to,p_fsc_rec.tax_determine_date);

   CURSOR c_xle_fc_assgn_exists IS
   SELECT 'EXISTS'
   FROM  xle_firstparty_information_v
   WHERE party_id = l_party_id
   AND activity_category = l_tca_class_category_code
-- AND p_fsc_rec.tax_determine_date between le_effective_from and nvl(le_effective_to,p_fsc_rec.tax_determine_date)
   AND p_fsc_rec.tax_determine_date between NVL(le_effective_from,p_fsc_rec.tax_determine_date) and nvl(le_effective_to,p_fsc_rec.tax_determine_date)
   AND rownum = 1;

 BEGIN
 -- Logging Infra: Setting up runtime level
 G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 -- Logging Infra: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(+)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
 END IF;

 -- Logging Infra: YK: 3/5: Break point
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'B: p_fsc_rec.classification_category='|| p_fsc_rec.classification_category;
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
 END IF;
    --Bug fix 4774215 Case 1.Return Status must be initialized.
   P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
   --End of Bug fix 4774215 Case 1.
 --  arp_util_tax.debug('classification_type = ' || p_fsc_rec.classification_type);
 --  arp_util_tax.debug('regime_code = ' || p_fsc_rec.tax_regime_code);

 -- Validate parameters

 if p_fsc_rec.classification_category = 'PRODUCT_FISCAL_CLASS' then
 -- 1. Validate the Fiscal Classification Type has been associated to the regime or to parent above
 -- 2. Derive the Inventory Category classification.
 -- 3. Get the Item Category for the Product within the given organization

 -- Check if inventory is installed
  IF zx_global_Structures_pkg.g_inventory_installed_flag is NULL then

      Begin
        Select STATUS, DB_STATUS
          into l_status, l_db_status
          from fnd_product_installations
         where APPLICATION_ID = '401';
      Exception
        When OTHERS then
          -- Logging Infra: YK: 3/5
          -- The following original code is commented out.
          -- NULL;

          -- Logging Infra: YK: 3/5: Statement level
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'E: EXC: OTHERS: select fnd_product_installations: '|| SQLCODE||': '||SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
      End;

      IF (nvl(l_status,'N') = 'N' or  nvl(l_db_status,'N') = 'N') THEN
             zx_global_Structures_pkg.g_inventory_installed_flag := 'N';
      ELSE
             zx_global_Structures_pkg.g_inventory_installed_flag := 'Y';
      END IF;

   END IF;  -- check inventory installed

   IF zx_global_Structures_pkg.g_inventory_installed_flag = 'N' THEN
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      --p_error_buffer:='Inventory is not enabled';
      fnd_message.set_name('ZX','ZX_INV_NOT_ENABLED');

      p_fsc_rec.fsc_code:= null;

      -- Logging Infra: YK: 3/5: Statement level: "E" means "E"rror
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'E: SEL fnd_product_installations: inventory not enabled: l_status='|| l_status ||
                     ', l_db_status=' || l_db_status;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      --return;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

 -- 1:
    Open c_regime_assoc;
    fetch c_regime_assoc into l_reg_fscType_flag;

    -- Logging Infra: YK: 3/5: Break point
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_regime_assoc: fetched: l_reg_fsctype_flag=' || l_reg_fsctype_flag;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_regime_assoc%notfound then
      close c_regime_assoc;

      Open c_parent_regime_assoc;
      fetch c_parent_regime_assoc into l_reg_fscType_flag;

      -- Logging Infra: YK: 3/5: Break point
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_parent_regime_assoc: fetched: l_reg_fsctype_flag=' || l_reg_fsctype_flag;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
      END IF;

      if c_parent_regime_assoc%notfound then
        --p_return_status:=FND_API.G_RET_STS_ERROR;
        --p_error_buffer:='Regime for the given Fiscal Type is not valid ';
        fnd_message.set_name('ZX','ZX_REGIME_NOT_VALID');
        p_fsc_rec.fsc_code:= null;
        close c_parent_regime_assoc;
        --return;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    else
      close c_regime_assoc;
    end if;


 -- 2:
    Open c_inventory_set;
    fetch c_inventory_set into l_category_set_id;

    -- Logging Infra: YK: 3/5: Break point l_category_set_id
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_inventory_set: fetched: l_category_set_id=' || l_category_set_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_inventory_set%notfound then
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      p_fsc_rec.fsc_code:= null;
      --p_error_buffer:='Fiscal Type Code does not exits';
      fnd_message.set_name('ZX','ZX_FC_TYPE_NOT_EXIST');
      close c_inventory_set;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_inventory_set;
    end if;

    if l_category_set_id = null then
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      p_fsc_rec.fsc_code:= null;
      --p_error_buffer:='Foreign Key broken:Fiscal Type Code does not have Inventory Category Set associated';
      fnd_message.set_name('ZX','ZX_FC_INV_CAT_NOT_EXIST');

      -- Logging Infra: YK: 3/5: Error l_category_set_id is null
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'E: l_category_set_id is null: classification_type_code='|| p_fsc_rec.classification_type;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
      END IF;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    end if;

    Open c_inventory_structure;
    fetch c_inventory_structure into l_structure_id;

    if c_inventory_structure%notfound then
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      p_fsc_rec.fsc_code:= null;
      --p_error_buffer:='Foreign Key broken: Inventory Structure ID not found';
      fnd_message.set_name('ZX','ZX_FC_INV_STRUCT_NOT_EXIST');
      close c_inventory_structure;

      -- Logging Infra: YK: 3/5: c_inventory_structure notfound
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'E: CUR: c_inventory_structure: notfound: category_set_id='|| l_category_set_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
      END IF;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_inventory_structure;
    end if;

  -- 3:
    -- Get the Category Id for the Category code
    -- Get the allocation.

    Open c_category;
    fetch c_category into l_category_id;

    -- Logging Infra: YK: 3/5: Break point l_category_id
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_category: fetched: l_category_id=' || l_category_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_category%notfound then
      --p_error_buffer:= 'Fiscal Classification Code does not have an equivalent Item Category Code';
      fnd_message.set_name('ZX','ZX_ITEM_CAT_NOT_EXIST');
      p_fsc_rec.fsc_code:= null;
      --p_return_status:=FND_API.G_RET_STS_SUCCESS;
      close c_category;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_category;
    end if;


     Open c_item_category;
    fetch c_item_category into l_allocated_flag;

  -- Logging Infra: YK: 3/5: Break point l_category_id
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_item_category: fetched: l_allocated_flag=' || l_allocated_flag;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_item_category%notfound then
       close c_item_category;

       Open c_item_category_child;
       fetch c_item_category_child into l_allocated_flag;


       if c_item_category_child%notfound then

        fnd_message.set_name('ZX','ZX_FC_NOT_ALLOC_ENTITY_ID');
        p_fsc_rec.fsc_code:= null;
        close c_item_category_child;

        -- Logging Infra: YK: 3/5: c_item_category notfound
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'S: CUR: c_item_category: notfound: category_set_id='|| l_category_set_id ||
                        ', category_id='|| l_category_id ||
                         ', organization_id='|| p_fsc_rec.item_org_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

       --return;
        RAISE FND_API.G_EXC_ERROR;
     else
        p_fsc_rec.fsc_code:= p_fsc_rec.condition_value;
        close c_item_category_child;

       -- Logging Infra: YK: 3/5: c_item_category found
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'S: CUR: c_item_category: found: category_set_id='|| l_category_set_id ||
                        ', category_id='|| l_category_id ||
                        ', organization_id='|| p_fsc_rec.item_org_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
       END IF;

    end if; -- parent query

   else
      --p_return_status:=FND_API.G_RET_STS_SUCCESS;
      --p_error_buffer:='Fiscal Code is allocated to the Entity ID';
      p_fsc_rec.fsc_code:= p_fsc_rec.condition_value;
      close c_item_category;

      -- Logging Infra: YK: 3/5: c_item_category found
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'S: CUR: c_item_category: found: category_set_id='|| l_category_set_id ||
                       ', category_id='|| l_category_id ||
                       ', organization_id='|| p_fsc_rec.item_org_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
      END IF;

    end if;

 elsif (p_fsc_rec.classification_category = 'PARTY_FISCAL_CLASS' OR
       p_fsc_rec.classification_category = 'LEGAL_PARTY_FISCAL_CLASS')  then
 -- 1. Validate the Fiscal Classification Type has been associated to the regime or parent above
 -- 2. Derive the TCA Classification Category
 -- 3. Get the Party ID , Party Type for the PTP ID
 -- 4. If First Party Entity then Get LE information using xle view
 --    In not in LE, then check for Classifications Association in TCA model. When not found, If another
 --     classification code is associated, then return NULL. Otherwise, return G_MISS_CHAR.
 --
 -- 5. If Supplier or Supplier Site Entity then navigate to TCA model. When not found, If another classification
 --     code is associated, then return NULL. Otherwise, return G_MISS_CHAR.

 -- 1:
    Open c_regime_assoc;
    fetch c_regime_assoc into l_reg_fscType_flag;

    -- Logging Infra: YK: 3/5: Break point
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_regime_assoc: fetched: l_reg_fsctype_flag=' || l_reg_fsctype_flag;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_regime_assoc%notfound then
      close c_regime_assoc;

      Open c_parent_regime_assoc;
      fetch c_parent_regime_assoc into l_reg_fscType_flag;

      -- Logging Infra: YK: 3/5: Break point c_regime_assoc not found
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: c_regime_assoc: notfound: tax_regime=' || p_fsc_rec.tax_regime_code ||
                     ', classification_type='||p_fsc_rec.classification_type;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
      END IF;

      if c_parent_regime_assoc%notfound then
        --p_return_status:=FND_API.G_RET_STS_ERROR;
        --p_error_buffer:='Regime for the given Fiscal Type is not valid ';
        fnd_message.set_name('ZX','ZX_REGIME_NOT_VALID');
        p_fsc_rec.fsc_code:= null;
        close c_parent_regime_assoc;
        --return;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    else
      close c_regime_assoc;
    end if;

 -- 2:
    Open c_tca_class_category;
    fetch c_tca_class_category into l_tca_class_category_code;

    -- Logging Infra: YK: 3/3: Break point l_tca_class_category_code
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: CUR: c_tca_class_category: fetched: l_tca_class_category_code=' || l_tca_class_category_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_procedure_name,
                     l_log_msg);
    END IF;

    if c_tca_class_category%notfound then
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      --p_error_buffer:='Fiscal Type Code does not exits';
      fnd_message.set_name('ZX','ZX_FC_TYPE_NOT_EXIST');
      p_fsc_rec.fsc_code:= null;
      close c_tca_class_category;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_tca_class_category;
    end if;

    if l_tca_class_category_code = null then
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      --p_error_buffer:='Foreign Key broken:Fiscal Type Code does not have Class Category associated';
      fnd_message.set_name('ZX','ZX_FC_INV_CAT_NOT_EXIST');
      p_fsc_rec.fsc_code:= null;

       -- Logging Infra: YK: 3/5: Error l_tca_class_category_code is null
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'E: CUR: c_tca_class_category: l_tca_class_category_code is null: ' ||
                       'classification_type_code='|| p_fsc_rec.classification_type;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
      END IF;
      --return;
      RAISE FND_API.G_EXC_ERROR;
   end if;

 -- 3:
   --Bug 5373773
   IF p_fsc_rec.classification_category = 'LEGAL_PARTY_FISCAL_CLASS' THEN
     -- for party fiscal classification, le id passed in
     -- and the party_type code is known as FIRST_PARTY

     select party_id INTO l_party_id
       from xle_entity_profiles
      where legal_entity_id = p_fsc_rec.classified_entity_id;

     l_Party_Type_Code:= 'FIRST_PARTY';

   ELSE -- for party fiscal classification, ptp passed in
    Open c_party_tax_profile_id;
    fetch c_party_tax_profile_id into l_party_id, l_Party_Type_Code;

    -- Logging Infra: YK: 3/5: Break point l_party_id, l_Party_Type_Code
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: CUR: c_party_tax_profile_id: fetched: l_party_id=' || l_party_id ||
                   ', l_party_type_code='|| l_party_type_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_procedure_name,
                     l_log_msg);
    END IF;

    if c_party_tax_profile_id%notfound then
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      --p_error_buffer:='Party Tax Profile ID not found';
      fnd_message.set_name('ZX','ZX_PTP_ID_NOT_EXIST');
      p_fsc_rec.fsc_code:= null;
      close c_party_tax_profile_id;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_party_tax_profile_id;
    end if;
   END IF; -- 5373773 lxzhang

 -- Get the actual Classification Code (without parent concatenated).
    Open c_class_code;
    fetch c_class_code into l_class_code;

    -- Logging Infra: YK: 3/5: Break point l_class_code
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: CUR: c_class_code: fetched: l_class_code=' || l_class_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_procedure_name,
                     l_log_msg);
    END IF;

    if c_class_code%notfound then
      p_fsc_rec.fsc_code:= null;
      --p_return_status:=FND_API.G_RET_STS_SUCCESS;
      --p_error_buffer:='Parameter value does not have a corresponding Fiscal Code';
      fnd_message.set_name('ZX','ZX_FC_CODE_PARAM_NOT_EXIST');
      close c_class_code;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_class_code;
    end if;

-- 4: Supplier or Supplier Site
   if l_Party_Type_Code ='THIRD_PARTY_SITE' OR l_Party_Type_Code = 'THIRD_PARTY' THEN
      l_table_owner := 'ZX_PARTY_TAX_PROFILE';
      l_table_id:= p_fsc_rec.classified_entity_id;

      Open c_party_category;
      fetch c_party_category into l_allocated_flag,l_effective_from, l_effective_to;

      -- Logging Infra: YK: 3/5: Break point
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: c_party_category: fetched: l_allocated_flag_=' || l_allocated_flag ||
                     ', l_effective_from=' || l_effective_from ||
                     ', l_effective_to=' || l_effective_to;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
      END IF;

-- Begin Bug Fix 5528805

      if c_party_category%notfound then

         Open c_party_category_multi_level;
         fetch c_party_category_multi_level into l_allocated_flag,l_effective_from, l_effective_to;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'B: CUR: c_party_category_multi_level: fetched: l_allocated_flag_=' || l_allocated_flag ||
                     ', l_effective_from=' || l_effective_from ||
                     ', l_effective_to=' || l_effective_to;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
         END IF;


         if c_party_category_multi_level%notfound then
           l_c_party_category_not_found := 'Y';
         end if;

         Close c_party_category_multi_level;

      end if;

      if l_c_party_category_not_found = 'Y' then

-- End Bug Fix 5528805

        Open c_pty_fc_assgn_exists;
        fetch c_pty_fc_assgn_exists into l_allocated_flag;

        IF c_pty_fc_assgn_exists%NOTFOUND THEN
          p_fsc_rec.fsc_code := FND_API.G_MISS_CHAR;
          -- Logging Infra: YK: 3/5: c_party_category notfound
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'S: c_party_category: notfound: class_category=' || l_tca_class_category_code||
                         ', class_code='|| l_class_code ||
                         ', owner_table_name=' || l_table_owner ||
                         ', owner_table_id=' || l_table_id ||
                         ', p_fsc_rec.tax_determine_date=' || p_fsc_rec.tax_determine_date;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_procedure_name,
                          l_log_msg);
          END IF;
        ELSE
          p_fsc_rec.fsc_code:= null;
          -- Logging Infra: YK: 3/5: c_party_category notfound
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'S: c_party_category: notfound: another FC associated: class_category=' || l_tca_class_category_code||
                         ', class_code='|| l_class_code ||
                         ', owner_table_name=' || l_table_owner ||
                         ', owner_table_id=' || l_table_id ||
                         ', p_fsc_rec.tax_determine_date=' || p_fsc_rec.tax_determine_date;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_procedure_name,
                          l_log_msg);
          END IF;
        END IF;
        close c_pty_fc_assgn_exists;

        p_fsc_rec.effective_from :=l_effective_from;
        p_fsc_rec.effective_to :=l_effective_to;
        --p_return_status:=FND_API.G_RET_STS_SUCCESS;
        --p_error_buffer:='Fiscal Code is not allocated to the Entity ID';
        --fnd_message.set_name('ZX','ZX_FC_NOT_ALLOC_ENTITY_ID');
        close c_party_category;

        --return;
        --RAISE FND_API.G_EXC_ERROR;
      else
        p_fsc_rec.fsc_code:= p_fsc_rec.condition_value;
        p_fsc_rec.effective_from :=l_effective_from;
        p_fsc_rec.effective_to :=l_effective_to;
        --p_return_status:=FND_API.G_RET_STS_SUCCESS;
        --p_error_buffer:='Fiscal Code is allocated to the Entity ID';
        close c_party_category;

      end if;

   else
     -- Call Legal Entity API for Party
     -- If no Classfication in LE, check for "Tax Classifications" in the FC-TCA model

     l_table_owner := 'HZ_PARTIES';
     l_table_id:= l_party_id;

     -- Start : Code commented for Bug#7010655
     /*
     --5373773
     BEGIN
   	   SELECT party_tax_profile_id INTO l_ptp_id
	     FROM zx_party_tax_profile
	    where party_id = l_party_id
	     and party_type_code ='FIRST_PARTY';
	    EXCEPTION  WHEN OTHERS THEN
	      l_ptp_id := null;
	    END;
     --5373773 end
     */
     -- End : Code commented for Bug#7010655

     l_ptp_id := p_fsc_rec.classified_entity_id;     -- Added for Bug#7010655

     Open c_xle_activity_code;
     fetch c_xle_activity_code into l_allocated_flag,l_effective_from, l_effective_to;

      -- Logging Infra: YK: 3/5: Break point
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: c_xle_activity_code: fetched: l_allocated_flag_=' || l_allocated_flag ||
                     ', l_effective_from=' || l_effective_from ||
                     ', l_effective_to=' || l_effective_to;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
      END IF;

      if c_xle_activity_code%notfound then
        l_le_status := 'NOT_FOUND';
        close c_xle_activity_code;

        -- Logging Infra: YK: 3/5: c_party_category notfound
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'S: c_xle_activity_code: notfound: class_category=' || l_tca_class_category_code||
                       ', class_code='|| l_class_code ||
                       ', p_fsc_rec.tax_determine_date=' || p_fsc_rec.tax_determine_date;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
        END IF;

      ELSE
        l_le_status := 'FOUND';
        p_fsc_rec.fsc_code:= p_fsc_rec.condition_value;
        p_fsc_rec.effective_from :=l_effective_from;
        p_fsc_rec.effective_to :=l_effective_to;
        close c_xle_activity_code;
      end if;

     -- Logging Infra: YK: 3/5/2004: Open issue
     -- After calling legal entitity API for party list output value here...
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'B: l_table_owner=' || l_table_owner ||
                    ', l_table_id=' || l_table_id ||
                    ', l_le_status=' || l_le_status;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
     END IF;

     if l_le_status = 'NOT_FOUND' then
       l_table_owner := 'ZX_PARTY_TAX_PROFILE';
       l_table_id := l_ptp_id;

       Open c_party_category;
       fetch c_party_category into l_allocated_flag,l_effective_from, l_effective_to;

       -- YK: 3/3: Break point: may not be necessary
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'B: CUR: c_party_category: fetched: l_allocated_flag=' || l_allocated_flag ||
                        ', l_effective_from=' || l_effective_from ||
                        ', l_effective_to=' || l_effective_to;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
       END IF;

-- Begin Bug Fix 5528805

      if c_party_category%notfound then

         Open c_party_category_multi_level;
         fetch c_party_category_multi_level into l_allocated_flag,l_effective_from, l_effective_to;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'B: CUR: c_party_category_multi_level: fetched: l_allocated_flag_=' || l_allocated_flag ||
                     ', l_effective_from=' || l_effective_from ||
                     ', l_effective_to=' || l_effective_to;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
         END IF;


         if c_party_category_multi_level%notfound then
           l_c_party_category_not_found := 'Y';
         end if;

         Close c_party_category_multi_level;

      end if;

      if l_c_party_category_not_found = 'Y' then

-- End Bug Fix 5528805

        l_table_owner := 'HZ_PARTIES';
        l_table_id := l_party_id;
        open c_xle_fc_assgn_exists;
        fetch c_xle_fc_assgn_exists into l_allocated_flag;

        if c_xle_fc_assgn_exists%notfound then
           l_le_other_fc_status := 'NOT_FOUND';
        else
           l_le_other_fc_status := 'FOUND';
        end if;

        close c_xle_fc_assgn_exists;

        if l_le_other_fc_status = 'FOUND' then

         p_fsc_rec.fsc_code:= null;
         -- Logging Infra: YK: 3/4: c_party_category notfound
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'S: CUR: c_party_category: notfound: other FC found in LE table: class_category=' || l_tca_class_category_code||
                        ', class_code='|| l_class_code ||
                        ', owner_table_name=' || l_table_owner ||
                        ', owner_table_id=' || l_table_id ||
                        ', p_fsc_rec.tax_determine_date=' || p_fsc_rec.tax_determine_date;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
         END IF;

        elsif l_le_other_fc_status = 'NOT_FOUND' then

          l_table_owner := 'ZX_PARTY_TAX_PROFILE';
          l_table_id := l_ptp_id;
          Open c_pty_fc_assgn_exists;
          fetch c_pty_fc_assgn_exists into l_allocated_flag;
          IF c_pty_fc_assgn_exists%NOTFOUND THEN
            p_fsc_rec.fsc_code := FND_API.G_MISS_CHAR;
            -- Logging Infra: YK: 3/4: c_party_category notfound
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'S: CUR: c_party_category: notfound: class_category=' || l_tca_class_category_code||
                           ', class_code='|| l_class_code ||
                           ', owner_table_name=' || l_table_owner ||
                           ', owner_table_id=' || l_table_id ||
                           ', p_fsc_rec.tax_determine_date=' || p_fsc_rec.tax_determine_date;
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                            G_MODULE_NAME || l_procedure_name,
                            l_log_msg);
            END IF;
          ELSE
            p_fsc_rec.fsc_code:= null;
            -- Logging Infra: YK: 3/4: c_party_category notfound
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'S: CUR: c_party_category: notfound: other FC found in HZ table: class_category=' || l_tca_class_category_code||
                           ', class_code='|| l_class_code ||
                           ', owner_table_name=' || l_table_owner ||
                           ', owner_table_id=' || l_table_id ||
                           ', p_fsc_rec.tax_determine_date=' || p_fsc_rec.tax_determine_date;
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                            G_MODULE_NAME || l_procedure_name,
                            l_log_msg);
            END IF;
          END IF;
          close c_pty_fc_assgn_exists;

        end if; -- end check for l_le_other_fc_status

         p_fsc_rec.effective_from := null;
         p_fsc_rec.effective_to := null;
         --p_return_status:=FND_API.G_RET_STS_SUCCESS;
         --p_error_buffer:='Fiscal Code is not allocated to the Entity ID';
         --fnd_message.set_name('ZX','ZX_FC_NOT_ALLOC_ENTITY_ID');
         close c_party_category;

         --return;
         --RAISE FND_API.G_EXC_ERROR;
       else
         p_fsc_rec.fsc_code:= p_fsc_rec.condition_value;
         p_fsc_rec.effective_from :=l_effective_from;
         p_fsc_rec.effective_to :=l_effective_to;
         --p_return_status:=FND_API.G_RET_STS_SUCCESS;
         --p_error_buffer:='Fiscal Code is allocated to the Entity ID';
         close c_party_category;

       end if;

     end if;

   end if;

 elsif p_fsc_rec.classification_category = 'TRX_FISCAL_CLASS' then
   -- 1. Validate Fiscal Type exists
   -- 2. Validate the Fiscal Classification Type has been associated to the regime
   -- 3. Get the Classification code for the passed in Concatenated code.
   -- 4. Get the fiscal code associated to the business category.

    Open c_classification_type_code;
    fetch c_classification_type_code into l_classification_type_code;

    -- Logging Infra: YK: 3/5: Break point: l_classification_type_code
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_classification_type_code: fetched: l_classification_type_code=' || l_classification_type_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_classification_type_code%notfound then
      p_fsc_rec.fsc_code:= null;
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      --p_error_buffer:='Fiscal Type Code does not exists';
      fnd_message.set_name('ZX','ZX_FC_TYPE_NOT_EXIST');
      close c_classification_type_code;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_classification_type_code;
    end if;


    Open c_regime_assoc;
    fetch c_regime_assoc into l_reg_fscType_flag;

    -- Logging Infra: YK: 3/5: Break point
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_regime_assoc: fetched: l_reg_fsctype_flag=' || l_reg_fsctype_flag;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_regime_assoc%notfound then
      close c_regime_assoc;
      Open c_parent_regime_assoc;
      fetch c_parent_regime_assoc into l_reg_fscType_flag;

      -- Logging Infra: YK: 3/5: Break point
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_parent_regime_assoc: fetched: l_reg_fsctype_flag=' || l_reg_fsctype_flag;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
      END IF;


      if c_parent_regime_assoc%notfound then
        p_fsc_rec.fsc_code:= null;
        --p_return_status:=FND_API.G_RET_STS_ERROR;
        --p_error_buffer:='Regime for the given Fiscal Type is not valid ';
        fnd_message.set_name('ZX','ZX_REGIME_NOT_VALID');
        close c_parent_regime_assoc;
        --return;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    else
      close c_regime_assoc;
    end if;


    Open c_trxbizcat_fiscalclass;
    fetch c_trxbizcat_fiscalclass into l_allocated_flag,l_effective_from, l_effective_to;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_trxbizcat_fiscalclass: fetched: l_allocated_flag=' || l_allocated_flag ||
                       ', l_effective_from=' || l_effective_from ||
                       ', l_effective_to=' || l_effective_to;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_trxbizcat_fiscalclass%notfound then
      -- Check if association has been to a parent Trx Biz Categgory
        close c_trxbizcat_fiscalclass;

        Open c_parent_trxbizcat_fiscalclass;
        fetch c_parent_trxbizcat_fiscalclass into l_allocated_flag,l_effective_from, l_effective_to;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_parent_trxbizcat_fiscalclass: fetched: l_allocated_flag=' || l_allocated_flag ||
                       ', l_effective_from=' || l_effective_from ||
                       ', l_effective_to=' || l_effective_to;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
        END IF;

	    if c_parent_trxbizcat_fiscalclass%notfound then
	       p_fsc_rec.fsc_code:= null;
	       p_fsc_rec.effective_from := null;
	       p_fsc_rec.effective_to := null;
	       fnd_message.set_name('ZX','ZX_FC_NOT_ALLOC_ENTITY_ID');
	       close c_parent_trxbizcat_fiscalclass;
	       RAISE FND_API.G_EXC_ERROR;
	    else
	       p_fsc_rec.effective_from :=l_effective_from;
	       p_fsc_rec.effective_to :=l_effective_to;
	       p_fsc_rec.fsc_code:= p_fsc_rec.condition_value;
	       close c_parent_trxbizcat_fiscalclass;
	    end if;

    else
       p_fsc_rec.effective_from :=l_effective_from;
       p_fsc_rec.effective_to :=l_effective_to;
       p_fsc_rec.fsc_code:= p_fsc_rec.condition_value;
       close c_trxbizcat_fiscalclass;
    end if;

  else
      --p_error_buffer:='Classification Category not supported by this procedure';
      fnd_message.set_name('ZX','ZX_FC_CATEG_NOT_SUPPORTED');

       -- Logging Infra: YK: 3/5:
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'E: unspported category: p_fsc_rec.classification_category=' || p_fsc_rec.classification_category;
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_procedure_name,
                     l_log_msg);
     END IF;

     RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Logging Infra: YK: 3/5: Put output value here
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'R: p_fsc_rec.effective_from=' ||l_effective_from ||
                 ', p_fsc_rec.effective_to=' ||l_effective_to ||
                 ', p_fsc_rec.fsc_code=' || p_fsc_rec.condition_value;
    l_log_msg := l_log_msg || 'get_fiscal_classification(-)';
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME || l_procedure_name,
                   l_log_msg);
  END IF;

EXCEPTION
   WHEN INVALID_CURSOR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

      if c_regime_assoc%isopen then close c_regime_assoc; end if;
      if c_parent_regime_assoc%isopen then close c_parent_regime_assoc; end if;
      if c_inventory_set%isopen then close c_inventory_set; end if;
      if c_inventory_structure%isopen then close c_inventory_structure; end if;
      if c_category%isopen then close c_category; end if;
      if c_item_category%isopen then close c_item_category;end if;
      if c_item_category_child%isopen then close c_item_category;end if;
      if c_tca_class_category%isopen then close c_tca_class_category; end if;
      if c_party_tax_profile_id%isopen then close c_party_tax_profile_id; end if;
      if c_class_code%isopen then close c_class_code; end if;
      if c_party_category%isopen then close c_party_category; end if;
      if c_party_category_multi_level%isopen then close c_party_category_multi_level; end if;
      if c_classification_type_code%isopen then close c_classification_type_code; end if;
      if c_trxbizcat_fiscalclass%isopen then close c_trxbizcat_fiscalclass; end if;

      -- Logging Infra: YK: 3/5:
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      if c_regime_assoc%isopen then close c_regime_assoc; end if;
      if c_parent_regime_assoc%isopen then close c_parent_regime_assoc; end if;
      if c_inventory_set%isopen then close c_inventory_set; end if;
      if c_inventory_structure%isopen then close c_inventory_structure; end if;
      if c_category%isopen then close c_category; end if;
      if c_item_category%isopen then close c_item_category; end if;
      if c_item_category_child%isopen then close c_item_category;end if;
      if c_tca_class_category%isopen then close c_tca_class_category; end if;
      if c_party_tax_profile_id%isopen then close c_party_tax_profile_id; end if;
      if c_class_code%isopen then close c_class_code; end if;
      if c_party_category%isopen then close c_party_category; end if;
      if c_party_category_multi_level%isopen then close c_party_category_multi_level; end if;
      if c_classification_type_code%isopen then close c_classification_type_code; end if;
      if c_trxbizcat_fiscalclass%isopen then close c_trxbizcat_fiscalclass; end if;

      -- Logging Infra: YK: 3/5:
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
      END IF;


   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

      if c_regime_assoc%isopen then close c_regime_assoc; end if;
      if c_parent_regime_assoc%isopen then close c_parent_regime_assoc; end if;
      if c_inventory_set%isopen then close c_inventory_set; end if;
      if c_inventory_structure%isopen then close c_inventory_structure; end if;
      if c_category%isopen then close c_category; end if;
      if c_item_category%isopen then close c_item_category; end if;
      if c_item_category_child%isopen then close c_item_category;end if;
      if c_tca_class_category%isopen then close c_tca_class_category; end if;
      if c_party_tax_profile_id%isopen then close c_party_tax_profile_id; end if;
      if c_class_code%isopen then close c_class_code; end if;
      if c_party_category%isopen then close c_party_category; end if;
      if c_party_category_multi_level%isopen then close c_party_category_multi_level; end if;
      if c_classification_type_code%isopen then close c_classification_type_code; end if;
      if c_trxbizcat_fiscalclass%isopen then close c_trxbizcat_fiscalclass; end if;

      -- Logging Infra: YK: 3/5:
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
      END IF;

END GET_FISCAL_CLASSIFICATION;


Procedure GET_PROD_TRX_CATE_VALUE (
             p_fsc_cat_rec      IN OUT NOCOPY ZX_TCM_CONTROL_PKG.ZX_CATEGORY_CODE_INFO_REC,
             p_return_status    OUT NOCOPY VARCHAR2)
IS

   cursor c_classification_code is
    select Classification_Code,
           classification_code_level,
           segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           effective_from,
           effective_to
    from Zx_Fc_Codes_Denorm_B
    where Classification_Type_Categ_Code = p_fsc_cat_rec.classification_category
    and classification_type_code = p_fsc_cat_rec.classification_type
    and concat_classif_code = p_fsc_cat_rec.parameter_value
    and p_fsc_cat_rec.tax_determine_date between effective_from and nvl(effective_to, p_fsc_cat_rec.tax_determine_date);

    cursor c_delimiter is
     select delimiter
     from zx_fc_types_b
     where Classification_Type_Categ_Code = p_fsc_cat_rec.classification_category
     and   classification_type_code = p_fsc_cat_rec.classification_type;

    l_Classification_Code zx_fc_codes_b.Classification_Code%type;
    l_segment1 Zx_Fc_Codes_Denorm_B.segment1%type;
    l_segment2 Zx_Fc_Codes_Denorm_B.segment1%type;
    l_segment3 Zx_Fc_Codes_Denorm_B.segment1%type;
    l_segment4 Zx_Fc_Codes_Denorm_B.segment1%type;
    l_segment5 Zx_Fc_Codes_Denorm_B.segment1%type;
    l_effective_from date;
    l_effective_to date;
    l_classification_code_level Zx_Fc_Codes_Denorm_B.classification_code_level%type;
    l_delimiter zx_fc_types_b.delimiter%type;
    l_unconcatenated_code Zx_Fc_Codes_Denorm_B.concat_classif_code%type;

    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := 'get_prod_trx_cate_value';
    l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

 BEGIN
  -- Logging Infra: 3/5: YK: Setting up runtime level
 G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 -- Logging Infra: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(+)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
 END IF;

--  arp_util_tax.debug('in GET_PROD_TRX_CATE_VALUE');
-- need to hard code return value here
   p_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_fsc_cat_rec.classification_category = 'TRX_GENERIC_CLASSIFICATION' or
     p_fsc_cat_rec.classification_category = 'PRODUCT_GENERIC_CLASSIFICATION' or
     p_fsc_cat_rec.classification_category = 'DOCUMENT'then

    Open c_delimiter;
    fetch c_delimiter into l_delimiter;

    -- Logging Infra: YK: 3/5: Break point
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_delimiter: fetched: l_delimiter=' || l_delimiter;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_delimiter%notfound then
      p_return_status:=FND_API.G_RET_STS_ERROR;
      --p_error_buffer:='Classification Type does not exist';
      fnd_message.set_name('ZX','ZX_FC_TYPE_NOT_EXIST');
      close c_delimiter;

      -- Logging Infra: YK: 3/5: c_delimiter notfound
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'E: CUR: c_delimiter: notfound: Classification_Type_Categ_Code='
                      || p_fsc_cat_rec.classification_category ||
                      ', classification_type_code=' || p_fsc_cat_rec.classification_type;
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
      END IF;
      --return;
      RAISE FND_API.G_EXC_ERROR;
    else
      close c_delimiter;
    end if;

   if p_fsc_cat_rec.parameter_value IS NOT NULL then
    -- YK: 3/5 What if l_delimiter is NULL?

    Open c_classification_code;
    fetch c_classification_code into
          l_Classification_Code,
          l_classification_code_level,
          l_segment1,
          l_segment2,
          l_segment3,
          l_segment4,
          l_segment5,
          l_effective_from,
          l_effective_to;

    -- Logging Infra: YK: 3/5: Break point
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_classification_code: fetched: l_classiciation_code=' || l_classification_code ||
                       ', l_classification_code_level=' || l_classification_code_level ||
                       ', l_segment1=' || l_segment1 ||
                       ', l_segment2=' || l_segment2 ||
                       ', l_segment3=' || l_segment3 ||
                       ', l_segment4=' || l_segment4 ||
                       ', l_segment5=' || l_segment5;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
    END IF;

    if c_classification_code%notfound then
      p_fsc_cat_rec.condition_value := Null;
      p_fsc_cat_rec.effective_from := Null;
      p_fsc_cat_rec.effective_to := Null;
      p_return_status:=FND_API.G_RET_STS_SUCCESS;
      close c_classification_code;

      -- Logging Infra: YK: 3/5: c_classification_code notfound
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'S: CUR: c_classification_code: notfound: Classification_Type_Categ_Code='
                      || p_fsc_cat_rec.classification_category ||
                      ', classification_type_code=' || p_fsc_cat_rec.classification_type ||
                      ', concat_classif_code=' || p_fsc_cat_rec.parameter_value ||
                      ', p_fsc_cat_rec.tax_determine_date=' || p_fsc_cat_rec.tax_determine_date;
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
      END IF;
      --return;
      RAISE FND_API.G_EXC_ERROR;

    else
      if p_fsc_cat_rec.condition_subclass='1' then
        p_fsc_cat_rec.condition_value :=l_segment1;

      elsif p_fsc_cat_rec.condition_subclass='2' then
        p_fsc_cat_rec.condition_value :=l_segment1 || l_delimiter || l_segment2;

      elsif p_fsc_cat_rec.condition_subclass='3' then
        p_fsc_cat_rec.condition_value :=l_segment1 || l_delimiter || l_segment2 || l_delimiter || l_segment3;

      elsif p_fsc_cat_rec.condition_subclass='4' then
        p_fsc_cat_rec.condition_value := l_segment1 || l_delimiter || l_segment2 || l_delimiter || l_segment3 || l_delimiter || l_segment4;

      elsif p_fsc_cat_rec.condition_subclass='5' then
        p_fsc_cat_rec.condition_value :=l_segment1 || l_delimiter || l_segment2 || l_delimiter || l_segment3 || l_delimiter || l_segment4 || l_delimiter || l_segment5;

      end if;

      p_fsc_cat_rec.effective_from :=l_effective_from;
      p_fsc_cat_rec.effective_to :=l_effective_to;
      p_return_status:=FND_API.G_RET_STS_SUCCESS;
      --p_error_buffer:='Classification Code found';
      close c_classification_code;

      -- Logging Infra: YK:3/5: Break point for l_delimiter
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: p_fsc_cat_rec.condition_subclass=' || p_fsc_cat_rec.condition_subclass ||
                       ', p_fsc_cat_rec.condition_value=' || p_fsc_cat_rec.condition_value ||
                       ', p_fsc_cat_rec.effective_from=' || p_fsc_cat_rec.effective_from ||
                       ', p_fsc_cat_rec.effective_to=' || p_fsc_cat_rec.effective_to;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
      END IF;


    end if;
    else
      -- value is null
      p_fsc_cat_rec.condition_value := null;
      p_fsc_cat_rec.effective_from := Null;
      p_fsc_cat_rec.effective_to := Null;
      p_return_status:=FND_API.G_RET_STS_SUCCESS;

    end if;

 else
      --p_return_status:=FND_API.G_RET_STS_ERROR;
      --p_error_buffer:='Classification Category not supported by this procedure';
      fnd_message.set_name('ZX','ZX_FC_CATEG_NOT_SUPPORTED');
      p_return_status:=FND_API.G_RET_STS_ERROR;

     -- Logging Infra: YK: 3/5:
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'E: unspported category: p_fsc_cat_rec.classification_category= '
                    || p_fsc_cat_rec.classification_category;
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_procedure_name,
                     l_log_msg);
     END IF;
     RAISE FND_API.G_EXC_ERROR;

  end if;

  -- Logging Infra: YK: 3/5: Procedure level message
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'E: unspported category: p_fsc_cat_rec.classification_category= '
               || p_fsc_cat_rec.classification_category;
     l_log_msg := l_log_msg || ' get_prod_trx_cate_value(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;
EXCEPTION
   WHEN INVALID_CURSOR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

      if c_classification_code%isopen then close c_classification_code; end if;
      if c_delimiter%isopen then close c_delimiter; end if;

      -- Logging Infra: YK: 3/5:
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      SQLCODE || ': ' || SQLERRM);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      p_fsc_cat_rec.condition_value := Null;
      p_fsc_cat_rec.effective_from := Null;
      p_fsc_cat_rec.effective_to := Null;

      if c_classification_code%isopen then close c_classification_code; end if;
      if c_delimiter%isopen then close c_delimiter; end if;

      -- Logging Infra: YK: 3/5:
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      SQLCODE || ': ' || SQLERRM);
      END IF;

   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

      if c_classification_code%isopen then close c_classification_code; end if;
      if c_delimiter%isopen then close c_delimiter; end if;

      -- Logging Infra: YK: 3/5:
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      SQLCODE || ': ' || SQLERRM);
      END IF;

END GET_PROD_TRX_CATE_VALUE;

/********************************************************************************
 *                   Private Procedures Specification                           *
 ********************************************************************************/

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Registration_Tax                                           *
 *  Purpose : Get Tax Registration Information of Tax Regime, Tax, Jurisdiction *
 *            level.                                                            *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Registration_Tax
             (p_ptp_id                IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
              p_tax_regime_code       IN   ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
              p_tax                   IN   ZX_TAXES_B.TAX%TYPE,
              p_jurisdiction_code     IN   ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
	      p_getone                OUT  NOCOPY NUMBER);

/*******************************************************************************
 *                                                                             *
 *  Name    : Do_Get_Sup_Site                                                  *
 *  Purpose : Get Tax Registration Information from sup sites                  *
 *                                                                             *
 *******************************************************************************/

PROCEDURE  Do_Get_Sup_Site
             (p_party_tax_profile_id  IN   NUMBER,
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id       IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
              p_getone                OUT  NOCOPY NUMBER);

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Reg_Site_Uses                                              *
 *  Purpose : Get Tax Registration Information of Sites.                        *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Reg_Site_Uses
             (p_party_tax_profile_id  IN   NUMBER,
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id       IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_site_use_id           IN   HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
	      p_getone                OUT  NOCOPY NUMBER);

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Registration_Accts                                         *
 *  Purpose : Get Tax Registration Information of Accounts.                     *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Registration_Accts
             (p_party_tax_profile_id  IN   NUMBER,
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
			  p_getone                OUT  NOCOPY NUMBER);

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Registration_Party                                         *
 *  Purpose : Get Tax Registration Information of Party.                        *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Registration_Party
             (p_party_tax_profile_id  IN   NUMBER,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
                          p_getone                OUT  NOCOPY NUMBER);

/********************************************************************************
 *                          Private Procedures                                  *
 ********************************************************************************/

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Registration_Tax                                           *
 *  Purpose : Get Tax Registration Information of Tax Regime, Tax, Jurisdiction *
 *            level.                                                            *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Registration_Tax
             (p_ptp_id                IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
              p_tax_regime_code       IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
              p_tax                   IN  ZX_TAXES_B.TAX%TYPE,
              p_jurisdiction_code     IN  ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE,
              p_tax_determine_date    IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT NOCOPY VARCHAR2,
              x_ret_record_level      OUT NOCOPY VARCHAR2,
	      p_getone                OUT NOCOPY NUMBER)
IS

  -----------------------------
  -- Local variables definition
  -----------------------------
  l_ptp_type_code            zx_party_tax_profile.party_type_code%type;

  -- Logging Infra
  l_procedure_name   CONSTANT VARCHAR2(30) := 'Do_Get_Registration_Tax';
  l_log_msg          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  -----------------------------------------------------------------
  -- Get the Tax Registration Information
  -- Tax Registration should be valid on the Tax Determination Date
  -----------------------------------------------------------------

  CURSOR c_get_registration_tax (c_party_tax_profile_id NUMBER,
                                 c_tax_regime_code ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
								 c_tax ZX_TAXES_B.TAX%TYPE,
                                 c_jurisdiction_code ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE,
                                 c_tax_determine_date  ZX_LINES.TAX_DETERMINE_DATE%TYPE)
  IS
  SELECT 'N' dummy_flag,
         reg.Registration_id,
         reg.Registration_Type_Code,
         reg.Registration_Number,
         reg.Validation_Rule,
         reg.Tax_Authority_id,
         reg.Rep_Tax_Authority_id,
         reg.Coll_Tax_Authority_id,
         reg.Rounding_Rule_Code,
         reg.Tax_Jurisdiction_Code,
         reg.Self_Assess_Flag,
         reg.Registration_Status_Code,
         reg.Registration_Source_Code,
         reg.Registration_Reason_Code,
         reg.Party_Tax_Profile_id,
         reg.Tax,
         reg.Tax_Regime_Code,
         reg.Inclusive_Tax_Flag,
         -- reg.Has_Tax_Exemptions_Flag,
         reg.Effective_From,
         reg.Effective_To,
         reg.Rep_Party_Tax_Name,
         reg.Legal_Registration_id,
         reg.Default_Registration_Flag,
         reg.Bank_id,
         reg.Bank_Branch_id,
         reg.Bank_Account_Num,
         reg.Legal_Location_id,
         reg.Record_Type_Code,
         reg.Request_id,
         reg.Program_Application_id,
         reg.Program_id,
         reg.Program_Login_id,
         reg.ACCOUNT_SITE_ID,
         -- reg.Site_Use_id,
         null, -- reg.Geo_Type_Classification_Code,
         reg.ACCOUNT_ID,
         reg.tax_classification_code,
         reg.attribute1,
         reg.attribute2,
         reg.attribute3,
         reg.attribute4,
         reg.attribute5,
         reg.attribute6,
         reg.attribute7,
         reg.attribute8,
         reg.attribute9,
         reg.attribute10,
         reg.attribute11,
         reg.attribute12,
         reg.attribute13,
         reg.attribute14,
         reg.attribute15,
         reg.attribute_category,
         ptp.party_type_code,
         ptp.supplier_flag,
         ptp.customer_flag,
         ptp.site_flag,
         ptp.process_for_applicability_flag,
         ptp.rounding_level_code,
         ptp.withholding_start_date,
         ptp.allow_awt_flag,
         ptp.use_le_as_subscriber_flag,
         ptp.legal_establishment_flag,
         ptp.first_party_le_flag,
         ptp.reporting_authority_flag,
         ptp.collecting_authority_flag,
         ptp.provider_type_code,
         ptp.create_awt_dists_type_code,
         ptp.create_awt_invoices_type_code,
         ptp.allow_offset_tax_flag,
         ptp.effective_from_use_le,
         ptp.party_id,
         ptp.rep_registration_number
    FROM zx_registrations  reg,
         zx_party_tax_profile  ptp
   WHERE reg.party_tax_profile_id = c_party_tax_profile_id
     AND reg.party_tax_profile_id = ptp.party_tax_profile_id
     AND nvl(reg.tax_regime_code,1)  = nvl(c_tax_regime_code,1)
     AND nvl(reg.tax,nvl(c_tax,1)) = nvl(c_tax,1)
     AND nvl(reg.tax_jurisdiction_code,nvl(c_jurisdiction_code,1)) = nvl(c_jurisdiction_code,1)
     AND  c_tax_determine_date >= reg.effective_from
     AND (c_tax_determine_date <= reg.effective_to OR reg.effective_to IS NULL);

 -- dario1
  CURSOR c_ptp_type (c_ptp_id  number) IS
    SELECT party_type_code
      FROM zx_party_tax_profile
     WHERE party_tax_profile_id = c_ptp_id;

  -- variables for caching
   L_TAX_REGIME_CODE         	ZX_REGIMES_B.TAX_REGIME_CODE%TYPE;
   L_TAX                	ZX_TAXES_B.TAX%TYPE;
   L_JURISDICTION_CODE  	ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE;
   L_INDEX                 	BINARY_INTEGER;
   DUMMY_REGISTRATION_REC 	ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC;

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Initialize return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'Parameters ';
    l_log_msg :=  l_log_msg||' p_ptp_id: '||to_char(p_ptp_id);
    l_log_msg :=  l_log_msg||' p_tax_regime_code: '||p_tax_regime_code;
    l_log_msg :=  l_log_msg||' p_tax: '||p_tax;
    l_log_msg :=  l_log_msg||' p_jurisdiction_code: '||p_jurisdiction_code;
    l_log_msg :=  l_log_msg||' p_tax_determine_date: '||to_char(p_tax_determine_date,'DD-MON-RRRR');
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  l_tax_regime_code := nvl(p_tax_regime_code, c_tax_regime_code_dummy);
  l_tax   := nvl(p_tax, c_tax_dummy);
  l_jurisdiction_code := nvl(p_jurisdiction_code, c_jurisdiction_code_dummy);

  l_index := DBMS_UTILITY.get_hash_value(to_char(p_ptp_id)||l_tax_regime_code||l_tax||l_jurisdiction_code,1,8192);

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'l_index = '||l_index);
  END IF;

  IF ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl.exists(l_index) THEN  -- found in cache

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'Record found in cache for l_index = '||l_index||
                                                            ' Dummy_flag = '||ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl(l_index).dummy_flag);
      END IF;

     IF ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl(l_index).dummy_flag = 'Y' then

         p_getone:=0;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The same combination already searched previously with an unsuccessful hit' ;
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

     ELSE

         x_get_registration_rec := ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl(l_index);

         -- check the date effectiveness of the record found in cahce
         IF p_tax_determine_date  >=  x_get_registration_rec.effective_from
         AND p_tax_determine_date  <=  nvl(x_get_registration_rec.effective_to,p_tax_determine_date)
         THEN

            p_getone:=1;
            -- Bug#5520167- set status to SUCCESS as a record
            -- is found in cache structure and not dummy
            --
            x_return_status := FND_API.G_RET_STS_SUCCESS;


            IF x_get_registration_rec.tax_jurisdiction_code is NOT NULL then
                x_ret_record_level := 'JURISDICTION';
            ELSIF x_get_registration_rec.tax_jurisdiction_code is NULL
              AND x_get_registration_rec.tax is NOT NULL then
                x_ret_record_level := 'TAX';
            ELSIF x_get_registration_rec.tax_regime_code is NOT NULL
              AND x_get_registration_rec.tax is NULL
              AND x_get_registration_rec.tax_jurisdiction_code is NULL then
                 x_ret_record_level := 'TAX_REGIME';
            ELSE
                  x_ret_record_level := 'NULL_REGIME';
            END IF;
         END IF;
     END IF;  -- dummy flag

  ELSE  -- not found in cache

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'Record NOT found in cache for l_index = '||l_index);
      END IF;

      p_getone := 0;
           --  If the parameters 'Tax' and 'Jurisdiction' are null, and 'Regime' is not null then look for Regime evel.
         IF (p_tax_regime_code IS NOT NULL AND p_tax IS NULL
                                           AND p_jurisdiction_code IS NULL) THEN
             x_ret_record_level := 'TAX_REGIME';
             OPEN c_get_registration_tax(p_ptp_id
	                                ,p_tax_regime_code
	    		   		,NULL
	    				,NULL
	    				,p_tax_determine_date);
         --  If the parameters for Jurisdiction is null, and Regime and Tax are not null then look for Tax level.
         ELSIF (p_tax_regime_code IS NOT NULL AND p_tax IS NOT NULL
                                              AND p_jurisdiction_code IS NULL) THEN
             x_ret_record_level := 'TAX';
             OPEN c_get_registration_tax(p_ptp_id
          	  			,p_tax_regime_code
	                                ,p_tax
	    				,NULL
	    				,p_tax_determine_date);
         --  If the parameters for Jurisdiction, Regime, and Tax are not null then look for Jurisdiction level.
         ELSIF (p_tax_regime_code IS NOT NULL AND p_tax IS NOT NULL
                                             AND p_jurisdiction_code IS NOT NULL) THEN
             x_ret_record_level := 'JURISDICTION';
             OPEN c_get_registration_tax(p_ptp_id
          				,p_tax_regime_code
	                                ,p_tax
	    				,p_jurisdiction_code
	    				,p_tax_determine_date);

         ELSIF (p_tax_regime_code IS NULL AND p_tax IS NULL
                                         AND p_jurisdiction_code IS NULL) THEN
             x_ret_record_level := 'NULL_REGIME';
             OPEN c_get_registration_tax(p_ptp_id
	                                ,NULL
	    		   		,NULL
	    				,NULL
	    				,p_tax_determine_date);

         END IF; -- Check p tax regime code is not null and tax and jur are null

         FETCH c_get_registration_tax INTO x_get_registration_rec;
         -- Got registration
         IF c_get_registration_tax%NOTFOUND THEN
            p_getone := 0;
            -- Bug#5520167- set flag to upper case Y
            DUMMY_REGISTRATION_REC.DUMMY_FLAG := 'Y';

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'Creating a dummy Record  for l_index = '||l_index);
            END IF;


            -- This assignment statement is to mark that we already searched the database for
            -- this combination of ptp_id, tax_regime_code, Tax, tax_jurisdiction_code and
            -- did not find a record. When we look for a registration record for the same
            -- combination for another transaction, we will avoid unnecessary hit against
            -- the databse just because a record did not exist in the cache.


            ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl(l_index) := DUMMY_REGISTRATION_REC;

         ELSE
            p_getone:=1;
            x_return_status := FND_API.G_RET_STS_SUCCESS;

            l_index := DBMS_UTILITY.get_hash_value(to_char(p_ptp_id)||
                                 nvl(x_get_registration_rec.tax_regime_code,c_tax_regime_code_dummy)||
                                 nvl(x_get_registration_rec.tax,c_tax_dummy)||
                                 nvl(x_get_registration_rec.tax_jurisdiction_code,c_jurisdiction_code_dummy),1,8192);

             ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl(l_index) := x_get_registration_rec;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Keys in the Index: ';
               l_log_msg :=  l_log_msg||' p_ptp_id: '||to_char(p_ptp_id);
               l_log_msg :=  l_log_msg||' tax_regime_code: '||nvl(x_get_registration_rec.tax_regime_code,c_tax_regime_code_dummy);
               l_log_msg :=  l_log_msg||' p_tax: '||nvl(x_get_registration_rec.tax,c_tax_dummy);
               l_log_msg :=  l_log_msg||' p_jurisdiction_code: '||nvl(x_get_registration_rec.tax_jurisdiction_code,c_jurisdiction_code_dummy);
               l_log_msg :=  l_log_msg||' l_index: '||to_char(l_index);
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;


         END IF;   -- Got registrations
         CLOSE c_get_registration_tax;

    END IF; -- found in cache

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;
  -- Fails
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
    FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Error Message: '||SQLERRM;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
END Do_Get_Registration_Tax;

/*******************************************************************************
 *                                                                             *
 *  Name    : Do_Get_Sup_Site                                                  *
 *  Purpose : Get Tax Registration Information from sup sites                  *
 *                                                                             *
 *******************************************************************************/
PROCEDURE  Do_Get_Sup_Site
             (p_party_tax_profile_id  IN   NUMBER,
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id       IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
              p_getone                OUT  NOCOPY NUMBER)
IS

  -----------------------------
  -- Local variables definition
  -----------------------------
  l_ptp_id           NUMBER;
  l_ptp_type_code    VARCHAR2(30);

  l_ap_tax_rounding_rule  VARCHAR2(10);
  l_tax_rounding_level    VARCHAR2(10);
  l_auto_tax_calc_flag    ap_supplier_sites_all.auto_tax_calc_flag%TYPE;
  l_vat_code              ap_supplier_sites_all.vat_code%TYPE;
  l_vat_registration_num  ap_supplier_sites_all.vat_registration_num%TYPE;

  -- Logging Infra
  l_procedure_name   CONSTANT VARCHAR2(30) := 'Do_Get_Sup_Site';
  l_log_msg          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  -----------------------------------------------------------------
  -- Get the Tax Registration Information
  -- Tax Registration should be valid on the Tax Determination Date
  -----------------------------------------------------------------
  CURSOR c_supplier_ptp
  IS
  SELECT
          decode(povs.AP_Tax_Rounding_Rule,'U','UP','D','DOWN','N','NEAREST',NULL)  tax_rounding_rule
         ,decode(nvl(povs.Auto_Tax_Calc_Flag,'Y'),'N','N','Y') Auto_Tax_Calc_Flag
         ,povs.VAT_Code
	 ,povs.VAT_Registration_Num
	 ,DECODE(povs.Auto_Tax_Calc_Flag,
               'L','LINE',
               'H','HEADER',
               'T','HEADER',
               NULL) tax_rounding_level
    FROM ap_supplier_sites_all  povs
   WHERE povs.vendor_id      = p_account_id
     AND povs.vendor_site_id = p_account_site_id;

   l_supp_site_info_rec ZX_GLOBAL_STRUCTURES_PKG.supp_site_info_rec_type;

BEGIN

 -- Logging Infra: Setting up runtime level
 G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 -- Initialize return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Logging Infra: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(+)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
 END IF;

 -- Logging Infra: Statement level
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'Parameters ';
   l_log_msg :=  l_log_msg||' p_party_tax_profile_id: '||to_char(p_party_tax_profile_id);
   l_log_msg :=  l_log_msg||' p_account_site_id: '||p_account_site_id;
   l_log_msg :=  l_log_msg||' p_tax_determine_date: '||to_char(p_tax_determine_date,'DD-MON-RRRR');
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
 END IF;
 -- Logging Infra: Statement level

 IF ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl.exists(p_account_site_id) THEN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
        'Vendor site record found in cache for vendor site id:'||to_char(p_account_site_id));
   END IF;

   l_supp_site_info_rec := ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id);

   x_get_registration_rec.Rounding_Rule_Code      := l_supp_site_info_rec.TAX_ROUNDING_RULE;
   x_get_registration_rec.process_for_applicability_flag := l_supp_site_info_rec.Auto_Tax_Calc_Flag;
   x_get_registration_rec.tax_classification_code := l_supp_site_info_rec.VAT_CODE;
   x_get_registration_rec.Rounding_level_Code      := l_supp_site_info_rec.TAX_ROUNDING_LEVEL;
   x_get_registration_rec.Registration_number  :=    l_supp_site_info_rec.VAT_REGISTRATION_NUM;

   p_getone:=1;

 ELSE

    OPEN c_supplier_ptp;
    FETCH c_supplier_ptp INTO l_ap_tax_rounding_rule
                             ,l_auto_tax_calc_flag
                             ,l_vat_code
                             ,l_vat_registration_num
                             ,l_tax_rounding_level
                             ;
    -- Got registration
    IF c_supplier_ptp%NOTFOUND THEN
        p_getone := 0;
    ELSE
        p_getone:=1;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Pupulate the stucture
        x_get_registration_rec.Rounding_Rule_Code      := l_ap_tax_rounding_rule;
        x_get_registration_rec.process_for_applicability_flag := l_auto_tax_calc_flag;
        x_get_registration_rec.tax_classification_code := l_vat_code;
           x_get_registration_rec.Registration_number  := l_vat_registration_num;

        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).TAX_ROUNDING_RULE :=
              l_ap_tax_rounding_rule;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).Auto_Tax_Calc_Flag :=
              l_auto_tax_calc_flag;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).VAT_CODE := l_vat_code;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).TAX_ROUNDING_LEVEL :=
              l_tax_rounding_level;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).VAT_REGISTRATION_NUM :=
              l_vat_registration_num;

    END IF;   -- Got registrations

    CLOSE c_supplier_ptp;
     -- Logging Infra: Procedure level
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := l_procedure_name||'(-)';
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
     END IF;
     -- Fails
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
    FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Error Message: '||SQLERRM;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
END Do_Get_Sup_Site;

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Reg_Site_Uses                                              *
 *  Purpose : Get Tax Registration Information of Accounts.                     *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Reg_Site_Uses
             (p_party_tax_profile_id  IN   NUMBER,
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id       IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_site_use_id           IN   HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
              p_getone                OUT  NOCOPY NUMBER)
IS

  -----------------------------
  -- Local variables definition
  -----------------------------
  l_ptp_id           NUMBER;
  l_ptp_type_code    VARCHAR2(30);

  -- Logging Infra
  l_procedure_name   CONSTANT VARCHAR2(30) := 'Do_Get_Reg_Site_Uses';
  l_log_msg          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  -----------------------------------------------------------------
  -- Get the Tax Registration Information
  -- Tax Registration should be valid on the Tax Determination Date
  -----------------------------------------------------------------
  CURSOR c_site_uses
  IS
  SELECT
          csu.Tax_Reference
		 ,nvl(csu.Tax_Code,caa.tax_code) tax_code
		 ,nvl(csu.Tax_Rounding_rule,caa.tax_rounding_rule) tax_rounding_rule
		 ,nvl(csu.tax_header_level_flag, caa.tax_header_level_flag) tax_header_level_flag
		 ,csu.Tax_Classification
    FROM hz_cust_site_uses_all csu
        ,hz_cust_acct_sites cas
        ,hz_cust_accounts caa
   WHERE csu.site_use_id = p_site_use_id
     AND csu.cust_acct_site_id = p_account_site_id
	 AND csu.cust_acct_site_id = cas.cust_acct_site_id
	 AND cas.cust_account_id = caa.cust_account_id
	 AND caa.cust_account_id = p_account_id;

BEGIN

 -- Logging Infra: Setting up runtime level
 G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 -- Initialize return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Logging Infra: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(+)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
 END IF;

 -- Logging Infra: Statement level
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'Parameters ';
   l_log_msg :=  l_log_msg||' p_party_tax_profile_id: '||to_char(p_party_tax_profile_id);
   l_log_msg :=  l_log_msg||' p_account_site_id: '||p_account_site_id;
   l_log_msg :=  l_log_msg||' p_site_use_id: '||p_site_use_id;
   l_log_msg :=  l_log_msg||' p_tax_determine_date: '||to_char(p_tax_determine_date,'DD-MON-RRRR');
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
 END IF;
 -- Logging Infra: Statement level
 p_getone := 0;

 IF  ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl.exists(p_site_use_id) then
          x_get_registration_rec.Rounding_Rule_Code:=
                           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_rounding_rule;
          x_get_registration_rec.rounding_level_code :=
                           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_header_level_flag;
          x_get_registration_rec.tax_classification_code :=
                           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_code;
          x_get_registration_rec.geo_type_classification_code:=
                           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).Tax_Classification;

          -- bug#6438009: populate Registration_number
          x_get_registration_rec.Registration_number :=
                           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_reference;

          p_getone:=1;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'Site Use information found in cache');
         END IF;
 ELSE
    For my_reg IN c_site_uses Loop
    -- Got registration
           p_getone:=1;
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Populate the stucture
           x_get_registration_rec.Rounding_Rule_Code:= my_reg.tax_rounding_rule;
           x_get_registration_rec.rounding_level_code := my_reg.tax_header_level_flag;
           x_get_registration_rec.tax_classification_code := my_reg.tax_code;
           x_get_registration_rec.geo_type_classification_code:= my_reg.Tax_Classification;

           -- bug#6438009: populate Registration_number
           x_get_registration_rec.Registration_number := my_reg.tax_reference;

           -- Populate the cache
           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).site_use_id := p_site_use_id;
           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_rounding_rule:= my_reg.tax_rounding_rule;
           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_header_level_flag := my_reg.tax_header_level_flag;
           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_code := my_reg.tax_code;
           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).Tax_Classification:= my_reg.Tax_Classification;
           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_reference := my_reg.tax_reference;

           return;
    END LOOP;
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;
  -- Fails
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
    FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Error Message: '||SQLERRM;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
END Do_Get_Reg_Site_Uses;

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Registration_Accts                                         *
 *  Purpose : Get Tax Registration Information of Accounts.                     *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Registration_Accts
             (p_party_tax_profile_id  IN   NUMBER,
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
	      p_getone                OUT  NOCOPY NUMBER)
IS
  -----------------------------
  -- Local variables definition
  -----------------------------
  l_ptp_id           NUMBER;
  l_ptp_type_code    VARCHAR2(30);

  -- Logging Infra
  l_procedure_name   CONSTANT VARCHAR2(30) := 'Do_Get_Registration_Accts';
  l_log_msg          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -----------------------------------------------------------------
  -- Get the Tax Registration Information
  -- Tax Registration should be valid on the Tax Determination Date
  -----------------------------------------------------------------
  CURSOR c_customer_account
  IS
  SELECT
          caa.tax_code tax_code
		 ,caa.tax_rounding_rule tax_rounding_rule
		 ,caa.tax_header_level_flag tax_header_level_flag
    FROM
         hz_cust_accounts caa
   WHERE caa.cust_account_id = p_account_id;

BEGIN

 -- Logging Infra: Setting up runtime level
 G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 -- Initialize return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Logging Infra: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(+)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
 END IF;

 -- Logging Infra: Statement level
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'Parameters ';
   l_log_msg :=  l_log_msg||' p_party_tax_profile_id: '||to_char(p_party_tax_profile_id);
   l_log_msg :=  l_log_msg||' p_account_id: '||p_account_id;
   l_log_msg :=  l_log_msg||' p_tax_determine_date: '||to_char(p_tax_determine_date,'DD-MON-RRRR');
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
 END IF;
 -- Logging Infra: Statement level
 p_getone := 0;

IF ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl.exists(p_account_id) THEN
             x_get_registration_rec.Rounding_Rule_Code:=
                   ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).tax_rounding_rule;
             x_get_registration_rec.rounding_level_code :=
                   ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).tax_header_level_flag;
             x_get_registration_rec.tax_classification_code :=
                   ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).tax_code;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'Cust Account information found in cache');
             END IF;
ELSE
     For my_reg IN c_customer_account Loop
     -- Got registration
            p_getone:=1;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            -- Pupulate the stucture
            x_get_registration_rec.Rounding_Rule_Code:= my_reg.tax_rounding_rule;
            x_get_registration_rec.rounding_level_code := my_reg.tax_header_level_flag;
            x_get_registration_rec.tax_classification_code := my_reg.tax_code;

            ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).CUST_ACCOUNT_ID := p_account_id;
            ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).TAX_CODE := my_reg.tax_code;
            ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).TAX_ROUNDING_RULE := my_reg.tax_rounding_rule;
            ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).TAX_HEADER_LEVEL_FLAG := my_reg.tax_header_level_flag;
            return;
     END LOOP;
END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;
  -- Fails
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
    FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Error Message: '||SQLERRM;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
END Do_Get_Registration_Accts;

/********************************************************************************
 *                                                                              *
 *  Name    : Do_Get_Registration_Party                                         *
 *  Purpose : Get Tax Registration Information of Party.                        *
 *                                                                              *
 ********************************************************************************/
PROCEDURE  Do_Get_Registration_Party
             (p_party_tax_profile_id  IN   NUMBER,
              p_tax_determine_date    IN   ZX_LINES.TAX_DETERMINE_DATE%TYPE,
              x_get_registration_rec  OUT  NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
              x_return_status         OUT  NOCOPY VARCHAR2,
              x_ret_record_level      OUT  NOCOPY VARCHAR2,
			  p_getone                OUT  NOCOPY NUMBER)
IS

  l_tbl_index  BINARY_INTEGER;

  -- Logging Infra
  l_procedure_name   CONSTANT VARCHAR2(30) := 'Do_Get_Registration_Party';
  l_log_msg          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN

 -- Logging Infra: Setting up runtime level
 G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 -- Initialize return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Logging Infra: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(+)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
 END IF;

 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'Parameters ';
   l_log_msg :=  l_log_msg||' p_party_tax_profile_id: '||to_char(p_party_tax_profile_id);
   l_log_msg :=  l_log_msg||' p_tax_determine_date: '||to_char(p_tax_determine_date,'DD-MON-RRRR');
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
 END IF;

 p_getone := 0;

 IF NOT ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL.exists(p_party_tax_profile_id) then

    ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO(
      P_PARTY_TAX_PROFILE_ID => p_party_tax_profile_id,
      X_TBL_INDEX            => l_tbl_index,
      X_RETURN_STATUS  	     => x_return_status);

 END IF;


 IF   ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL.exists(p_party_tax_profile_id) THEN

    p_getone := 1;

    x_get_registration_rec.party_type_code :=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).party_type_code;
    x_get_registration_rec.process_for_applicability_flag:=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).process_for_applicability_flag;
    x_get_registration_rec.rounding_level_code:=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).rounding_level_code;
    x_get_registration_rec.withholding_start_date:=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).withholding_start_date;
    x_get_registration_rec.allow_awt_flag:=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).allow_awt_flag;
    x_get_registration_rec.use_le_as_subscriber_flag:=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).use_le_as_subscriber_flag;
    x_get_registration_rec.allow_offset_tax_flag:=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).allow_offset_tax_flag;
    x_get_registration_rec.party_id:=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).party_id;

    -- bug#6438009: populate rep_registration_number
    x_get_registration_rec.rep_registration_number :=
         ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).rep_registration_number;

  ELSE
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Party Tax Profile Id is not valid: '||p_party_tax_profile_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;
  -- Fails
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
    FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Error Message: '||SQLERRM;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
END Do_Get_Registration_Party;

/********************************************************************************
 *                          Public Procedures                                   *
 ********************************************************************************/

/********************************************************************************
 *                                                                              *
 *  Name    : Get_Tax_Registration                                              *
 *  Purpose : Get_Tax_Registration the following procedure return the           *
 *            registrations details for a given party. Registrations can be     *
 *            retrieved at 3 levels: Regimes, Taxes, or Jurisdictions.          *
 *            Also for migrated rows regime, tax, and jurisdictions fields will *
 *            be null. As per bug 4286280. If there are not true registrations  *
 *            the API will look in account site uses and/or accounts to get     *
 *            tax registration information                                      *
 ********************************************************************************/

Procedure Get_Tax_Registration(
            p_parent_ptp_id          IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_site_ptp_id            IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
  	    p_account_Type_Code      IN  zx_registrations.account_type_code%TYPE,
            p_tax_determine_date     IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax                    IN  ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code        IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_jurisdiction_code      IN  ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE,
            p_account_id             IN  ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
            p_account_site_id        IN  ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
            p_site_use_id            IN  HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE,
            p_zx_registration_rec    OUT NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
            p_ret_record_level       OUT NOCOPY VARCHAR2,
            p_return_status          OUT NOCOPY VARCHAR2) IS

    l_ptp_id           NUMBER;
    l_getone           NUMBER;
    l_ptp_type_code    VARCHAR2(30);

    -- Logging Infra
    l_procedure_name   CONSTANT VARCHAR2(30) := 'Get_Tax_Registration';
    l_log_msg          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

 BEGIN

    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters ';
      l_log_msg :=  l_log_msg||' p_parent_ptp_id: '||to_char(p_parent_ptp_id)||', ';
      l_log_msg :=  l_log_msg||' p_site_ptp_id: '||to_char(p_site_ptp_id)||', ';
      l_log_msg :=  l_log_msg||' p_tax_determine_date: '||to_char(p_tax_determine_date,'DD-MON-RRRR')||', ';
      l_log_msg :=  l_log_msg||' p_tax: '||p_tax||', ';
      l_log_msg :=  l_log_msg||' p_tax_regime_code: '||p_tax_regime_code||', ';
      l_log_msg :=  l_log_msg||' p_jurisdiction_code: '||p_jurisdiction_code||', ';
      l_log_msg :=  l_log_msg||' p_account_site_id: '||to_char(p_account_site_id)||', ';
      l_log_msg :=  l_log_msg||' p_site_use_id: '||to_char(p_site_use_id)||', ';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level

  -- Initialize Return Status and Error Buffer
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  l_getone := 0;
  --
  -- Always PTP_ID parameter can NOT be NULL
  --
  IF p_parent_ptp_id IS NULL THEN -- if 1
-- Bug 4939819 - Return error only if the third party account id is also NULL.
--               PTP setup is not mandatory for third parties.
     IF p_account_id IS NULL THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
       p_ret_record_level := NULL;
       return;
     END IF;
  ELSE -- if 1
     -- Checking for true registrations
--     IF ((p_tax_regime_code IS NOT NULL) OR (p_tax IS NOT NULL)
--	                                     OR (p_jurisdiction_code IS NOT NULL)) THEN -- if2
     IF (p_site_ptp_id is null) and (p_account_id is NULL) and (p_account_site_id IS NULL) THEN  -- HQ
     -- Checking for etb registrations at HQ only
        Do_Get_Registration_Tax(p_parent_ptp_id
                               ,p_tax_regime_code
                               ,p_tax
                               ,p_jurisdiction_code
                               ,p_tax_determine_date
                               ,p_zx_registration_rec
                               ,p_return_status
                               ,p_ret_record_level
                               ,l_getone);
         IF l_getone = 1 THEN
            return;
         END IF;
     END IF; -- HQ

       -- Get tax registrations from the site
        IF p_site_ptp_id is not null THEN -- if3
           Do_Get_Registration_Tax(p_site_ptp_id
		                  ,p_tax_regime_code
			   	  ,p_tax
				  ,p_jurisdiction_code
				  ,p_tax_determine_date
				  ,p_zx_registration_rec
				  ,p_return_status
				  ,p_ret_record_level
				  ,l_getone);
		   IF l_getone = 1 THEN -- if4
		      return;
		   ELSE -- if4 Trying to get a true registration for the parent
                           Do_Get_Registration_Tax(p_parent_ptp_id
		                      ,p_tax_regime_code
				      ,p_tax
				      ,p_jurisdiction_code
				      ,p_tax_determine_date
				      ,p_zx_registration_rec
				      ,p_return_status
				      ,p_ret_record_level
				      ,l_getone);
			   IF l_getone = 1 THEN -- if5
		          return;
			   END IF;	-- if5
		   END IF; -- if4
	    END IF;	-- if3 p_site_ptp_id id not null
	 -- Check if we can get the registration information from ap_supplier_sites_all
	 -- or hz_cust_accounts or hz_cust_site_uses
	 --
     IF (p_account_id is not NULL) and (p_account_site_id IS NOT NULL) THEN -- if6
     -- Check party type code
        IF p_account_type_code = 'SUPPLIER' THEN -- if7
           -- Get supplier information from ap_suppliers-sites
           Do_Get_Sup_Site(p_parent_ptp_id
                          ,p_account_id
		          ,p_account_site_id
                          ,p_tax_determine_date
			  ,p_zx_registration_rec
			  ,p_return_status
		          ,p_ret_record_level
			  ,l_getone);
            IF l_getone = 1 THEN -- if8
		       return;
	    End IF;	 -- if8

        ELSIF p_account_type_code = 'CUSTOMER' THEN -- if7
           -- Check if account site use parameter is not null
            IF p_site_use_id IS NOT NULL THEN -- if9
               Do_Get_Reg_Site_Uses(p_parent_ptp_id
                                   ,p_account_id
		                   ,p_account_site_id
				   ,p_site_use_id
   				   ,p_tax_determine_date
				   ,p_zx_registration_rec
				   ,p_return_status
				   ,p_ret_record_level
				   ,l_getone);

                IF l_getone = 1 THEN -- if10
		           return;
			    -- Get registration at account level
	        ElSE -- if10
                   Do_Get_Registration_Accts(p_parent_ptp_id
				            ,p_account_id
					    ,p_tax_determine_date
					    ,p_zx_registration_rec
					    ,p_return_status
					    ,p_ret_record_level
					    ,l_getone);
                   IF l_getone = 1 THEN -- if11
		              return;
		           End IF; --if11
                End If; -- if10 getone
             End IF;-- if9 p_site_use_id is not null
        END IF; -- if7 p_account_type
      END IF;  -- if6 p_account_id is not null
        -- Get Registration information at ptp level
        IF l_getone = 0 Then -- if12
           IF p_site_ptp_id is not null THEN --if13
              -- Get registration infomation from the site
              Do_Get_Registration_Party(p_site_ptp_id
		                       ,p_tax_determine_date
		   		       ,p_zx_registration_rec
				       ,p_return_status
				       ,p_ret_record_level
				       ,l_getone);
		    IF l_getone = 1 THEN --if14
		       return;
		    ELSE -- if14
	           -- get registration information from the parent
               Do_Get_Registration_Party(p_parent_ptp_id
		                        ,p_tax_determine_date
		   			,p_zx_registration_rec
					,p_return_status
					,p_ret_record_level
 					,l_getone);
			   IF l_getone = 1 THEN -- if15
		               return;
               ELSE -- if15 getone
                             p_return_status := FND_API.G_RET_STS_ERROR;
                              p_ret_record_level := NULL;

                           -- Logging Infra: Procedure level
    	   	      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN -- if16
                     l_log_msg := l_procedure_name||'Get Tax Registration did not find any record';
                     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
                  END IF; --if16
              END IF; -- if15 getone
           END IF; -- if14 getone site level
         END IF; -- if13
      END IF; -- if12
--    END IF;  --if2
   END IF; --if1
    -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.END', l_log_msg);
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
    FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Error Message: '||SQLERRM;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level

END Get_Tax_Registration;


 PROCEDURE INITIALIZE_LTE (p_return_status    OUT NOCOPY VARCHAR2) IS

    l_procedure_name   CONSTANT VARCHAR2(30) := 'Initialize LTE';
    l_log_msg          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    l_category_set     mtl_category_sets_b.Category_set_ID%TYPE;
    l_fc_id            ZX_FC_CODES_B.CLASSIFICATION_ID%TYPE;

 BEGIN
     -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

     -- Initialize return status
     p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters : None';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level

      IF (zx_fc_migrate_pkg.Is_Country_Installed(7004, 'jlbrloc')  or
          zx_fc_migrate_pkg.Is_Country_Installed(7004, 'jlarloc') or
          zx_fc_migrate_pkg.Is_Country_Installed(7004, 'jlcoloc')
	  )THEN

	 -- Insert the FISCAL CLASSIFICATION CODE for LTE in level one
 	 zx_fc_migrate_pkg.FIRST_LEVEL_FC_CODE_INSERT('PRODUCT_CATEGORY','FISCAL CLASSIFICATION CODE',
				   'Fiscal Classification Code',NULL,l_fc_id);

	 IF Zx_Migrate_Util.IS_INSTALLED('INV') = 'Y' THEN

	   zx_fc_migrate_pkg.Create_Category_Set ('FISCAL_CLASSIFICATION',
	                         'Fiscal Classification',
	                         'FISCAL_CLASSIFICATION',
	                         'Fiscal Classification');

  	   SELECT Category_set_ID
	   INTO l_category_set
	   FROM mtl_category_sets
	   WHERE Category_Set_Name = 'FISCAL_CLASSIFICATION';

	  -- Call a common procedure to create FC Types
	  zx_fc_migrate_pkg.FC_TYPE_INSERT('FISCAL_CLASSIFICATION','Fiscal Classification Code',l_category_set);

  	  -- Call Country Defaults
	  zx_fc_migrate_pkg.country_default;

	  -- Create Regime Association for 'FISCAL CLASSIFICATION CODE'
	  arp_util_tax.debug( 'Creating the regime association to fiscal type.. ');

		INSERT ALL INTO
		ZX_FC_TYPES_REG_ASSOC
			(Tax_regime_code,
			classification_type_code,
			effective_FROM,
			effective_to,
			record_type_code,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			classif_regime_id,
			object_version_number)
	  	VALUES
			(TAX_REGIME_CODE,
			'FISCAL_CLASSIFICATION',
			SYSDATE,
			NULL,
			'MIGRATED',
			fnd_global.user_id,
			SYSDATE,
			fnd_global.user_id,
			SYSDATE,
			FND_GLOBAL.CONC_LOGIN_ID,
			zx_fc_types_reg_assoc_s.nextval,
			1)
		SELECT unique tax_regime_code
		FROM zx_rates_b
		WHERE content_owner_id in
			(SELECT unique org_id
			 FROM  zx_product_options_all
			 WHERE application_id = 222
			 and tax_method_code='LTE');

	    END IF; -- Check for Inventory installed

     END IF; -- Countries installed.

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.END', l_log_msg);
   END IF;


 EXCEPTION  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
    FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Error Message: '||SQLERRM;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level

 END INITIALIZE_LTE;

END  ZX_TCM_CONTROL_PKG;

/
