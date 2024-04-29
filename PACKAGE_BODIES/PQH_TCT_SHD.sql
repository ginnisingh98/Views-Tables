--------------------------------------------------------
--  DDL for Package Body PQH_TCT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCT_SHD" as
/* $Header: pqtctrhi.pkb 120.4.12000000.2 2007/04/19 12:48:04 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tct_shd.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'AVCON_15469327_FUTUR_000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'AVCON_15469327_MEMBE_000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'AVCON_15469327_POST__000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'AVCON_15469327_ROUTE_000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TRANSACTION_CATEGORIES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TRANSACTION_CATEGORIES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TRANSACTION_CATEGORIES_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TRANSACTION_CATEGORIES_UK') Then
    hr_utility.set_message(8302, 'PQH_SS_DUPLICATE_SHORT_NAME');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_transaction_category_id            in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	transaction_category_id,
	custom_wf_process_name,
	custom_workflow_name,
	form_name,
	freeze_status_cd,
	future_action_cd,
	member_cd,
	name,
        short_name,
	post_style_cd,
	post_txn_function,
	route_validated_txn_flag,
        prevent_approver_skip,
        workflow_enable_flag,
        enable_flag,
	timeout_days,
	object_version_number,
	consolidated_table_route_id	,
        business_group_id,
        setup_type_cd,
        master_table_route_id
    from	pqh_transaction_categories
    where	transaction_category_id = p_transaction_category_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_transaction_category_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_transaction_category_id = g_old_rec.transaction_category_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_transaction_category_id            in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	transaction_category_id,
	custom_wf_process_name,
	custom_workflow_name,
	form_name,
	freeze_status_cd,
	future_action_cd,
	member_cd,
	name,
        short_name,
	post_style_cd,
	post_txn_function,
	route_validated_txn_flag,
	prevent_approver_skip,
        workflow_enable_flag,
        enable_flag,
	timeout_days,
	object_version_number,
	consolidated_table_route_id,
        business_group_id,
        setup_type_cd,
        master_table_route_id
    from	pqh_transaction_categories
    where	transaction_category_id = p_transaction_category_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pqh_transaction_categories');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_transaction_category_id       in number,
	p_custom_wf_process_name        in varchar2,
	p_custom_workflow_name          in varchar2,
	p_form_name                     in varchar2,
	p_freeze_status_cd              in varchar2,
	p_future_action_cd              in varchar2,
	p_member_cd                     in varchar2,
	p_name                          in varchar2,
        p_short_name                    in varchar2,
	p_post_style_cd                 in varchar2,
	p_post_txn_function             in varchar2,
	p_route_validated_txn_flag      in varchar2,
	p_prevent_approver_skip         in varchar2,
        p_workflow_enable_flag          in varchar2,
        p_enable_flag          in varchar2,
	p_timeout_days                  in number,
	p_object_version_number         in number,
	p_consolidated_table_route_id   in number ,
        p_business_group_id         in number,
        p_setup_type_cd            in varchar2,
	p_master_table_route_id   in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.transaction_category_id          := p_transaction_category_id;
  l_rec.custom_wf_process_name           := p_custom_wf_process_name;
  l_rec.custom_workflow_name             := p_custom_workflow_name;
  l_rec.form_name                        := p_form_name;
  l_rec.freeze_status_cd                 := p_freeze_status_cd;
  l_rec.future_action_cd                 := p_future_action_cd;
  l_rec.member_cd                        := p_member_cd;
  l_rec.name                             := p_name;
  l_rec.short_name                       := p_short_name;
  l_rec.post_style_cd                    := p_post_style_cd;
  l_rec.post_txn_function                := p_post_txn_function;
  l_rec.route_validated_txn_flag         := p_route_validated_txn_flag;
  l_rec.prevent_approver_skip            := p_prevent_approver_skip;
  l_rec.workflow_enable_flag         := p_workflow_enable_flag;
  l_rec.enable_flag         := p_enable_flag;
  l_rec.timeout_days                     := p_timeout_days;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.consolidated_table_route_id      := p_consolidated_table_route_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.setup_type_cd                    := p_setup_type_cd;
  l_rec.master_table_route_id      := p_master_table_route_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
Procedure load_seed_row
  (p_upload_mode                    in  varchar2
  ,p_name                           in  varchar2
  ,p_short_name                     in  varchar2
  ,p_custom_wf_process_name         in  varchar2
  ,p_custom_workflow_name           in  varchar2
  ,p_form_name                      in  varchar2
  ,p_freeze_status_cd               in  varchar2
  ,p_future_action_cd               in  varchar2
  ,p_member_cd                      in  varchar2
  ,p_post_style_cd                  in  varchar2
  ,p_post_txn_function              in  varchar2
  ,p_route_validated_txn_flag       in  varchar2
  ,p_prevent_approver_skip          in  varchar2
  ,p_workflow_enable_flag           in  varchar2
  ,p_timeout_days                   in  number
  ,p_consolid_table_alias           in  varchar2
--  ,p_business_group_alias           in  varchar2
  ,p_setup_type_cd                  in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_master_table_alias             in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
  ) is
--
--
l_data_migrator_mode varchar2(1);
--
Begin
   l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';

     if (p_upload_mode = 'NLS') then
        pqh_ctl_upd.translate_row (
            p_short_name                => p_short_name,
            p_name                      => p_name ,
            p_owner                     => p_owner);
      else

        pqh_tct_shd.load_row
            (
             p_custom_wf_process_name       => p_custom_wf_process_name
            ,p_custom_workflow_name         => p_custom_workflow_name
            ,p_form_name                    => p_form_name
            ,p_freeze_status_cd             => p_freeze_status_cd
            ,p_future_action_cd             => p_future_action_cd
            ,p_member_cd                    => p_member_cd
            ,p_name                         => p_name
            ,p_short_name                   => p_short_name
            ,p_post_style_cd                => p_post_style_cd
            ,p_post_txn_function            => p_post_txn_function
            ,p_route_validated_txn_flag     => p_route_validated_txn_flag
            ,p_workflow_enable_flag         => p_workflow_enable_flag
            ,p_timeout_days                 => p_timeout_days
            ,p_consolid_table_alias         => p_consolid_table_alias
            ,p_master_table_alias           => p_master_table_alias
            ,p_setup_type_cd                => p_setup_type_cd
            ,p_enable_flag                  => p_enable_flag
            ,p_prevent_approver_skip        => p_prevent_approver_skip
            ,p_owner                        => p_owner
            ,p_last_update_date             => p_last_update_date);
      end if;
       hr_general.g_data_migrator_mode := l_data_migrator_mode;
End;
--
--  -----------    Load Row    -------------------------------------------
--
Procedure load_row
  (
   p_name                           in  varchar2
  ,p_short_name                     in  varchar2
  ,p_custom_wf_process_name         in  varchar2
  ,p_custom_workflow_name           in  varchar2
  ,p_form_name                      in  varchar2
  ,p_freeze_status_cd               in  varchar2
  ,p_future_action_cd               in  varchar2
  ,p_member_cd                      in  varchar2
  ,p_post_style_cd                  in  varchar2
  ,p_post_txn_function              in  varchar2
  ,p_route_validated_txn_flag       in  varchar2
  ,p_prevent_approver_skip          in  varchar2
  ,p_workflow_enable_flag           in  varchar2
  ,p_timeout_days                   in  number
  ,p_consolid_table_alias           in  varchar2
  --,p_business_group_alias           in  varchar2
  ,p_setup_type_cd                  in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_master_table_alias             in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
  ) is
--
   l_effective_date            date  := sysdate ;
   l_object_version_number     number  := 1;
   l_language                  varchar2(30) ;

--
 l_transaction_category_id     pqh_transaction_categories.transaction_category_id%type := 0;
 l_consolidated_table_route_id pqh_transaction_categories.consolidated_table_route_id%type;
 l_master_table_route_id       pqh_transaction_categories.master_table_route_id%type;
 l_business_group_id         hr_all_organization_units.business_group_id%type;
--
--
   l_created_by                 pqh_transaction_categories.created_by%TYPE;
   l_last_updated_by            pqh_transaction_categories.last_updated_by%TYPE;
   l_creation_date              pqh_transaction_categories.creation_date%TYPE;
   l_last_update_date           pqh_transaction_categories.last_update_date%TYPE;
   l_last_update_login          pqh_transaction_categories.last_update_login%TYPE;
--
--
   cursor c1 is select userenv('LANG') from dual ;
--
  Cursor c2(p_table_alias in VARCHAR2) is
    Select table_route_id
      From pqh_table_route
     Where table_alias = p_table_alias;
--
--
  Cursor c3 is
    Select transaction_category_id
      From pqh_transaction_categories_vl
     Where short_name = p_short_name and business_group_id IS NULL;
--
  Cursor C_Sel1 is select pqh_transaction_categories_s.nextval from sys.dual;
--
--
/**
  Cursor c4 is select business_group_id
               from hr_all_organization_units
               where name = p_business_group_alias ;
**/
--
BEGIN
--
   open c1;
   fetch c1 into l_language ;
   close c1;
--
   Open c2(p_table_alias => p_consolid_table_alias);
   Fetch c2 into l_consolidated_table_route_id;
   Close c2;
--
   Open c2(p_table_alias => p_master_table_alias);
   Fetch c2 into l_master_table_route_id;
   Close c2;
--
   Open c3;
   Fetch c3 into l_transaction_category_id;
   Close c3;
--
--
--   Open c4;
--   Fetch c4 into l_business_group_id;
--   Close c4;
--
--
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := -1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/

  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);
  /**
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  **/
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_login := 0;

--

  begin
  --
  If l_transaction_category_id <> 0 then
  --
       --
       -- If there is a row for the transaction category
       -- update the row in the base table
       --
       update pqh_transaction_categories
       set
       custom_wf_process_name            = p_custom_wf_process_name,
       custom_workflow_name              = p_custom_workflow_name,
       form_name                         = p_form_name,
       freeze_status_cd                  = p_freeze_status_cd,
       future_action_cd                  = p_future_action_cd,
       member_cd                         = p_member_cd,
       name                              = p_name,
       short_name                        = p_short_name,
       post_style_cd                     = p_post_style_cd,
       post_txn_function                 = p_post_txn_function,
       route_validated_txn_flag          = p_route_validated_txn_flag,
       prevent_approver_skip             = p_prevent_approver_skip,
       workflow_enable_flag              = p_workflow_enable_flag,
     --  enable_flag                       = p_enable_flag,
       timeout_days                      = p_timeout_days,
       last_updated_by                   = l_last_updated_by,
       last_update_date                  = l_last_update_date,
       last_update_login                 = l_last_update_login,
       consolidated_table_route_id       = l_consolidated_table_route_id,
--      business_group_id                 = l_business_group_id,
--      setup_type_cd                     = p_setup_type_cd,
       master_table_route_id             = l_master_table_route_id
       WHERE transaction_category_id     = l_transaction_category_id
         AND NVL(last_updated_by,-1) in (l_last_updated_by,1,0,-1);
       --
       -- update the tl table
       --
    if (sql%found) then

      UPDATE pqh_transaction_categories_tl
      SET  name               =  p_name,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login,
         source_lang                    = userenv('LANG')
      WHERE transaction_category_id  =  l_transaction_category_id
        AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      If (sql%notfound) then
       -- no row in TL table so insert row

      --
      insert into pqh_transaction_categories_tl
      (	transaction_category_id,
	name,
	language,
	source_lang,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
       )
       Select
        l_transaction_category_id,
	p_name,
	l.language_code,
	l_language ,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login
       from fnd_languages l
       where l.installed_flag in ('I','B')
       and not exists (select null
                  from pqh_transaction_categories_tl ctl
                  where ctl.transaction_category_id = l_transaction_category_id
                  and ctl.language         = l.language_code );
      --
      End if;
      --
    end if; -- sql%found for main table

  Else
      --
      -- Select the next sequence number
      --
      Open C_Sel1;
      Fetch C_Sel1 Into l_transaction_category_id;
      Close C_Sel1;
      --
       --
       -- Insert row into the base table
       --

       insert into pqh_transaction_categories
       (	transaction_category_id,
	custom_wf_process_name,
	custom_workflow_name,
	form_name,
	freeze_status_cd,
	future_action_cd,
	member_cd,
	name,
        short_name,
	post_style_cd,
	post_txn_function,
	route_validated_txn_flag,
	prevent_approver_skip,
        workflow_enable_flag,
 --       enable_flag,
	timeout_days,
	consolidated_table_route_id ,
  --      business_group_id,
  --      setup_type_cd,
	master_table_route_id ,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login,
        object_version_number
       )
       Values
       (l_transaction_category_id,
	p_custom_wf_process_name,
	p_custom_workflow_name,
	p_form_name,
	p_freeze_status_cd,
	p_future_action_cd,
	p_member_cd,
	p_name,
        p_short_name,
	p_post_style_cd,
	p_post_txn_function,
	p_route_validated_txn_flag,
	p_prevent_approver_skip,
        p_workflow_enable_flag,
   --     p_enable_flag,
	p_timeout_days,
	l_consolidated_table_route_id ,
  --      l_business_group_id,
    --    p_setup_type_cd,
	l_master_table_route_id ,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login,
	l_object_version_number
       );

       --
       -- Insert row into the tl table
       --
      insert into pqh_transaction_categories_tl
      (	transaction_category_id,
	name,
	language,
	source_lang,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
       )
       Select
        l_transaction_category_id,
	p_name,
	l.language_code,
	l_language ,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login
       from fnd_languages l
       where l.installed_flag in ('I','B')
       and not exists (select null
                  from pqh_transaction_categories_tl ctl
                  where ctl.transaction_category_id = l_transaction_category_id
                  and ctl.language         = l.language_code );
      --
      --
      --
   End if;
   --
 End;
 --
End load_row;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- Procedure added as a fix for bug 5484366
--
Procedure ADD_LANGUAGE
is
begin
  delete from PQH_TRANSACTION_CATEGORIES_TL T
  where not exists
    (select NULL
    from PQH_TRANSACTION_CATEGORIES B
    where B.TRANSACTION_CATEGORY_ID = T.TRANSACTION_CATEGORY_ID
    );

  update PQH_TRANSACTION_CATEGORIES_TL T set (
      NAME
    ) = (select
      B.NAME
    from PQH_TRANSACTION_CATEGORIES_TL B
    where B.TRANSACTION_CATEGORY_ID = T.TRANSACTION_CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TRANSACTION_CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TRANSACTION_CATEGORY_ID,
      SUBT.LANGUAGE
    from PQH_TRANSACTION_CATEGORIES_TL SUBB, PQH_TRANSACTION_CATEGORIES_TL SUBT
    where SUBB.TRANSACTION_CATEGORY_ID = SUBT.TRANSACTION_CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into PQH_TRANSACTION_CATEGORIES_TL (
    TRANSACTION_CATEGORY_ID,
    NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TRANSACTION_CATEGORY_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_TRANSACTION_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_TRANSACTION_CATEGORIES_TL T
    where T.TRANSACTION_CATEGORY_ID = B.TRANSACTION_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-- --
-- --
end pqh_tct_shd;

/
