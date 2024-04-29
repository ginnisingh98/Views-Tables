--------------------------------------------------------
--  DDL for Package Body PER_RVR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RVR_SHD" as
/* $Header: pervrrhi.pkb 120.5 2006/06/12 23:57:11 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rvr_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  Null;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_workbench_view_report_code           in     varchar2
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       workbench_item_code
      ,workbench_view_report_code
      ,workbench_view_report_type
      ,workbench_view_report_action
      ,workbench_view_country
      ,wb_view_report_instruction
      ,object_version_number
      ,primary_industry
      ,enabled_flag
    from        per_ri_view_reports
    where       workbench_view_report_code = p_workbench_view_report_code;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_workbench_view_report_code is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_workbench_view_report_code
        = per_rvr_shd.g_old_rec.workbench_view_report_code and
        p_object_version_number
        = per_rvr_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into per_rvr_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> per_rvr_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_workbench_view_report_code           in     varchar2
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       workbench_item_code
      ,workbench_view_report_code
      ,workbench_view_report_type
      ,workbench_view_report_action
      ,workbench_view_country
      ,wb_view_report_instruction
      ,object_version_number
      ,primary_industry
      ,enabled_flag
    from        per_ri_view_reports
    where       workbench_view_report_code = p_workbench_view_report_code
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'WORKBENCH_VIEW_REPORT_CODE'
    ,p_argument_value     => p_workbench_view_report_code
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_rvr_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> per_rvr_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'per_ri_view_reports');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
-- EDIT_HERE:  Execute AOL's tltblgen(UNIX) program to generate the
--             ADD_LANGUAGE procedure.  Only the add_language procedure
--             should be added here.  Remove the following skeleton
--             procedure.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
Begin
  --
    delete from PER_RI_VIEW_REPORTS_TL T
  where not exists
    (select NULL
    from PER_RI_VIEW_REPORTS B
    where B.WORKBENCH_VIEW_REPORT_CODE = T.WORKBENCH_VIEW_REPORT_CODE
    );

  update PER_RI_VIEW_REPORTS_TL T set (
      WORKBENCH_VIEW_REPORT_NAME,
      WB_VIEW_REPORT_DESCRIPTION
    ) = (select
      B.WORKBENCH_VIEW_REPORT_NAME,
      B.WB_VIEW_REPORT_DESCRIPTION
    from PER_RI_VIEW_REPORTS_TL B
    where B.WORKBENCH_VIEW_REPORT_CODE = T.WORKBENCH_VIEW_REPORT_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WORKBENCH_VIEW_REPORT_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.WORKBENCH_VIEW_REPORT_CODE,
      SUBT.LANGUAGE
    from PER_RI_VIEW_REPORTS_TL SUBB, PER_RI_VIEW_REPORTS_TL SUBT
    where SUBB.WORKBENCH_VIEW_REPORT_CODE = SUBT.WORKBENCH_VIEW_REPORT_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.WORKBENCH_VIEW_REPORT_NAME <> SUBT.WORKBENCH_VIEW_REPORT_NAME
      or SUBB.WB_VIEW_REPORT_DESCRIPTION <> SUBT.WB_VIEW_REPORT_DESCRIPTION
  ));

  insert into PER_RI_VIEW_REPORTS_TL (
    WORKBENCH_VIEW_REPORT_CODE,
    WORKBENCH_VIEW_REPORT_NAME,
    WB_VIEW_REPORT_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.WORKBENCH_VIEW_REPORT_CODE,
    B.WORKBENCH_VIEW_REPORT_NAME,
    B.WB_VIEW_REPORT_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_RI_VIEW_REPORTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_RI_VIEW_REPORTS_TL T
    where T.WORKBENCH_VIEW_REPORT_CODE = B.WORKBENCH_VIEW_REPORT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
End add_language;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_workbench_item_code            in varchar2
  ,p_workbench_view_report_code     in varchar2
  ,p_workbench_view_report_type     in varchar2
  ,p_workbench_view_report_action   in varchar2
  ,p_workbench_view_country         in varchar2
  ,p_wb_view_report_instruction     in varchar2
  ,p_object_version_number          in number
  ,p_primary_industry		        in varchar2
  ,p_enabled_flag                   in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.workbench_item_code              := p_workbench_item_code;
  l_rec.workbench_view_report_code       := p_workbench_view_report_code;
  l_rec.workbench_view_report_type       := p_workbench_view_report_type;
  l_rec.workbench_view_report_action     := p_workbench_view_report_action;
  l_rec.workbench_view_country           := p_workbench_view_country;
  l_rec.wb_view_report_instruction       := p_wb_view_report_instruction;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.primary_industry		         := p_primary_industry;
  l_rec.enabled_flag                     := p_enabled_flag;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_rvr_shd;

/
