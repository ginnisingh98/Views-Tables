--------------------------------------------------------
--  DDL for Package Body SSP_ERN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_ERN_SHD" as
/* $Header: spernrhi.pkb 120.5.12010000.2 2008/08/13 13:25:38 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_ern_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End return_api_dml_status;
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
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  If (p_constraint_name = 'SSP_EARNINGS_CALCULATIONS_PK') Then
    fnd_message.set_name('SSP', 'SSP_35043_INVALID_PRIMARY_KEY');
  ElsIf (p_constraint_name = 'SSP_EARNINGS_CALCULATIONS_UK1') Then
    fnd_message.set_name('SSP', 'SSP_35053_ERN_INV_UK1');
  Else
    fnd_message.set_name('PAY','HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token ('PROCEDURE',l_proc);
    fnd_message.set_token ('CONSTRAINT_NAME',p_constraint_name);
  End If;
  --
  fnd_message.raise_error;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_earnings_calculations_id           in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
	select	earnings_calculations_id,
		object_version_number,
		person_id,
		effective_date,
		average_earnings_amount,
		user_entered,
		payment_periods
	  from	ssp_earnings_calculations
	 where	earnings_calculations_id = p_earnings_calculations_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  If (p_earnings_calculations_id is null and p_object_version_number is null)
  then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_earnings_calculations_id = g_old_rec.earnings_calculations_id and
	p_object_version_number = g_old_rec.object_version_number
       )
    then
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
      Fetch C_Sel1 Into g_old_rec.earnings_calculations_id,
			g_old_rec.object_version_number,
			g_old_rec.person_id,
			g_old_rec.effective_date,
			g_old_rec.average_earnings_amount,
			g_old_rec.user_entered,
			g_old_rec.payment_periods;
      --
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('SSP', 'SSP_35043_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number)
      Then
        fnd_message.set_name('SSP', 'SSP_35044_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_earnings_calculations_id           in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select earnings_calculations_id,
	   object_version_number,
	   person_id,
	   effective_date,
	   average_earnings_amount,
	   user_entered,
	   payment_periods
    from   ssp_earnings_calculations
    where  earnings_calculations_id = p_earnings_calculations_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec.earnings_calculations_id,
                    g_old_rec.object_version_number,
		    g_old_rec.person_id,
                    g_old_rec.effective_date,
                    g_old_rec.average_earnings_amount,
		    g_old_rec.user_entered,
		    g_old_rec.payment_periods;
  --
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('SSP', 'SSP_35043_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number)
  Then
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.raise_error;
  end If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 100);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked so supply a meaningful error message.
    --
    fnd_message.set_name('PAY','HR_7165_OBJECT_LOCKED');
    fnd_message.set_token ('TABLE_NAME','ssp_earnings_calculations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_earnings_calculations_id      in number,
	p_object_version_number         in number,
	p_person_id                     in number,
	p_effective_date                in date,
	p_average_earnings_amount       in number,
	p_user_entered                  in varchar2,
	p_absence_category		in varchar2, --DFoster 1304683
	p_payment_periods		in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.earnings_calculations_id         := p_earnings_calculations_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.person_id                        := p_person_id;
  l_rec.effective_date                   := p_effective_date;
  l_rec.average_earnings_amount          := p_average_earnings_amount;
  l_rec.user_entered                     := p_user_entered;
  l_rec.absence_category		 := p_absence_category; --DFoster 1304683
  l_rec.payment_periods                  := p_payment_periods;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
  Return(l_rec);
--
End convert_args;
--
end ssp_ern_shd;

/
