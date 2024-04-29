--------------------------------------------------------
--  DDL for Package Body HR_TIS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIS_SHD" as
/* $Header: hrtisrhi.pkb 120.3 2008/02/25 13:24:06 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_tis_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_KI_TOPIC_INTEGRATIONS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_KI_TOPIC_INTEGRATIONS_UK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  (p_topic_integrations_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select topic_integrations_id
          ,topic_id
          ,integration_id
          ,param_name1
          ,param_value1
          ,param_name2
          ,param_value2
          ,param_name3
          ,param_value3
          ,param_name4
          ,param_value4
          ,param_name5
          ,param_value5
          ,param_name6
          ,param_value6
          ,param_name7
          ,param_value7
          ,param_name8
          ,param_value8
          ,param_name9
          ,param_value9
          ,param_name10
          ,param_value10
          ,object_version_number
     from  hr_ki_topic_integrations
    where  topic_integrations_id = p_topic_integrations_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_topic_integrations_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_topic_integrations_id  = hr_tis_shd.g_old_rec.topic_integrations_id and
        p_object_version_number  = hr_tis_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_tis_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> hr_tis_shd.g_old_rec.object_version_number) Then
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
  (p_topic_integrations_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select topic_integrations_id
          ,topic_id
          ,integration_id
          ,param_name1
          ,param_value1
          ,param_name2
          ,param_value2
          ,param_name3
          ,param_value3
          ,param_name4
          ,param_value4
          ,param_name5
          ,param_value5
          ,param_name6
          ,param_value6
          ,param_name7
          ,param_value7
          ,param_name8
          ,param_value8
          ,param_name9
          ,param_value9
          ,param_name10
          ,param_value10
          ,object_version_number
    from   hr_ki_topic_integrations
    where  topic_integrations_id = p_topic_integrations_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TOPIC_INTEGRATIONS_ID'
    ,p_argument_value     => p_topic_integrations_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_tis_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number  <> hr_tis_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_ki_topic_integrations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_topic_integrations_id          in number
  ,p_topic_id                       in number
  ,p_integration_id                 in number
  ,p_param_name1                    in varchar2
  ,p_param_value1                   in varchar2
  ,p_param_name2                    in varchar2
  ,p_param_value2                   in varchar2
  ,p_param_name3                    in varchar2
  ,p_param_value3                   in varchar2
  ,p_param_name4                    in varchar2
  ,p_param_value4                   in varchar2
  ,p_param_name5                    in varchar2
  ,p_param_value5                   in varchar2
  ,p_param_name6                    in varchar2
  ,p_param_value6                   in varchar2
  ,p_param_name7                    in varchar2
  ,p_param_value7                   in varchar2
  ,p_param_name8                    in varchar2
  ,p_param_value8                   in varchar2
  ,p_param_name9                    in varchar2
  ,p_param_value9                   in varchar2
  ,p_param_name10                   in varchar2
  ,p_param_value10                  in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.topic_integrations_id        := p_topic_integrations_id;
  l_rec.topic_id                     := p_topic_id;
  l_rec.integration_id               := p_integration_id;
  l_rec.param_name1                  := p_param_name1;
  l_rec.param_value1                 := p_param_value1;
  l_rec.param_name2                  := p_param_name2;
  l_rec.param_value2                 := p_param_value2;
  l_rec.param_name3                  := p_param_name3;
  l_rec.param_value3                 := p_param_value3;
  l_rec.param_name4                  := p_param_name4;
  l_rec.param_value4                 := p_param_value4;
  l_rec.param_name5                  := p_param_name5;
  l_rec.param_value5                 := p_param_value5;
  l_rec.param_name6                  := p_param_name6;
  l_rec.param_value6                 := p_param_value6;
  l_rec.param_name7                  := p_param_name7;
  l_rec.param_value7                 := p_param_value7;
  l_rec.param_name8                  := p_param_name8;
  l_rec.param_value8                 := p_param_value8;
  l_rec.param_name9                  := p_param_name9;
  l_rec.param_value9                 := p_param_value9;
  l_rec.param_name10                 := p_param_name10;
  l_rec.param_value10                := p_param_value10;
  l_rec.object_version_number        := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_tis_shd;

/
