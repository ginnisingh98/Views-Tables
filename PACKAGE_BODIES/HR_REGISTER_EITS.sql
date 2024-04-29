--------------------------------------------------------
--  DDL for Package Body HR_REGISTER_EITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_REGISTER_EITS" AS
/* $Header: peregeit.pkb 120.5 2006/08/09 20:32:24 nsanghal noship $ */

PROCEDURE create_eit(
                 errbuf           OUT nocopy  VARCHAR2,
                 retcode          OUT nocopy  VARCHAR2,
                 p_table_name     IN  varchar2,
                 p_info_type_name IN  varchar2,
                 p_active_flag    IN  varchar2,
                 p_multi_row      IN  varchar2,
		 p_leg_code       IN  varchar2 default null,
                 p_desc           IN  varchar2,
                 p_org_class      IN  varchar2,
                 p_category_code  IN  varchar2 default null,
		 p_sub_category_code      IN varchar2 default null,
	         p_authorization_required IN varchar2 default null,
                 p_warning_period IN number default null,
		 p_application_id IN NUMBER default null
                 )
  IS
   v_table_name varchar2(30)     := upper(p_table_name);
   v_info_type_name varchar2(30) := p_info_type_name;
   v_active_flag varchar2(1)     := upper(p_active_flag);
   v_multi_row varchar2(1)       := upper(p_multi_row);
   v_desc varchar2(240)          := p_desc;
   v_leg_code varchar2(4)        := upper(p_leg_code);
   v_org_class varchar2(30)      := upper(p_org_class);

   l_info_type varchar2(80);
   l_info_count number;
   l_insert     varchar2(2000):= 'The Information Type: ' || v_info_type_name  || ' has been inserted into the table: ' || v_table_name;
   l_fail     varchar2(2000):= 'The Information Type: ' || v_info_type_name  || ' already exists in the table: ' || v_table_name;
--Added
   l_show_error varchar2(2000);
--

/* 4197450 Start of Fix */

   l_created_by	    number :=  fnd_profile.value('USER_ID');
   l_updated_by     number := fnd_profile.value('USER_ID');
   l_update_login   number := fnd_profile.value('USER_ID');
   l_creation_date  date   := trunc(sysdate);
   l_update_date    date   := trunc(sysdate);
   l_navig_method   varchar2(5);

/* 4197450 End of Fix */

/* START Added for Documents Of Record */

   l_category_code varchar2(30)     := p_category_code;
   l_sub_category_code varchar2(30) := p_sub_category_code;
   l_authorization_required varchar2(10) := upper(p_authorization_required);
   l_warning_period number          := p_warning_period;
   l_request_id number;
   l_program_application_id number;
   l_program_id number;
   l_ovn number;
   l_doc_type_id number;


/* END Added for Documents Of Record */
--Added
   l_application_id number       := p_application_id;
--


begin

if v_table_name = 'PER_PEOPLE_INFO_TYPES' then

     INSERT INTO PER_PEOPLE_INFO_TYPES
     (INFORMATION_TYPE
     ,ACTIVE_INACTIVE_FLAG
     ,MULTIPLE_OCCURENCES_FLAG
     ,DESCRIPTION
     ,LEGISLATION_CODE
     ,OBJECT_VERSION_NUMBER)
     VALUES
     (v_info_type_name
     ,v_active_flag
     ,v_multi_row
     ,v_desc
     ,v_leg_code
     ,1);

     fnd_file.put_line(fnd_file.log,l_insert);


--

elsif v_table_name = 'PER_ASSIGNMENT_INFO_TYPES' then
--
      INSERT INTO PER_ASSIGNMENT_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);
   --
      fnd_file.put_line(fnd_file.log,l_insert);

      insert into PER_ASSIGNMENT_INFO_TYPES_TL
      (INFORMATION_TYPE
      ,LANGUAGE
      ,SOURCE_LANG
      ,DESCRIPTION
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,CREATED_BY
      ,CREATION_DATE
      )
      select M.INFORMATION_TYPE
      ,L.LANGUAGE_CODE
      ,B.LANGUAGE_CODE
      ,M.DESCRIPTION
      ,M.LAST_UPDATE_DATE
      ,M.LAST_UPDATED_BY
      ,M.LAST_UPDATE_LOGIN
      ,M.CREATED_BY
      ,M.CREATION_DATE
      from PER_ASSIGNMENT_INFO_TYPES M
          ,FND_LANGUAGES L
          ,FND_LANGUAGES B
      where M.INFORMATION_TYPE = v_info_type_name
      and   L.INSTALLED_FLAG in ('I', 'B')
      and   B.INSTALLED_FLAG   = 'B'
      and   not exists (select '1'
                       from  per_assignment_info_types_tl pait
                       where pait.information_type = m.information_type
                       and   pait.language         = l.language_code);
      --
      fnd_file.put_line(fnd_file.log,l_insert);


elsif v_table_name = 'PER_POSITION_INFO_TYPES' then
--
      INSERT INTO PER_POSITION_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);

      fnd_file.put_line(fnd_file.log,l_insert);


elsif v_table_name = 'PQP_VEH_ALLOC_INFO_TYPES' then
--
      INSERT INTO PQP_VEH_ALLOC_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);

      fnd_file.put_line(fnd_file.log,l_insert);


elsif v_table_name = 'PQP_VEH_REPOS_INFO_TYPES' then
--
      INSERT INTO PQP_VEH_REPOS_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);

      fnd_file.put_line(fnd_file.log,l_insert);

elsif v_table_name = 'HR_LOCATION_INFO_TYPES' then
   --
      INSERT INTO HR_LOCATION_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);

      fnd_file.put_line(fnd_file.log,l_insert);
   --
elsif v_table_name = 'PER_JOB_INFO_TYPES' then
--

      INSERT INTO PER_JOB_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);

       fnd_file.put_line(fnd_file.log,l_insert);

elsif v_table_name = 'PER_CONTACT_INFO_TYPES' then
--

      INSERT INTO PER_CONTACT_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_leg_code
      ,1);

   fnd_file.put_line(fnd_file.log,l_insert);
   --
      insert into PER_CONTACT_INFO_TYPES_TL
      (INFORMATION_TYPE
      , LANGUAGE
      , SOURCE_LANG
      , DESCRIPTION
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , CREATED_BY
      , CREATION_DATE
   )
   select M.INFORMATION_TYPE
      , L.LANGUAGE_CODE
      , B.LANGUAGE_CODE
      , v_desc
      , M.LAST_UPDATE_DATE
      , M.LAST_UPDATED_BY
      , M.LAST_UPDATE_LOGIN
      , M.CREATED_BY
      , M.CREATION_DATE
   from PER_CONTACT_INFO_TYPES M
      , FND_LANGUAGES L
      , FND_LANGUAGES B
   where  M.INFORMATION_TYPE = v_info_type_name
   and    L.INSTALLED_FLAG in ('I', 'B')
   and    B.INSTALLED_FLAG   = 'B'
   and not exists ( select '1'
                    from per_contact_info_types_tl pcit
                    where pcit.information_type = m.information_type
                    and pcit.language           = l.language_code);

   fnd_file.put_line(fnd_file.log,l_insert);
   --

elsif v_table_name = 'PER_PREV_JOB_INFO_TYPES' then
--

      INSERT INTO PER_PREV_JOB_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURANCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);

       fnd_file.put_line(fnd_file.log,l_insert);

elsif v_table_name = 'PAY_ELEMENT_TYPE_INFO_TYPES' then
--
      INSERT INTO PAY_ELEMENT_TYPE_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);

      fnd_file.put_line(fnd_file.log,l_insert);

  /* Changes  Added to support BEN EITs start here */

  elsif v_table_name = 'BEN_OPT_INFO_TYPES' then
--
      INSERT INTO  BEN_OPT_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);
   fnd_file.put_line(fnd_file.log,l_insert);

  --
    elsif v_table_name = 'BEN_ABR_INFO_TYPES' then
--
      INSERT INTO BEN_ABR_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);
   fnd_file.put_line(fnd_file.log,l_insert);
   --
     elsif v_table_name = 'BEN_PL_INFO_TYPES' then
--
      INSERT INTO BEN_PL_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);
   fnd_file.put_line(fnd_file.log,l_insert);
   --
     elsif v_table_name = 'BEN_ELP_INFO_TYPES' then
--
      INSERT INTO BEN_ELP_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);
   fnd_file.put_line(fnd_file.log,l_insert);
   --
     elsif v_table_name = 'BEN_LER_INFO_TYPES' then
--
      INSERT INTO BEN_LER_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);
   fnd_file.put_line(fnd_file.log,l_insert);
   --
     elsif v_table_name = 'BEN_PGM_INFO_TYPES' then
--
      INSERT INTO BEN_PGM_INFO_TYPES
      (INFORMATION_TYPE
      ,ACTIVE_INACTIVE_FLAG
      ,MULTIPLE_OCCURENCES_FLAG
      ,DESCRIPTION
      ,LEGISLATION_CODE
      ,OBJECT_VERSION_NUMBER)
      VALUES
      (v_info_type_name
      ,v_active_flag
      ,v_multi_row
      ,v_desc
      ,v_leg_code
      ,1);
   fnd_file.put_line(fnd_file.log,l_insert);
   --

  /* Changes  Added to support BEN EITs end here */
/* 4197450 Start of Fix */
  elsif v_table_name = 'HR_ORG_INFORMATION_TYPES' then

    if v_multi_row = 'N' then
       l_navig_method := 'GS';
    else
       l_navig_method := 'GM';
    end if;

    if v_desc is NULL then
       v_desc := v_info_type_name;
    end if;

    if p_application_id is not null then
   begin
     begin
	hr_org_information_types_pkg.insert_row
						(v_info_type_name
						 ,null
						 ,v_leg_code
						 ,l_navig_method
						 ,l_application_id
						 ,v_desc
						 ,v_desc
						 ,l_creation_date
						 ,l_created_by
						 ,l_update_date
						 ,l_updated_by
						 ,l_update_login);

      fnd_file.put_line(fnd_file.log,l_insert);
     EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line(fnd_file.log,l_fail);
     end;

      INSERT INTO HR_ORG_INFO_TYPES_BY_CLASS
 	 (ORG_CLASSIFICATION
	 ,ORG_INFORMATION_TYPE
	 ,MANDATORY_FLAG
         ,ENABLED_FLAG )
	 SELECT
	  v_org_class
	 ,v_info_type_name
	 ,'N'
         ,'Y'
	 FROM sys.dual
	 WHERE not exists (SELECT 1
	 FROM HR_ORG_INFO_TYPES_BY_CLASS
	 WHERE ORG_INFORMATION_TYPE =v_info_type_name
	 and ORG_CLASSIFICATION = v_org_class);

      l_insert := 'The Information has been inserted into the table HR_ORG_INFO_TYPES_BY_CLASS for Organization Classification ' || v_org_class;

      fnd_file.put_line(fnd_file.log,l_insert);
    EXCEPTION
      WHEN OTHERS THEN
           fnd_file.put_line(fnd_file.log,l_fail);
  end;

  else
--The following has been added to return error if application id is not entered.
    retcode := '2';
    l_show_error:= 'Please enter the mandatory application for HR_ORG_INFORMATION_TYPES';
    fnd_file.put_line(fnd_file.log,l_show_error);
--
  end if;


/* 4197450 End of Fix */


/* START Added elsif block for Documents Of Record */

   elsif v_table_name = 'HR_DOCUMENT_TYPES' then

begin

  l_request_id             := fnd_global.conc_request_id;
  l_program_application_id := fnd_global.prog_appl_id;
  l_program_id             := fnd_global.conc_program_id;
  l_insert                 := 'The Document Type : "' || p_info_type_name || '" has been created';
  l_fail                   := 'Error while creating document type : "' || p_info_type_name || '"';

  hr_document_types_api.create_document_type
  (
   p_description                    => v_desc
  ,p_document_type                  => v_info_type_name
  ,p_category_code                  => l_category_code
  ,p_active_inactive_flag           => v_active_flag
  ,p_multiple_occurences_flag       => v_multi_row
  ,p_authorization_required         => l_authorization_required
  ,p_sub_category_code              => l_sub_category_code
  ,p_legislation_code               => v_leg_code
  ,p_warning_period                 => l_warning_period
  ,p_program_application_id         => l_program_application_id
  ,p_program_id                     => l_program_id
  ,p_request_id                     => l_request_id
  ,p_document_type_id               => l_doc_type_id
  ,p_object_version_number          => l_ovn
  );

   fnd_file.put_line(fnd_file.log,l_insert);
exception
when others then
  retcode:='1';
  fnd_file.put_line(fnd_file.log,l_fail);
  fnd_file.put_line(fnd_file.log,sqlerrm);

end;


 /* END Added elsif block for Documents Of Record */
else

     fnd_file.put_line(fnd_file.log,'Error - user entered invalid or unsupported table name');

     raise VALUE_ERROR;

end if;

EXCEPTION

   WHEN OTHERS THEN

   fnd_file.put_line(fnd_file.log,l_fail);
   --
END;

end;

/
