--------------------------------------------------------
--  DDL for Package Body PQH_CGN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CGN_SHD" as
/* $Header: pqcgnrhi.pkb 115.7 2002/11/27 04:43:27 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cgn_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_DE_CASE_GROUPS_PK') Then
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
  (p_case_group_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       case_group_id
      ,case_group_number
      ,description
      ,advanced_pay_grade
      ,entries_in_minute
      ,period_of_prob_advmnt
      ,period_of_time_advmnt
      ,advancement_to
      ,object_version_number
      ,advancement_additional_pyt
      ,time_advanced_pay_grade
      ,time_advancement_to
      ,business_group_id
      ,time_advn_units
      ,prob_advn_units
      ,sub_csgrp_description
    from        pqh_de_case_groups
    where       case_group_id = p_case_group_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_case_group_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_case_group_id
        = pqh_cgn_shd.g_old_rec.case_group_id and
        p_object_version_number
        = pqh_cgn_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_cgn_shd.g_old_rec;
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
          <> pqh_cgn_shd.g_old_rec.object_version_number) Then
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
  (p_case_group_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       case_group_id
      ,case_group_number
      ,description
      ,advanced_pay_grade
      ,entries_in_minute
      ,period_of_prob_advmnt
      ,period_of_time_advmnt
      ,advancement_to
      ,object_version_number
      ,advancement_additional_pyt
      ,time_advanced_pay_grade
      ,time_advancement_to
      ,business_group_id
      ,time_advn_units
      ,prob_advn_units
      ,sub_csgrp_description
    from        pqh_de_case_groups
    where       case_group_id = p_case_group_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CASE_GROUP_ID'
    ,p_argument_value     => p_case_group_id
    );

  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OBJECT_VERSION_NUMBER'
  ,p_argument_value     => p_object_version_number
  );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_cgn_shd.g_old_rec;
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
      <> pqh_cgn_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_de_case_groups');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_case_group_id                  in number
  ,p_case_group_number              in varchar2
  ,p_description                    in varchar2
  ,p_advanced_pay_grade             in number
  ,p_entries_in_minute              in varchar2
  ,p_period_of_prob_advmnt          in number
  ,p_period_of_time_advmnt          in number
  ,p_advancement_to                 in number
  ,p_object_version_number          in number
  ,p_advancement_additional_pyt     in number
  ,p_time_advanced_pay_grade        in number
  ,p_time_advancement_to            in number
  ,p_business_group_id              in number
  ,p_time_advn_units                in varchar2
  ,p_prob_advn_units                in varchar2
  ,p_sub_csgrp_description          in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.case_group_id                    := p_case_group_id;
  l_rec.case_group_number                := p_case_group_number;
  l_rec.description                      := p_description;
  l_rec.advanced_pay_grade               := p_advanced_pay_grade;
  l_rec.entries_in_minute                := p_entries_in_minute;
  l_rec.period_of_prob_advmnt            := p_period_of_prob_advmnt;
  l_rec.period_of_time_advmnt            := p_period_of_time_advmnt;
  l_rec.advancement_to                   := p_advancement_to;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.advancement_additional_pyt       := p_advancement_additional_pyt;
  l_rec.time_advanced_pay_grade          := p_time_advanced_pay_grade;
  l_rec.time_advancement_to              := p_time_advancement_to;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.time_advn_units                  := p_time_advn_units;
  l_rec.prob_advn_units                  := p_prob_advn_units;
  l_rec.sub_csgrp_description            := p_sub_csgrp_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_cgn_shd;

/
