--------------------------------------------------------
--  DDL for Package Body IRC_IPT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPT_SHD" as
/* $Header: iriptrhi.pkb 120.0 2005/07/26 15:10:09 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipt_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_POSTING_CONTENTS_TL_PK') Then
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
  (p_posting_content_id                   in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       posting_content_id
      ,language
      ,source_language
      ,name
      ,org_name
      ,org_description
      ,job_title
      ,brief_description
      ,detailed_description
      ,job_requirements
      ,additional_details
      ,how_to_apply
      ,benefit_info
      ,image_url
      ,image_url_alt
    from  irc_posting_contents_tl
    where posting_content_id = p_posting_content_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_posting_content_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_posting_content_id
        = irc_ipt_shd.g_old_rec.posting_content_id and
        p_language
        = irc_ipt_shd.g_old_rec.language
       ) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_clob_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into irc_ipt_shd.g_clob_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
     -- Convert clob structure to varchar
     g_old_rec.posting_content_id := g_clob_old_rec.posting_content_id;
     g_old_rec.language := g_clob_old_rec.language;
     g_old_rec.source_language := g_clob_old_rec.source_language;
     g_old_rec.name := g_clob_old_rec.name;
     g_old_rec.org_name := g_clob_old_rec.org_name;
     g_old_rec.job_title := g_clob_old_rec.job_title;
     --
     g_old_rec.org_description
       := dbms_lob.substr(g_clob_old_rec.org_description);
     g_old_rec.brief_description
       := dbms_lob.substr(g_clob_old_rec.brief_description);
     g_old_rec.detailed_description
       := dbms_lob.substr(g_clob_old_rec.detailed_description);
     g_old_rec.job_requirements
       := dbms_lob.substr(g_clob_old_rec.job_requirements);
     g_old_rec.additional_details
       := dbms_lob.substr(g_clob_old_rec.additional_details);
     g_old_rec.how_to_apply
       := dbms_lob.substr(g_clob_old_rec.how_to_apply);
     g_old_rec.benefit_info
       := dbms_lob.substr(g_clob_old_rec.benefit_info);
     g_old_rec.image_url
       := dbms_lob.substr(g_clob_old_rec.image_url);
      g_old_rec.image_url_alt
       := dbms_lob.substr(g_clob_old_rec.image_url_alt);
      --
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
  (p_posting_content_id                   in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       posting_content_id
      ,language
      ,source_language
      ,name
      ,org_name
      ,org_description
      ,job_title
      ,brief_description
      ,detailed_description
      ,job_requirements
      ,additional_details
      ,how_to_apply
      ,benefit_info
      ,image_url
      ,image_url_alt
    from        irc_posting_contents_tl
    where       posting_content_id = p_posting_content_id
    and   language = p_language
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'POSTING_CONTENT_ID'
    ,p_argument_value     => p_posting_content_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_ipt_shd.g_clob_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Convert clob structure to varchar
     g_old_rec.posting_content_id := g_clob_old_rec.posting_content_id;
     g_old_rec.language := g_clob_old_rec.language;
     g_old_rec.source_language := g_clob_old_rec.source_language;
     g_old_rec.name := g_clob_old_rec.name;
     g_old_rec.org_name := g_clob_old_rec.org_name;
     g_old_rec.job_title := g_clob_old_rec.job_title;
     --
  g_old_rec.org_description
     := dbms_lob.substr(g_clob_old_rec.org_description);
  g_old_rec.brief_description
     := dbms_lob.substr(g_clob_old_rec.brief_description);
  g_old_rec.detailed_description
     := dbms_lob.substr(g_clob_old_rec.detailed_description);
  g_old_rec.job_requirements
     := dbms_lob.substr(g_clob_old_rec.job_requirements);
  g_old_rec.additional_details
     := dbms_lob.substr(g_clob_old_rec.additional_details);
  g_old_rec.how_to_apply
     := dbms_lob.substr(g_clob_old_rec.how_to_apply);
  g_old_rec.benefit_info
     := dbms_lob.substr(g_clob_old_rec.benefit_info);
  g_old_rec.image_url
     := dbms_lob.substr(g_clob_old_rec.image_url);
  g_old_rec.image_url_alt
     := dbms_lob.substr(g_clob_old_rec.image_url_alt);
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'irc_posting_contents_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
procedure add_language
is
begin
  delete from IRC_POSTING_CONTENTS_TL T
  where not exists
    (select NULL
    from IRC_POSTING_CONTENTS B
    where B.POSTING_CONTENT_ID = T.POSTING_CONTENT_ID
    );
  update IRC_POSTING_CONTENTS_TL T set (
      NAME,
      ORG_NAME,
      ORG_DESCRIPTION,
      JOB_TITLE,
      BRIEF_DESCRIPTION,
      DETAILED_DESCRIPTION,
      JOB_REQUIREMENTS,
      ADDITIONAL_DETAILS,
      HOW_TO_APPLY,
      BENEFIT_INFO,
      IMAGE_URL,
      IMAGE_URL_ALT
    ) = (select
      B.NAME,
      B.ORG_NAME,
      B.ORG_DESCRIPTION,
      B.JOB_TITLE,
      B.BRIEF_DESCRIPTION,
      B.DETAILED_DESCRIPTION,
      B.JOB_REQUIREMENTS,
      B.ADDITIONAL_DETAILS,
      B.HOW_TO_APPLY,
      B.BENEFIT_INFO,
      B.IMAGE_URL,
      B.IMAGE_URL_ALT
    from IRC_POSTING_CONTENTS_TL B
    where B.POSTING_CONTENT_ID = T.POSTING_CONTENT_ID
    and B.LANGUAGE = T.SOURCE_LANGUAGE)
  where (
      T.POSTING_CONTENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.POSTING_CONTENT_ID,
      SUBT.LANGUAGE
    from IRC_POSTING_CONTENTS_TL SUBB, IRC_POSTING_CONTENTS_TL SUBT
    where SUBB.POSTING_CONTENT_ID = SUBT.POSTING_CONTENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANGUAGE
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.ORG_NAME <> SUBT.ORG_NAME
      or (SUBB.ORG_NAME is null and SUBT.ORG_NAME is not null)
      or (SUBB.ORG_NAME is not null and SUBT.ORG_NAME is null)
      or dbms_lob.compare(SUBB.ORG_DESCRIPTION ,SUBT.ORG_DESCRIPTION) = 0
      or (SUBB.ORG_DESCRIPTION is null and SUBT.ORG_DESCRIPTION is not null)
      or (SUBB.ORG_DESCRIPTION is not null and SUBT.ORG_DESCRIPTION is null)
      or SUBB.JOB_TITLE <> SUBT.JOB_TITLE
      or (SUBB.JOB_TITLE is null and SUBT.JOB_TITLE is not null)
      or (SUBB.JOB_TITLE is not null and SUBT.JOB_TITLE is null)
      or dbms_lob.compare(SUBB.BRIEF_DESCRIPTION , SUBT.BRIEF_DESCRIPTION) = 0
      or (SUBB.BRIEF_DESCRIPTION is null and SUBT.BRIEF_DESCRIPTION is not
      null)
      or (SUBB.BRIEF_DESCRIPTION is not null and SUBT.BRIEF_DESCRIPTION
      is null)
      or dbms_lob.compare(SUBB.DETAILED_DESCRIPTION
      , SUBT.DETAILED_DESCRIPTION) = 0
      or (SUBB.DETAILED_DESCRIPTION is null and SUBT.DETAILED_DESCRIPTION
      is not null)
      or (SUBB.DETAILED_DESCRIPTION is not null and SUBT.DETAILED_DESCRIPTION
      is null)
      or dbms_lob.compare(SUBB.JOB_REQUIREMENTS , SUBT.JOB_REQUIREMENTS) = 0
      or (SUBB.JOB_REQUIREMENTS is null and SUBT.JOB_REQUIREMENTS
      is not null)
      or (SUBB.JOB_REQUIREMENTS is not null and SUBT.JOB_REQUIREMENTS
      is null)
      or dbms_lob.compare(SUBB.ADDITIONAL_DETAILS,SUBT.ADDITIONAL_DETAILS) = 0
      or (SUBB.ADDITIONAL_DETAILS is null and SUBT.ADDITIONAL_DETAILS
      is not null)
      or (SUBB.ADDITIONAL_DETAILS is not null and SUBT.ADDITIONAL_DETAILS
      is null)
      or dbms_lob.compare(SUBB.HOW_TO_APPLY,SUBT.HOW_TO_APPLY) = 0
      or (SUBB.HOW_TO_APPLY is null and SUBT.HOW_TO_APPLY
      is not null)
      or (SUBB.HOW_TO_APPLY is not null and SUBT.HOW_TO_APPLY is null)
      or dbms_lob.compare(SUBB.BENEFIT_INFO,SUBT.BENEFIT_INFO) = 0
      or (SUBB.BENEFIT_INFO is null and SUBT.BENEFIT_INFO is not null)
      or (SUBB.BENEFIT_INFO is not null and SUBT.BENEFIT_INFO is null)
      or dbms_lob.compare(SUBB.IMAGE_URL,SUBT.IMAGE_URL) = 0
      or (SUBB.IMAGE_URL is null and SUBT.IMAGE_URL is not null)
      or (SUBB.IMAGE_URL is not null and SUBT.IMAGE_URL is null)
      or dbms_lob.compare(SUBB.IMAGE_URL_ALT , SUBT.IMAGE_URL_ALT) = 0
      or (SUBB.IMAGE_URL_ALT is null and SUBT.IMAGE_URL_ALT is not null)
      or (SUBB.IMAGE_URL_ALT is not null and SUBT.IMAGE_URL_ALT is null)
  ));
  insert into IRC_POSTING_CONTENTS_TL (
    POSTING_CONTENT_ID,
    SOURCE_LANGUAGE,
    NAME,
    ORG_NAME,
    ORG_DESCRIPTION,
    JOB_TITLE,
    BRIEF_DESCRIPTION,
    DETAILED_DESCRIPTION,
    JOB_REQUIREMENTS,
    ADDITIONAL_DETAILS,
    HOW_TO_APPLY,
    BENEFIT_INFO,
    IMAGE_URL,
    IMAGE_URL_ALT,
    LANGUAGE
  ) select
    B.POSTING_CONTENT_ID,
    B.SOURCE_LANGUAGE,
    B.NAME,
    B.ORG_NAME,
    B.ORG_DESCRIPTION,
    B.JOB_TITLE,
    B.BRIEF_DESCRIPTION,
    B.DETAILED_DESCRIPTION,
    B.JOB_REQUIREMENTS,
    B.ADDITIONAL_DETAILS,
    B.HOW_TO_APPLY,
    B.BENEFIT_INFO,
    B.IMAGE_URL,
    B.IMAGE_URL_ALT,
    L.LANGUAGE_CODE
  from IRC_POSTING_CONTENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IRC_POSTING_CONTENTS_TL T
    where T.POSTING_CONTENT_ID = B.POSTING_CONTENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end add_language;
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_posting_content_id             in number
  ,p_language                       in varchar2
  ,p_source_language                in varchar2
  ,p_name                           in varchar2
  ,p_org_name                       in varchar2
  ,p_org_description                in varchar2
  ,p_job_title                      in varchar2
  ,p_brief_description              in varchar2
  ,p_detailed_description           in varchar2
  ,p_job_requirements               in varchar2
  ,p_additional_details             in varchar2
  ,p_how_to_apply                   in varchar2
  ,p_benefit_info                   in varchar2
  ,p_image_url                      in varchar2
  ,p_image_url_alt                  in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.posting_content_id               := p_posting_content_id;
  l_rec.language                         := p_language;
  l_rec.source_language                  := p_source_language;
  l_rec.name                             := p_name;
  l_rec.org_name                         := p_org_name;
  l_rec.org_description                  := p_org_description;
  l_rec.job_title                        := p_job_title;
  l_rec.brief_description                := p_brief_description;
  l_rec.detailed_description             := p_detailed_description;
  l_rec.job_requirements                 := p_job_requirements;
  l_rec.additional_details               := p_additional_details;
  l_rec.how_to_apply                     := p_how_to_apply;
  l_rec.benefit_info                     := p_benefit_info;
  l_rec.image_url                        := p_image_url;
  l_rec.image_url_alt                    := p_image_url_alt;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
-- ----------------------------------------------------------------------------
-- |------------------------------< clob_dml >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure clob_dml
  (p_rec in out nocopy irc_ipt_shd.g_rec_type
  ,p_api_updating boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'clob_dml';
--
cursor get_rec is
select
 org_description
,brief_description
,detailed_description
,job_requirements
,additional_details
,how_to_apply
,benefit_info
,image_url
,image_url_alt
 from irc_posting_contents_tl
where posting_content_id = p_rec.posting_content_id
and language = p_rec.language;
--
l_org_description      irc_posting_contents_tl.org_description%type;
l_brief_description    irc_posting_contents_tl.brief_description%type;
l_detailed_description irc_posting_contents_tl.detailed_description%type;
l_job_requirements     irc_posting_contents_tl.job_requirements%type;
l_additional_details   irc_posting_contents_tl.additional_details%type;
l_how_to_apply         irc_posting_contents_tl.how_to_apply%type;
l_benefit_info         irc_posting_contents_tl.benefit_info%type;
l_image_url            irc_posting_contents_tl.image_url%type;
l_image_url_alt        irc_posting_contents_tl.image_url_alt%type;
--
l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open get_rec;
  fetch get_rec into
   l_org_description
  ,l_brief_description
  ,l_detailed_description
  ,l_job_requirements
  ,l_additional_details
  ,l_how_to_apply
  ,l_benefit_info
  ,l_image_url
  ,l_image_url_alt;
    if get_rec%notfound then
    close get_rec;
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close get_rec;
  --
  l_api_updating:=p_api_updating;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if (g_org_description_upd
      and l_api_updating
      and dbms_lob.getlength(l_org_description)<=32767
      and dbms_lob.instr(l_org_description,p_rec.org_description)<>1)
  or (not l_api_updating
      and p_rec.org_description is not null) then
    dbms_lob.trim(l_org_description,0);
    dbms_lob.write(l_org_description
                  ,length(p_rec.org_description)
                  ,1
                  ,p_rec.org_description);
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (g_brief_description_upd
      and l_api_updating
      and dbms_lob.getlength(l_brief_description)<=32767
      and dbms_lob.instr(l_brief_description,p_rec.brief_description)<>1)
  or (not l_api_updating
      and p_rec.brief_description is not null) then
    dbms_lob.trim(l_brief_description,0);
    dbms_lob.write(l_brief_description
                  ,length(p_rec.brief_description)
                  ,1
                  ,p_rec.brief_description);
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if (g_detailed_description_upd
      and l_api_updating
      and dbms_lob.getlength(l_detailed_description)<=32767
      and dbms_lob.instr(l_detailed_description,p_rec.detailed_description)<>1)
  or (not l_api_updating
      and p_rec.detailed_description is not null) then
    dbms_lob.trim(l_detailed_description,0);
    dbms_lob.write(l_detailed_description
                  ,length(p_rec.detailed_description)
                  ,1
                  ,p_rec.detailed_description);
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if (g_job_requirements_upd
      and l_api_updating
      and dbms_lob.getlength(l_job_requirements)<=32767
      and dbms_lob.instr(l_job_requirements,p_rec.job_requirements)<>1)
  or (not l_api_updating
      and p_rec.job_requirements is not null) then
    dbms_lob.trim(l_job_requirements,0);
    dbms_lob.write(l_job_requirements
                  ,length(p_rec.job_requirements)
                  ,1
                  ,p_rec.job_requirements);
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  if (g_additional_details_upd
      and l_api_updating
      and dbms_lob.getlength(l_additional_details)<=32767
      and dbms_lob.instr(l_additional_details,p_rec.additional_details)<>1)
  or (not l_api_updating
      and p_rec.additional_details is not null) then
    dbms_lob.trim(l_additional_details,0);
    dbms_lob.write(l_additional_details
                  ,length(p_rec.additional_details)
                  ,1
                  ,p_rec.additional_details);
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  if (g_how_to_apply_upd
      and l_api_updating
      and dbms_lob.getlength(l_how_to_apply)<=32767
      and dbms_lob.instr(l_how_to_apply,p_rec.how_to_apply)<>1)
  or (not l_api_updating
      and p_rec.how_to_apply is not null) then
    dbms_lob.trim(l_how_to_apply,0);
    dbms_lob.write(l_how_to_apply
                  ,length(p_rec.how_to_apply)
                  ,1
                  ,p_rec.how_to_apply);
  end if;
  --
  hr_utility.set_location(l_proc, 70);
  --
  if (g_benefit_info_upd
        and l_api_updating
        and dbms_lob.getlength(l_benefit_info)<=32767
        and dbms_lob.instr(l_benefit_info,p_rec.benefit_info)<>1)
    or (not l_api_updating
        and p_rec.benefit_info is not null) then
      dbms_lob.trim(l_benefit_info,0);
      dbms_lob.write(l_benefit_info
                    ,length(p_rec.benefit_info)
                    ,1
                    ,p_rec.benefit_info);
  end if;
  --
    hr_utility.set_location(l_proc, 80);
  --
  if (g_image_url_upd
      and l_api_updating
      and dbms_lob.getlength(l_image_url)<=32767
      and dbms_lob.instr(l_image_url,p_rec.image_url)<>1)
  or (not l_api_updating
      and p_rec.image_url is not null) then
    dbms_lob.trim(l_image_url,0);
    dbms_lob.write(l_image_url
                  ,length(p_rec.image_url)
                  ,1
                  ,p_rec.image_url);
  end if;
  --
  hr_utility.set_location(l_proc, 90);
  --
  if (g_image_url_alt_upd
      and l_api_updating
      and dbms_lob.getlength(l_image_url_alt)<=32767
      and dbms_lob.instr(l_image_url_alt,p_rec.image_url_alt)<>1)
  or (not l_api_updating
      and p_rec.image_url_alt is not null) then
    dbms_lob.trim(l_image_url_alt,0);
    dbms_lob.write(l_image_url_alt
                  ,length(p_rec.image_url_alt)
                  ,1
                  ,p_rec.image_url_alt);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_ipt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    irc_ipt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_ipt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End clob_dml;
--
--
end irc_ipt_shd;

/
