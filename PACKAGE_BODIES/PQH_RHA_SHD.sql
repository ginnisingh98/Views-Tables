--------------------------------------------------------
--  DDL for Package Body PQH_RHA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RHA_SHD" as
/* $Header: pqrharhi.pkb 120.1 2005/08/03 13:43:25 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rha_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_ROUTING_HIST_ATTRIBS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_ROUTING_HIST_ATTRIBS_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_ROUTING_HIST_ATTRIBS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  (p_routing_hist_attrib_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       routing_hist_attrib_id
      ,routing_history_id
      ,attribute_id
      ,from_char
      ,from_date
      ,from_number
      ,to_char
      ,to_date
      ,to_number
      ,object_version_number
      ,range_type_cd
      ,value_date
      ,value_number
      ,value_char
    from	pqh_routing_hist_attribs
    where	routing_hist_attrib_id = p_routing_hist_attrib_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_routing_hist_attrib_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_routing_hist_attrib_id
        = pqh_rha_shd.g_old_rec.routing_hist_attrib_id and
        p_object_version_number
        = pqh_rha_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_rha_shd.g_old_rec;
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
          <> pqh_rha_shd.g_old_rec.object_version_number) Then
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
  (p_routing_hist_attrib_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       routing_hist_attrib_id
      ,routing_history_id
      ,attribute_id
      ,from_char
      ,from_date
      ,from_number
      ,to_char
      ,to_date
      ,to_number
      ,object_version_number
      ,range_type_cd
      ,value_date
      ,value_number
      ,value_char
    from	pqh_routing_hist_attribs
    where	routing_hist_attrib_id = p_routing_hist_attrib_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ROUTING_HIST_ATTRIB_ID'
    ,p_argument_value     => p_routing_hist_attrib_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_rha_shd.g_old_rec;
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
      <> pqh_rha_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_routing_hist_attribs');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_routing_hist_attrib_id         in number
  ,p_routing_history_id             in number
  ,p_attribute_id                   in number
  ,p_from_char                      in varchar2
  ,p_from_date                      in date
  ,p_from_number                    in number
  ,p_to_char                        in varchar2
  ,p_to_date                        in date
  ,p_to_number                      in number
  ,p_object_version_number          in number
  ,p_range_type_cd                  in varchar2
  ,p_value_date                     in date
  ,p_value_number                   in number
  ,p_value_char                     in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.routing_hist_attrib_id           := p_routing_hist_attrib_id;
  l_rec.routing_history_id               := p_routing_history_id;
  l_rec.attribute_id                     := p_attribute_id;
  l_rec.from_char                        := p_from_char;
  l_rec.from_date                        := p_from_date;
  l_rec.from_number                      := p_from_number;
  l_rec.to_char                          := p_to_char;
  l_rec.to_date                          := p_to_date;
  l_rec.to_number                        := p_to_number;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.range_type_cd                    := p_range_type_cd;
  l_rec.value_date                       := p_value_date;
  l_rec.value_number                     := p_value_number;
  l_rec.value_char                       := p_value_char;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_rha_shd;

/
