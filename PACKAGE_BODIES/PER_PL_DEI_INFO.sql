--------------------------------------------------------
--  DDL for Package Body PER_PL_DEI_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_DEI_INFO" AS
/* $Header: pepldeip.pkb 120.1 2006/09/13 11:14:04 mseshadr noship $ */

PROCEDURE VALIDATE_DATES(P_ISSUED_DATE      DATE,
                         P_DATE_FROM        DATE,
                         P_DOCUMENT_NUMBER  VARCHAR2) IS


BEGIN


    /* Issue Date is mandatory  */
     if p_issued_date is null then
        hr_utility.set_message(800,'HR_375884_DEI_DATE_REQD');
        hr_utility.raise_error;
     end if;

     /* Document Number si mandatory */
     if p_document_number is null then
        hr_utility.set_message(800,'HR_375885_DEI_NO_REQD');
        hr_utility.raise_error;
     end if;

-- Issued Date should be same as that of Valid From date.
     if P_ISSUED_DATE <> P_DATE_FROM then
        hr_utility.set_message(800,'HR_375876_INVALID_DEI_DATE');
        hr_utility.raise_error;
     end if;

END VALIDATE_DATES;

PROCEDURE CREATE_PL_DEI_INFO(P_PERSON_ID                 NUMBER,
                             P_DOCUMENT_TYPE_ID          NUMBER,
                             P_DOCUMENT_NUMBER           VARCHAR2,
                             P_ISSUED_DATE               DATE,
                             P_DATE_FROM                 DATE,
                             P_DATE_TO                   DATE) IS

cursor csr_document_type is
   select system_document_type from hr_document_types
           where document_type_id = p_document_type_id;

cursor csr_doc_exists is
   select null from hr_document_extra_info
    where person_id = p_person_id
      and document_type_id = p_document_type_id
      and (date_from between p_date_from and p_date_to or
           date_to between p_date_from and p_date_to or
           p_date_from between date_from and date_to);

l_exists varchar2(1);
l_sys_doc_type hr_document_types.system_document_type%TYPE;
l_proc varchar2(18);
BEGIN
l_proc:='CREATE_PL_DEI_INFO';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
 open csr_document_type;
  fetch csr_document_type into l_sys_doc_type;
 close csr_document_type;

 if l_sys_doc_type in ('PL_PASSPORT','PL_IDENTITY_CARD','PL_MILITARY_BOOK') then

  VALIDATE_DATES(P_ISSUED_DATE      => p_issued_date,
                 P_DATE_FROM        => p_date_from,
                 P_DOCUMENT_NUMBER  => p_document_number);

 end if;


-- Another document of the same type should not exists in the same period when the current record
-- is created
/* Do the validations only for Passport and Identity Card  */

if l_sys_doc_type in ('PL_PASSPORT','PL_IDENTITY_CARD') then

    open csr_doc_exists;
     fetch csr_doc_exists into l_exists;
       if csr_doc_exists%FOUND then
          hr_utility.set_message(800,'HR_375877_OVERLAP_DEI_INFO');
          hr_utility.raise_error;
       end if;
    close csr_doc_exists;

end if;

END CREATE_PL_DEI_INFO;



PROCEDURE UPDATE_PL_DEI_INFO(P_DOCUMENT_EXTRA_INFO_ID    NUMBER,
                             P_DOCUMENT_TYPE_ID          NUMBER,
                             P_DOCUMENT_NUMBER           VARCHAR2,
                             P_PERSON_ID                 NUMBER,
                             P_DATE_FROM                 DATE,
                             P_DATE_TO                   DATE,
                             P_ISSUED_DATE               DATE) IS

cursor csr_document_type is
   select system_document_type from hr_document_types
           where document_type_id = p_document_type_id;

cursor csr_doc_exists is
   select null from hr_document_extra_info
    where person_id = p_person_id
      and document_type_id = p_document_type_id
      and (date_from between p_date_from and p_date_to or
           date_to between p_date_from and p_date_to or
           p_date_from between date_from and date_to)
      and document_extra_info_id <> p_document_extra_info_id;

l_exists varchar2(1);
l_sys_doc_type hr_document_types.system_document_type%TYPE;
l_proc varchar2(18);
BEGIN
l_proc:='UPDATE_PL_DEI_INFO';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;

 open csr_document_type;
  fetch csr_document_type into l_sys_doc_type;
 close csr_document_type;

 if l_sys_doc_type in ('PL_PASSPORT','PL_IDENTITY_CARD','PL_MILITARY_BOOK') then

  VALIDATE_DATES(P_ISSUED_DATE      => p_issued_date,
                 P_DATE_FROM        => p_date_from,
                 P_DOCUMENT_NUMBER  => p_document_number);

 end if;

-- Another document of the same type should not exists in the same period when the current record
-- is created

/* Do the validations only for Passport and Identity Card  */

if l_sys_doc_type in ('PL_PASSPORT','PL_IDENTITY_CARD') then

    open csr_doc_exists;
     fetch csr_doc_exists into l_exists;
       if csr_doc_exists%FOUND then
          hr_utility.set_message(800,'HR_375877_OVERLAP_DEI_INFO');
          hr_utility.raise_error;
       end if;
    close csr_doc_exists;

end if;

END UPDATE_PL_DEI_INFO;

END PER_PL_DEI_INFO;

/
