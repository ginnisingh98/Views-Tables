--------------------------------------------------------
--  DDL for Package Body OTA_THG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_THG_SHD" as
/* $Header: otthgrhi.pkb 120.0 2005/05/29 07:44:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_thg_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'OTA_GL_HR_FLEX_MAPS_FK1') Then
     fnd_message.set_name('OTA','OTA_13217_THG_NO_TCC');
     fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_HR_GL_FLEX_MAPS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_HR_GL_FLEX_MAPS_UK1') Then
    fnd_message.set_name('OTA','OTA_13396_THG_DUPLICATE');
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
  (p_gl_default_segment_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       gl_default_segment_id
      ,cross_charge_id
      ,segment
      ,segment_num
      ,hr_data_source
      ,constant
      ,hr_cost_segment
      ,object_version_number
    from	ota_hr_gl_flex_maps
    where	gl_default_segment_id = p_gl_default_segment_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_gl_default_segment_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_gl_default_segment_id
        = ota_thg_shd.g_old_rec.gl_default_segment_id and
        p_object_version_number
        = ota_thg_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ota_thg_shd.g_old_rec;
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
          <> ota_thg_shd.g_old_rec.object_version_number) Then
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
  (p_gl_default_segment_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       gl_default_segment_id
      ,cross_charge_id
      ,segment
      ,segment_num
      ,hr_data_source
      ,constant
      ,hr_cost_segment
      ,object_version_number
    from	ota_hr_gl_flex_maps
    where	gl_default_segment_id = p_gl_default_segment_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'GL_DEFAULT_SEGMENT_ID'
    ,p_argument_value     => p_gl_default_segment_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_thg_shd.g_old_rec;
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
      <> ota_thg_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ota_hr_gl_flex_maps');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_gl_default_segment_id          in number
  ,p_cross_charge_id                in number
  ,p_segment                        in varchar2
  ,p_segment_num                    in number
  ,p_hr_data_source                     in varchar2
  ,p_constant                       in varchar2
  ,p_hr_cost_segment                in varchar2
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
  l_rec.gl_default_segment_id            := p_gl_default_segment_id;
  l_rec.cross_charge_id                  := p_cross_charge_id;
  l_rec.segment                          := p_segment;
  l_rec.segment_num                      := p_segment_num;
  l_rec.hr_data_source                       := p_hr_data_source;
  l_rec.constant                         := p_constant;
  l_rec.hr_cost_segment                  := p_hr_cost_segment;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_thg_shd;

/
