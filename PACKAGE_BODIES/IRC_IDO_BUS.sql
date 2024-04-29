--------------------------------------------------------
--  DDL for Package Body IRC_IDO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IDO_BUS" as
/* $Header: iridorhi.pkb 120.5.12010000.2 2008/09/26 13:55:20 pvelugul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ido_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_document_id                 number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_document_id                          in number
  ) is
  --
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'document_id'
    ,p_argument_value     => p_document_id
    );
  --
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_document_id                          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(100);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'document_id'
    ,p_argument_value     => p_document_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_party_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates the party_id exists in HZ_PARTIES, on insert.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_party_id number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_party_id does not exist in HZ_PARTIES
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_party_id(p_party_id in number) is
--
  l_proc varchar2(72) := g_package||'chk_party_id';
--
  l_party_id hz_parties.party_id%type ;
  cursor csr_valid_party is
    select hp.party_id
    from hz_parties hp
    where hp.party_id = p_party_id;
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check the party_id being passed exists on HZ_PARTIES table.
  --
  open csr_valid_party;
  fetch csr_valid_party into l_party_id;
  if csr_valid_party%notfound then
    close csr_valid_party;
    hr_utility.set_message(800,'IRC_289477_RTM_INV_PARTY_ID');
    hr_utility.raise_error;
  end if;
  close csr_valid_party;
  --
  hr_utility.set_location('Exiting: '|| l_proc, 2);
end chk_party_id;
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_person_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been set.
--   If the person id is not found in per_all_people_f an error is generated.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_person_id
--   p_party_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_rec.p_person_id does not exist in PER_ALL_PEOPLE_F
--
-- Access Status:
--   Internal Table Handler Use Only.
 Procedure chk_person_id
  (p_person_id in irc_documents.person_id%type
  ,p_party_id in out nocopy irc_documents.party_id%type
  ,p_effective_date date) is
 --
  l_proc     varchar2(72) := g_package || 'chk_person_id';
  l_party_id irc_documents.party_id%type;
  l_var varchar2(30);
  --
  --
  --   Cursor to check that the person_id exists in PER_ALL_PEOPLE_F.
  --
  cursor csr_person_id is
    select per.party_id
      from per_all_people_f per
     where per.person_id = p_person_id
          and p_effective_date between effective_start_date and effective_end_date;
  Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  -- Check if the person_id exists in PER_ALL_PEOPLE_F.
  --
  open csr_person_id;
  fetch csr_person_id into l_party_id;
  hr_utility.set_location(l_proc, 30);
  if csr_person_id%notfound then
    close csr_person_id;
    fnd_message.set_name('PER','IRC_412249_DOC_NO_PERSON');
    fnd_message.raise_error;
  end if;
  close csr_person_id;
  if p_party_id is not null then
    if p_party_id<>l_party_id then
      fnd_message.set_name('PER','IRC_412033_RTM_INV_PARTY_ID');
      fnd_message.raise_error;
    end if;
  else
    p_party_id:=l_party_id;
  end if;
--
End chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_monthly_doc_upload_count >-----------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the number of documents that
--   can be inserted in the last month is limited to the value
--   specified by profile, IRC_MONTHLY_DOC_UPLOAD_COUNT.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_person_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised if the
--   number of document rows inserted for p_person_id exceeds
--   the value given by profile, IRC_MONTHLY_DOC_UPLOAD_COUNT
--   in the last month
--
-- Access Status:
--   Internal Table Handler Use Only.
 Procedure chk_monthly_doc_upload_count
  (p_person_id in irc_documents.person_id%type
  ,p_effective_date date) is
 --
  l_proc     varchar2(72) := g_package || 'chk_monthly_doc_upload_count';
  l_count    number;
  l_max_count number;
  --
  --
  --   Cursor to check that document upload count not exceeded in last month
  --
  cursor csr_doc_upload_count is
    select count(*)
      from irc_documents doc
      where doc.person_id = p_person_id
      and  doc.end_date is null
          and months_between(p_effective_date,doc.creation_date) <= 1;
  Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  --
  open csr_doc_upload_count;
  fetch csr_doc_upload_count into l_count;
  close csr_doc_upload_count;
  hr_utility.set_location(l_proc, 20);
  l_max_count := to_number(fnd_profile.value('IRC_MONTHLY_DOC_UPLOAD_COUNT'));
  if l_count >= l_max_count then
    hr_utility.set_location(l_proc, 30);
    fnd_message.set_name('PER','IRC_MAX_DOC_UPLOADS_EXCEEDED');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location('Leaving'||l_proc, 40);
--
End chk_monthly_doc_upload_count;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_total_doc_upload_count >-----------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the number of documents that
--   can be inserted for a person is limited to the value
--   specified by profile, IRC_TOTAL_DOC_UPLOAD_COUNT.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_person_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised if the
--   number of document rows inserted for p_person_id exceeds
--   the value given by profile, IRC_TOTAL_DOC_UPLOAD_COUNT
--
-- Access Status:
--   Internal Table Handler Use Only.
 Procedure chk_total_doc_upload_count
  (p_person_id in irc_documents.person_id%type ) is
 --
  l_proc     varchar2(72) := g_package || 'chk_total_doc_upload_count';
  l_count    number;
  l_max_count number;
  --
  --
  --   Cursor to check that document upload count not exceeded in last month
  --
  cursor csr_doc_upload_count is
    select count(*)
      from irc_documents doc
      where doc.person_id = p_person_id
      and  doc.end_date is null;
  Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  --
  open csr_doc_upload_count;
  fetch csr_doc_upload_count into l_count;
  close csr_doc_upload_count;
  hr_utility.set_location(l_proc, 20);
  l_max_count := to_number(fnd_profile.value('IRC_TOTAL_DOC_UPLOAD_COUNT'));
  if l_count >= l_max_count then
    hr_utility.set_location(l_proc, 30);
    fnd_message.set_name('PER','IRC_TOT_DOC_UPLOADS_EXCEEDED');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location('Leaving'||l_proc, 40);
--
End chk_total_doc_upload_count;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_type >---------------------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates the document type exists in the lookup
--   IRC_DOCUMENT_TYPE
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   type                  varchar2(30) document type
--   document_id           number(15)   PK of IRC_DOCUMENTS
--   object_version_number number(9)    version of row
--   effective_date        date         date record effective
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_type does not exist in lookup IRC_DOCUMENT_TYPE
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_type(p_type in varchar2,
                   p_document_id in number,
                   p_effective_date in date,
                   p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_type';
  l_api_updating boolean;
--
begin
    hr_utility.set_location('Entering: '|| l_proc, 1);
    l_api_updating := irc_ido_shd.api_updating
           (p_document_id                 => p_document_id,
            p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating
      and nvl(p_type,hr_api.g_varchar2)
          <> nvl(irc_ido_shd.g_old_rec.type,hr_api.g_varchar2)
      or not l_api_updating) then
      --
      -- check if value of type falls within lookup.
      --
      if hr_api.not_exists_in_hr_lookups(p_lookup_type  => 'IRC_DOCUMENT_TYPE',
                                         p_lookup_code    => p_type,
                                         p_effective_date => p_effective_date)
                                        then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_location('Leaving: '|| l_proc, 3);
        hr_utility.set_message(800,'IRC_412089_NO_SUCH_DOC_TYPE');
        hr_utility.raise_error;
      end if;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 2);
end chk_type;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in irc_ido_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ido_shd.api_updating
      (p_document_id                          => p_rec.document_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_person_id
   (p_person_id => p_rec.person_id
   ,p_party_id  => p_rec.party_id
   ,p_effective_date => p_effective_date
   );
  --
  chk_type
    (p_type                          => p_rec.type,
     p_document_id                   => p_rec.document_id,
     p_effective_date                => p_effective_date,
     p_object_version_number         => p_rec.object_version_number);
  --
 -- chk_total_doc_upload_count
--   (p_person_id => p_rec.person_id
 --  );
  --
 -- chk_monthly_doc_upload_count
 --  (p_person_id => p_rec.person_id
  -- ,p_effective_date => p_effective_date
  -- );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_type
    (p_type                          => p_rec.type,
     p_document_id                   => p_rec.document_id,
     p_effective_date                => p_effective_date,
     p_object_version_number         => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end irc_ido_bus;

/
