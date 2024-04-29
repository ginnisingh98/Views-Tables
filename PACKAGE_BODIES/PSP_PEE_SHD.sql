--------------------------------------------------------
--  DDL for Package Body PSP_PEE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PEE_SHD" as
/* $Header: PSPEERHB.pls 120.3 2006/02/08 05:35 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_pee_shd.';  -- Global package name
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
  If (p_constraint_name = 'SYS_C00145474') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_external_effort_line_id              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       external_effort_line_id
      ,batch_name
      ,object_version_number
      ,distribution_date
      ,person_id
      ,assignment_id
      ,currency_code
      ,distribution_amount
      ,business_group_id
      ,set_of_books_id
      ,gl_code_combination_id
      ,project_id
      ,task_id
      ,award_id
      ,expenditure_organization_id
      ,expenditure_type
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
    from        psp_external_effort_lines
    where       external_effort_line_id = p_external_effort_line_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_external_effort_line_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_external_effort_line_id
        = psp_pee_shd.g_old_rec.external_effort_line_id and
        p_object_version_number
        = psp_pee_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into psp_pee_shd.g_old_rec;
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
          <> psp_pee_shd.g_old_rec.object_version_number) Then
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
  (p_external_effort_line_id              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       external_effort_line_id
      ,batch_name
      ,object_version_number
      ,distribution_date
      ,person_id
      ,assignment_id
      ,currency_code
      ,distribution_amount
      ,business_group_id
      ,set_of_books_id
      ,gl_code_combination_id
      ,project_id
      ,task_id
      ,award_id
      ,expenditure_organization_id
      ,expenditure_type
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
    from        psp_external_effort_lines
    where       external_effort_line_id = p_external_effort_line_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EXTERNAL_EFFORT_LINE_ID'
    ,p_argument_value     => p_external_effort_line_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into psp_pee_shd.g_old_rec;
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
      <> psp_pee_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'psp_external_effort_lines');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_external_effort_line_id        in number
  ,p_batch_name                     in varchar2
  ,p_object_version_number          in number
  ,p_distribution_date              in date
  ,p_person_id                      in number
  ,p_assignment_id                  in number
  ,p_currency_code                  in varchar2
  ,p_distribution_amount            in number
  ,p_business_group_id              in number
  ,p_set_of_books_id                in number
  ,p_gl_code_combination_id         in number
  ,p_project_id                     in number
  ,p_task_id                        in number
  ,p_award_id                       in number
  ,p_expenditure_organization_id    in number
  ,p_expenditure_type               in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.external_effort_line_id          := p_external_effort_line_id;
  l_rec.batch_name                       := p_batch_name;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.distribution_date                := p_distribution_date;
  l_rec.person_id                        := p_person_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.currency_code                    := p_currency_code;
  l_rec.distribution_amount              := p_distribution_amount;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.set_of_books_id                  := p_set_of_books_id;
  l_rec.gl_code_combination_id           := p_gl_code_combination_id;
  l_rec.project_id                       := p_project_id;
  l_rec.task_id                          := p_task_id;
  l_rec.award_id                         := p_award_id;
  l_rec.expenditure_organization_id      := p_expenditure_organization_id;
  l_rec.expenditure_type                 := p_expenditure_type;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end psp_pee_shd;

/
