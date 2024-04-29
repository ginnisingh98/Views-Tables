--------------------------------------------------------
--  DDL for Package Body PQH_RNK_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RNK_SHD" as
/* $Header: pqrnkrhi.pkb 120.1 2005/06/23 13:27 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package constant varchar2(33) := '  pqh_rnk_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc constant       varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PQH_RANK_PROCESSES_PK') Then
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
  (p_rank_process_id                      in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       rank_process_id
      ,pgm_id
      ,pl_id
      ,oipl_id
      ,process_cd
      ,process_date
      ,benefit_action_id
      ,person_id
      ,assignment_id
      ,total_score
      ,object_version_number
      ,request_id
      ,business_group_id
      ,per_in_ler_id
    from        pqh_rank_processes
    where       rank_process_id = p_rank_process_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_rank_process_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_rank_process_id
        = pqh_rnk_shd.g_old_rec.rank_process_id and
        p_object_version_number
        = pqh_rnk_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_rnk_shd.g_old_rec;
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
          <> pqh_rnk_shd.g_old_rec.object_version_number) Then
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
  (p_rank_process_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       rank_process_id
      ,pgm_id
      ,pl_id
      ,oipl_id
      ,process_cd
      ,process_date
      ,benefit_action_id
      ,person_id
      ,assignment_id
      ,total_score
      ,object_version_number
      ,request_id
      ,business_group_id
      ,per_in_ler_id
    from        pqh_rank_processes
    where       rank_process_id = p_rank_process_id
    for update nowait;
--
  l_proc constant      varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RANK_PROCESS_ID'
    ,p_argument_value     => p_rank_process_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_rnk_shd.g_old_rec;
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
      <> pqh_rnk_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_rank_processes');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_rank_process_id                in number
  ,p_pgm_id                         in number
  ,p_pl_id                          in number
  ,p_oipl_id                        in number
  ,p_process_cd                     in varchar2
  ,p_process_date                   in date
  ,p_benefit_action_id              in number
  ,p_person_id                      in number
  ,p_assignment_id                  in number
  ,p_total_score                    in number
  ,p_object_version_number          in number
  ,p_request_id                     in number
  ,p_business_group_id              in number
  ,p_per_in_ler_id                  in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.rank_process_id                  := p_rank_process_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.process_cd                       := p_process_cd;
  l_rec.process_date                     := p_process_date;
  l_rec.benefit_action_id                := p_benefit_action_id;
  l_rec.person_id                        := p_person_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.total_score                      := p_total_score;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.request_id                       := p_request_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_rnk_shd;

/
