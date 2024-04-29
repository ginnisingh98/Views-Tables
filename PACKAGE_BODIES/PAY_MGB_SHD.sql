--------------------------------------------------------
--  DDL for Package Body PAY_MGB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MGB_SHD" as
/* $Header: pymgbrhi.pkb 120.0 2005/05/29 06:45:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_mgb_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc        varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PAY_MAGNETIC_BLOCKS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_MGB_MAIN_BLOCK_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
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
  p_magnetic_block_id                  in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
        magnetic_block_id,
        block_name,
        main_block_flag,
        report_format,
        cursor_name,
        no_column_returned
    from        pay_magnetic_blocks
    where       magnetic_block_id = p_magnetic_block_id;
--
  l_proc        varchar2(72)    := g_package||'api_updating';
  l_fct_ret     boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
        p_magnetic_block_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
        p_magnetic_block_id = g_old_rec.magnetic_block_id
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
      --
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
  p_magnetic_block_id                  in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select      magnetic_block_id,
        block_name,
        main_block_flag,
        report_format,
        cursor_name,
        no_column_returned
    from        pay_magnetic_blocks
    where       magnetic_block_id = p_magnetic_block_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
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
  --
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
    hr_utility.set_message_token('TABLE_NAME', 'pay_magnetic_blocks');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
        (
        p_magnetic_block_id             in number,
        p_block_name                    in varchar2,
        p_main_block_flag               in varchar2,
        p_report_format                 in varchar2,
        p_cursor_name                   in varchar2,
        p_no_column_returned            in number
        )
        Return g_rec_type is
--
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.magnetic_block_id                := p_magnetic_block_id;
  l_rec.block_name                       := p_block_name;
  l_rec.main_block_flag                  := p_main_block_flag;
  l_rec.report_format                    := p_report_format;
  l_rec.cursor_name                      := p_cursor_name;
  l_rec.no_column_returned               := p_no_column_returned;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_magnetic_block_id >---------------------|
-- ----------------------------------------------------------------------------
Function get_magnetic_block_id
  (p_block_name                     in varchar2
  ,p_report_format                  in varchar2
  )
  Return number is
--
  cursor csr_magnetic_block_id is
       select distinct magnetic_block_id
         from pay_magnetic_blocks
        where block_name = p_block_name
          and report_format = p_report_format;
--
  l_proc   varchar2(72) := g_package||'get_magnetic_block_id';
  l_magnetic_block_id   PAY_MAGNETIC_BLOCKS.MAGNETIC_BLOCK_ID%TYPE;
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_block_name is null  or  p_report_format is null  then

        return  null;

  end if;

  open csr_magnetic_block_id;
  fetch csr_magnetic_block_id into l_magnetic_block_id;

  if csr_magnetic_block_id%ROWCOUNT > 1 then

        close csr_magnetic_block_id;

        fnd_message.set_name( 'PAY' , 'PAY_33255_INV_SKEY' );
        fnd_message.set_token( 'SURROGATE_ID' , 'MAGNETIC_BLOCK_ID' );
        fnd_message.set_token( 'ENTITY' , 'MAGNETIC BLOCK' );
        fnd_message.raise_error ;

  end if;

  close csr_magnetic_block_id;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

  return l_magnetic_block_id;

--
End get_magnetic_block_id;
--
end pay_mgb_shd;

/
