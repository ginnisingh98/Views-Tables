--------------------------------------------------------
--  DDL for Package Body PER_ADDRESSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADDRESSES_PKG" AS
/* $Header: peadd01t.pkb 120.0 2005/05/31 04:51:59 appldev noship $ */

g_pkg  CONSTANT Varchar2(150):='PER_Addresses_Pkg.';
-- ===========================================================================
-- InsUpd_OSS_Person_Add: Insert or Update address into hz_locations only if
-- the person is a student or faculty employee.
-- p_action         : Valid Values INSERT and UPDATE
-- p_effective_date :
-- ===========================================================================
PROCEDURE InsUpd_OSS_Person_Add
          (p_addr_rec_new   in per_addresses%ROWTYPE
          ,p_addr_rec_old   in per_addresses%ROWTYPE
          ,p_action         in varchar2
          ,p_effective_date in date
          )  As
   -- Cursor to check if person is student
   CURSOR csr_stu (c_person_id IN Number) IS
    SELECT pei.pei_information5
      FROM per_people_extra_info  pei
     WHERE pei.information_type         = 'PQP_OSS_PERSON_DETAILS'
       AND pei.pei_information_category = 'PQP_OSS_PERSON_DETAILS'
       AND pei.person_id                = c_person_id;

  l_rowid               ROWID;
  --
  l_party_site_id       Number;
  l_location_id         Number;
  l_location_ovn        Number;
  l_party_site_ovn      Number;
  l_hz_loc_rowid        Rowid;
  l_hz_loc_upd_dt       Date;
  l_last_update_date    Date;
  l_return_flag         Boolean;
  l_Stu_OSSData_Sync    Varchar2(5);
  l_return_status       Varchar2(5);
  l_msg_data            Varchar2(2000);
  l_error_msg           Varchar2(2000);
  l_proc_name  CONSTANT Varchar2(150):= g_pkg||'InsUpd_OSS_Person_Add';
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  l_return_flag := False;
  OPEN csr_stu (c_person_id => p_addr_rec_new.person_id);
  FETCH csr_stu INTO l_Stu_OSSData_Sync;
  CLOSE csr_stu;
  --
  IF Nvl(l_Stu_OSSData_Sync,'-1') <> 'Y'  OR
     Nvl(p_addr_rec_new.primary_flag,'-1')     <> 'Y'  OR
     Nvl(Fnd_Profile.VALUE('HZ_PROTECT_HR_PERSON_INFO'),'-1') <> 'N' OR
     p_addr_rec_new.party_id IS NULL
     THEN
     l_return_flag := TRUE;
  END IF;
  Hr_Utility.set_location('..person_id  : '||p_addr_rec_new.person_id, 6);
  Hr_Utility.set_location('..sync Flag  : '||l_Stu_OSSData_Sync, 6);
  Hr_Utility.set_location('..party_id   : '||p_addr_rec_new.party_id , 6);
  Hr_Utility.set_location('..Bus Grp Id : '||p_addr_rec_new.business_group_id, 6);
  -- Return if any of the above conditions are true
  IF l_return_flag THEN
     Hr_Utility.set_location('..Returning : '||l_proc_name,7 );
     RETURN;
  END IF;

  If p_action = 'UPDATE' AND
     Not l_return_flag       THEN
     Hr_Utility.set_location('..p_action : '||p_action,9 );
     Pqp_Hrtca_Integration.Update_Address_HR_To_TCA
     (p_business_group_id      => p_addr_rec_new.business_group_id
     ,p_person_id              => p_addr_rec_new.person_id
     ,p_party_id               => p_addr_rec_new.party_id
     ,p_address_id             => p_addr_rec_new.address_id
     ,p_effective_date         => p_effective_date
     ,p_per_addr_rec_new       => p_addr_rec_new
     ,p_per_addr_rec_old       => p_addr_rec_old
      -- TCA
     ,p_party_type             => 'PERSON'
     ,p_action                 => p_action
     ,p_status                 => 'A'
      -- In Out Variables
     ,p_location_id            => l_location_id
     ,p_party_site_id          => l_party_site_id
     ,p_last_update_date       => l_hz_loc_upd_dt
     ,p_party_site_ovn         => l_party_site_ovn
     ,p_location_ovn           => l_location_ovn
     ,p_rowid                  => l_hz_loc_rowid
      -- Out Variables
     ,p_return_status          => l_return_status
     ,p_msg_data               => l_msg_data
     );
  ELSIF p_action = 'INSERT' AND
        Not l_return_flag      THEN
     Hr_Utility.set_location('..p_action : '||p_action,9 );
     Pqp_Hrtca_Integration.Create_Address_HR_To_TCA
     (p_business_group_id      => p_addr_rec_new.business_group_id
     ,p_person_id              => p_addr_rec_new.person_id
     ,p_party_id               => p_addr_rec_new.party_id
     ,p_address_id             => p_addr_rec_new.address_id
     ,p_effective_date         => p_effective_date
     ,p_per_addr_rec_new       => p_addr_rec_new
      -- TCA
     ,p_party_type             => 'PERSON'
     ,p_action                 => p_action
     ,p_status                 => 'A'
      -- In Out Variables
     ,p_location_id            => l_location_id
     ,p_party_site_id          => l_party_site_id
     ,p_last_update_date       => l_last_update_date
     ,p_party_site_ovn         => l_party_site_ovn
     ,p_location_ovn           => l_location_ovn
     ,p_rowid                  => l_rowid
      -- Out Variables
     ,p_return_status          => l_return_status
     ,p_msg_data               => l_msg_data
     );
  END IF;
  IF l_return_status IN ('E','U') THEN
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_msg_data );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;
  END IF;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
  WHEN OTHERS THEN
    l_error_msg := Substrb(l_msg_data,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;

END InsUpd_OSS_Person_Add;

/*
  Procedure to perform DML on the table PER_ADDRESSES
  when it is used in Forms which utilise the Base View method
*/
--
--
procedure insert_row(p_row_id in out nocopy VARCHAR2
      ,p_address_id           in out nocopy NUMBER
      ,p_business_group_id           NUMBER
      ,p_person_id                   NUMBER
      ,p_date_from                   DATE
      ,p_primary_flag                VARCHAR2
      ,p_style                       VARCHAR2
      ,p_address_line1               VARCHAR2
      ,p_address_line2               VARCHAR2
      ,p_address_line3               VARCHAR2
      ,p_address_type                VARCHAR2
      ,p_comments                    VARCHAR2
      ,p_country                     VARCHAR2
      ,p_date_to                     DATE
      ,p_postal_code                 VARCHAR2
      ,p_region_1                    VARCHAR2
      ,p_region_2                    VARCHAR2
      ,p_region_3                    VARCHAR2
      ,p_telephone_number_1          VARCHAR2
      ,p_telephone_number_2          VARCHAR2
      ,p_telephone_number_3          VARCHAR2
      ,p_town_or_city                VARCHAR2
      ,p_request_id                  NUMBER
      ,p_program_application_id      NUMBER
      ,p_program_id                  NUMBER
      ,p_program_update_date         DATE
      ,p_addr_attribute_category     VARCHAR2
      ,p_addr_attribute1             VARCHAR2
      ,p_addr_attribute2             VARCHAR2
      ,p_addr_attribute3             VARCHAR2
      ,p_addr_attribute4             VARCHAR2
      ,p_addr_attribute5             VARCHAR2
      ,p_addr_attribute6             VARCHAR2
      ,p_addr_attribute7             VARCHAR2
      ,p_addr_attribute8             VARCHAR2
      ,p_addr_attribute9             VARCHAR2
      ,p_addr_attribute10            VARCHAR2
      ,p_addr_attribute11            VARCHAR2
      ,p_addr_attribute12            VARCHAR2
      ,p_addr_attribute13            VARCHAR2
      ,p_addr_attribute14            VARCHAR2
      ,p_addr_attribute15            VARCHAR2
      ,p_addr_attribute16            VARCHAR2
      ,p_addr_attribute17            VARCHAR2
      ,p_addr_attribute18            VARCHAR2
      ,p_addr_attribute19            VARCHAR2
      ,p_addr_attribute20            VARCHAR2
-- ***** Start new code for bug 2711964 **************
      ,p_add_information13           VARCHAR2
      ,p_add_information14           VARCHAR2
      ,p_add_information15           VARCHAR2
      ,p_add_information16           VARCHAR2
-- ***** End new code for bug 2711964 ***************
      ,p_add_information17           VARCHAR2
      ,p_add_information18           VARCHAR2
      ,p_add_information19           VARCHAR2
      ,p_add_information20           VARCHAR2
      ,p_end_of_time                 DATE DEFAULT  to_date('31-12-4712','DD-MM-YYYY')
       ) is
--
-- Local Variables
--
l_default_primary VARCHAR2(1);
begin
per_addresses_pkg.insert_row(p_row_id
      ,p_address_id
      ,p_business_group_id
      ,p_person_id
      ,p_date_from
      ,p_primary_flag
      ,p_style
      ,p_address_line1
      ,p_address_line2
      ,p_address_line3
      ,p_address_type
      ,p_comments
      ,p_country
      ,p_date_to
      ,p_postal_code
      ,p_region_1
      ,p_region_2
      ,p_region_3
      ,p_telephone_number_1
      ,p_telephone_number_2
      ,p_telephone_number_3
      ,p_town_or_city
      ,p_request_id
      ,p_program_application_id
      ,p_program_id
      ,p_program_update_date
      ,p_addr_attribute_category
      ,p_addr_attribute1
      ,p_addr_attribute2
      ,p_addr_attribute3
      ,p_addr_attribute4
      ,p_addr_attribute5
      ,p_addr_attribute6
      ,p_addr_attribute7
      ,p_addr_attribute8
      ,p_addr_attribute9
      ,p_addr_attribute10
      ,p_addr_attribute11
      ,p_addr_attribute12
      ,p_addr_attribute13
      ,p_addr_attribute14
      ,p_addr_attribute15
      ,p_addr_attribute16
      ,p_addr_attribute17
      ,p_addr_attribute18
      ,p_addr_attribute19
      ,p_addr_attribute20
 -- ***** Start new code for bug 2711964 **************
      ,p_add_information13
      ,p_add_information14
      ,p_add_information15
      ,p_add_information16
-- ***** End new code for bug 2711964 ***************
      ,p_add_information17
      ,p_add_information18
      ,p_add_information19
      ,p_add_information20
      ,p_end_of_time
      ,l_default_primary
);
end insert_row;
--
procedure insert_row(p_row_id in out nocopy VARCHAR2
      ,p_address_id           in out nocopy NUMBER
      ,p_business_group_id           NUMBER
      ,p_person_id                   NUMBER
      ,p_date_from                   DATE
      ,p_primary_flag                VARCHAR2
      ,p_style                       VARCHAR2
      ,p_address_line1               VARCHAR2
      ,p_address_line2               VARCHAR2
      ,p_address_line3               VARCHAR2
      ,p_address_type                VARCHAR2
      ,p_comments                    VARCHAR2
      ,p_country                     VARCHAR2
      ,p_date_to                     DATE
      ,p_postal_code                 VARCHAR2
      ,p_region_1                    VARCHAR2
      ,p_region_2                    VARCHAR2
      ,p_region_3                    VARCHAR2
      ,p_telephone_number_1          VARCHAR2
      ,p_telephone_number_2          VARCHAR2
      ,p_telephone_number_3          VARCHAR2
      ,p_town_or_city                VARCHAR2
      ,p_request_id                  NUMBER
      ,p_program_application_id      NUMBER
      ,p_program_id                  NUMBER
      ,p_program_update_date         DATE
      ,p_addr_attribute_category     VARCHAR2
      ,p_addr_attribute1             VARCHAR2
      ,p_addr_attribute2             VARCHAR2
      ,p_addr_attribute3             VARCHAR2
      ,p_addr_attribute4             VARCHAR2
      ,p_addr_attribute5             VARCHAR2
      ,p_addr_attribute6             VARCHAR2
      ,p_addr_attribute7             VARCHAR2
      ,p_addr_attribute8             VARCHAR2
      ,p_addr_attribute9             VARCHAR2
      ,p_addr_attribute10            VARCHAR2
      ,p_addr_attribute11            VARCHAR2
      ,p_addr_attribute12            VARCHAR2
      ,p_addr_attribute13            VARCHAR2
      ,p_addr_attribute14            VARCHAR2
      ,p_addr_attribute15            VARCHAR2
      ,p_addr_attribute16            VARCHAR2
      ,p_addr_attribute17            VARCHAR2
      ,p_addr_attribute18            VARCHAR2
      ,p_addr_attribute19            VARCHAR2
      ,p_addr_attribute20            VARCHAR2
-- ***** Start new code for bug 2711964 **************
      ,p_add_information13           VARCHAR2
      ,p_add_information14           VARCHAR2
      ,p_add_information15           VARCHAR2
      ,p_add_information16           VARCHAR2
-- ***** End new code for bug 2711964 ***************
      ,p_add_information17           VARCHAR2
      ,p_add_information18           VARCHAR2
      ,p_add_information19           VARCHAR2
      ,p_add_information20           VARCHAR2
      ,p_end_of_time                 DATE DEFAULT  to_date('31-12-4712','DD-MM-YYYY')
      ,p_default_primary      IN OUT NOCOPY VARCHAR2
) is
--
cursor c1 is select per_addresses_s.nextval
             from sys.dual;
--
cursor c2 is select rowid
             from per_addresses
             where address_id = p_address_id;
-- rpinjala

cursor c3 is select *
             from per_addresses
             where address_id = p_address_id;
l_addr_rec per_addresses%ROWTYPE;
-- rpinjala
--
cursor csr_get_party_id is
             select max(party_id)
             from per_all_people_f
             where person_id = p_person_id;

--
/* Need to check that US payroll is installed */
/*CURSOR get_install_info IS
SELECT fpi.status
FROM fnd_product_installations fpi,
     per_people_f ppf,
     per_business_groups pbg
WHERE fpi.application_id = 801
AND   p_person_id = ppf.person_id
AND   p_business_group_id = pbg.business_group_id
AND   pbg.legislation_code = 'US'
AND   p_person_id = ppf.person_id
AND   ppf.current_employee_flag = 'Y'
AND   p_style = 'US'
AND   p_primary_flag = 'Y';
*/

/* Need to check that legislation_code of the business group,to avoid
default_tax_with_validation getting called for other legislation code except
'US'  - mmukherj */

CURSOR get_legislation_code  IS
SELECT  pbg.legislation_code
from    per_business_groups pbg
where   p_business_group_id = pbg.business_group_id;

--
l_status            VARCHAR2(50);
l_return_code       number;
l_return_text       varchar2(240);
l_legislation_code  varchar2(240);
l_party_id          number;
--
-- Fix for WWBUG 1408379
--
l_old               ben_add_ler.g_add_ler_rec;
l_new               ben_add_ler.g_add_ler_rec;
--
-- End of Fix for WWBUG 1408379
--
begin
hr_utility.set_location('Insert_row',1);
--
 open c1;
 fetch c1 into p_address_id;
 close c1;
--
        open csr_get_party_id;
        fetch csr_get_party_id into l_party_id;
        close csr_get_party_id;
--
 insert into per_addresses(
address_id
,business_group_id
,person_id
,date_from
,primary_flag
,style
,address_line1
,address_line2
,address_line3
,address_type
,comments
,country
,date_to
,postal_code
,region_1
,region_2
,region_3
,telephone_number_1
,telephone_number_2
,telephone_number_3
,town_or_city
,request_id
,program_application_id
,program_id
,program_update_date
,addr_attribute_category
,addr_attribute1
,addr_attribute2
,addr_attribute3
,addr_attribute4
,addr_attribute5
,addr_attribute6
,addr_attribute7
,addr_attribute8
,addr_attribute9
,addr_attribute10
,addr_attribute11
,addr_attribute12
,addr_attribute13
,addr_attribute14
,addr_attribute15
,addr_attribute16
,addr_attribute17
,addr_attribute18
,addr_attribute19
,addr_attribute20
-- ***** Start new code for bug 2711964 **************
,add_information13
,add_information14
,add_information15
,add_information16
-- ***** End new code for bug 2711964 ***************
,add_information17
,add_information18
,add_information19
,add_information20
,party_id
)
values
(p_address_id
,p_business_group_id
,p_person_id
,p_date_from
,p_primary_flag
,p_style
,p_address_line1
,p_address_line2
,p_address_line3
,p_address_type
,p_comments
,p_country
,p_date_to
,p_postal_code
,p_region_1
,p_region_2
,p_region_3
,p_telephone_number_1
,p_telephone_number_2
,p_telephone_number_3
,p_town_or_city
,p_request_id
,p_program_application_id
,p_program_id
,p_program_update_date
,p_addr_attribute_category
,p_addr_attribute1
,p_addr_attribute2
,p_addr_attribute3
,p_addr_attribute4
,p_addr_attribute5
,p_addr_attribute6
,p_addr_attribute7
,p_addr_attribute8
,p_addr_attribute9
,p_addr_attribute10
,p_addr_attribute11
,p_addr_attribute12
,p_addr_attribute13
,p_addr_attribute14
,p_addr_attribute15
,p_addr_attribute16
,p_addr_attribute17
,p_addr_attribute18
,p_addr_attribute19
,p_addr_attribute20
-- ***** Start new code for bug 2711964 **************
,p_add_information13
,p_add_information14
,p_add_information15
,p_add_information16
-- ***** End new code for bug 2711964 ***************
,p_add_information17
,p_add_information18
,p_add_information19
,p_add_information20
,l_party_id
);
--
-- Fix for WWBUG 1408379
--
l_new.person_id := p_person_id;
l_new.business_group_id := p_business_group_id;
l_new.date_from := p_date_from;
l_new.date_to := p_date_to;
l_new.primary_flag := p_primary_flag;
l_new.postal_code := p_postal_code;
l_new.region_2 := p_region_2;
l_new.address_type := p_address_type;
l_new.address_id := p_address_id;
--
ben_add_ler.ler_chk(p_old            => l_old,
                    p_new            => l_new,
                    p_effective_date => l_new.date_from);
--
-- End of Fix for WWBUG 1408379
--
  -- ==============================================================
  -- Call to HZ V2 Address API for creating address in HZ_LOCATIONS
  -- as per OSS HRMS integration
  -- ==============================================================
  open  c3;
  fetch c3 into l_addr_rec;
  close c3;

  InsUpd_OSS_Person_Add
  (p_addr_rec_new   => l_addr_rec
  ,p_addr_rec_old   => Null
  ,p_action         => 'INSERT'
  ,p_effective_date => p_date_from
  );
 -- ==============================================================

open c2;
--
fetch c2 into p_row_id;
--
close c2;
--
p_default_primary := per_addresses_pkg.does_primary_exist(p_person_id
                                    ,p_business_group_id
                                    ,p_end_of_time);
-- Now need to insure that tax record exists if this is the Primary address.
-- For US Payroll installed, employees only.
/* Check For if this is a primary address for a
   US employee when payroll is installed will be made in default_tax_with_validation procedure
   Changes are made as an impact of datetracking of W4 form*/

-- OPEN  get_install_info;
-- FETCH get_install_info INTO l_status;
-- CLOSE get_install_info;
-- IF l_status = 'I' THEN

open get_legislation_code;
fetch get_legislation_code into l_legislation_code;
close get_legislation_code;

IF l_legislation_code = 'US' THEN
   pay_us_emp_dt_tax_rules.default_tax_with_validation(
                               p_assignment_id          => NULL,
                               p_person_id              => p_person_id,
                               p_effective_start_date   => p_date_from,
                               p_effective_end_date     => p_date_to,
                               p_session_date           => NULL,
                               p_business_group_id      => p_business_group_id,
                               p_from_form              => 'Address',
                               p_mode                   => NULL,
                               p_location_id            => NULL,
                               p_return_code            => l_return_code,
                               p_return_text            => l_return_text);
end if;
-- No need to check return, because if not possible then no
-- user message ness.
-- end if;
end insert_row;
--
procedure delete_row(p_row_id VARCHAR2) is
--
-- local variables
--
l_person_id NUMBER;
l_business_group_id NUMBER;
l_end_of_time DATE;
l_default_primary VARCHAR2(1);
begin
  per_addresses_pkg.delete_row(p_row_id
                          ,l_person_id
                          ,l_business_group_id
                          ,l_end_of_time
                          ,l_default_primary);
end delete_row;
--
procedure delete_row(p_row_id VARCHAR2
                    ,p_person_id NUMBER
                    ,p_business_group_id NUMBER
                    ,p_end_of_time DATE
                    ,p_default_primary IN OUT NOCOPY VARCHAR2) is
--
begin
delete from per_addresses pa
where pa.rowid = chartorowid(p_row_id);
--
p_default_primary := per_addresses_pkg.does_primary_exist(p_person_id
                                    ,p_business_group_id
                                    ,p_end_of_time);
--
end delete_row;
--
procedure lock_row(p_row_id VARCHAR2
      ,p_address_id                 NUMBER
      ,p_business_group_id          NUMBER
      ,p_person_id                  NUMBER
      ,p_date_from                  DATE
      ,p_primary_flag               VARCHAR2
      ,p_style                      VARCHAR2
      ,p_address_line1              VARCHAR2
      ,p_address_line2              VARCHAR2
      ,p_address_line3              VARCHAR2
      ,p_address_type               VARCHAR2
      ,p_comments                   VARCHAR2
      ,p_country                    VARCHAR2
      ,p_date_to                    DATE
      ,p_postal_code                VARCHAR2
      ,p_region_1                   VARCHAR2
      ,p_region_2                   VARCHAR2
      ,p_region_3                   VARCHAR2
      ,p_telephone_number_1         VARCHAR2
      ,p_telephone_number_2         VARCHAR2
      ,p_telephone_number_3         VARCHAR2
      ,p_town_or_city               VARCHAR2
      ,p_addr_attribute_category    VARCHAR2
      ,p_addr_attribute1            VARCHAR2
      ,p_addr_attribute2            VARCHAR2
      ,p_addr_attribute3            VARCHAR2
      ,p_addr_attribute4            VARCHAR2
      ,p_addr_attribute5            VARCHAR2
      ,p_addr_attribute6            VARCHAR2
      ,p_addr_attribute7            VARCHAR2
      ,p_addr_attribute8            VARCHAR2
      ,p_addr_attribute9            VARCHAR2
      ,p_addr_attribute10           VARCHAR2
      ,p_addr_attribute11           VARCHAR2
      ,p_addr_attribute12           VARCHAR2
      ,p_addr_attribute13           VARCHAR2
      ,p_addr_attribute14           VARCHAR2
      ,p_addr_attribute15           VARCHAR2
      ,p_addr_attribute16           VARCHAR2
      ,p_addr_attribute17           VARCHAR2
      ,p_addr_attribute18           VARCHAR2
      ,p_addr_attribute19           VARCHAR2
      ,p_addr_attribute20           VARCHAR2
      ,p_add_information17          VARCHAR2
      ,p_add_information18          VARCHAR2
      ,p_add_information19          VARCHAR2
      ,p_add_information20          VARCHAR2
) is
cursor addr is select *
from per_addresses
where rowid = chartorowid(p_row_id)
for update nowait;
add_rec addr%rowtype;
begin
open addr;
fetch addr into add_rec;
close addr;
add_rec.addr_attribute13 := rtrim(add_rec.addr_attribute13);
add_rec.addr_attribute14 := rtrim(add_rec.addr_attribute14);
add_rec.addr_attribute15 := rtrim(add_rec.addr_attribute15);
add_rec.addr_attribute16 := rtrim(add_rec.addr_attribute16);
add_rec.addr_attribute17 := rtrim(add_rec.addr_attribute17);
add_rec.addr_attribute18 := rtrim(add_rec.addr_attribute18);
add_rec.addr_attribute19 := rtrim(add_rec.addr_attribute19);
add_rec.addr_attribute20 := rtrim(add_rec.addr_attribute20);
add_rec.primary_flag := rtrim(add_rec.primary_flag);
add_rec.style := rtrim(add_rec.style);
add_rec.address_line1 := rtrim(add_rec.address_line1);
add_rec.address_line2 := rtrim(add_rec.address_line2);
add_rec.address_line3 := rtrim(add_rec.address_line3);
add_rec.address_type := rtrim(add_rec.address_type);
add_rec.comments := rtrim(add_rec.comments);
add_rec.country := rtrim(add_rec.country);
add_rec.postal_code := rtrim(add_rec.postal_code);
add_rec.region_1 := rtrim(add_rec.region_1);
add_rec.region_2 := rtrim(add_rec.region_2);
add_rec.region_3 := rtrim(add_rec.region_3);
add_rec.telephone_number_1 := rtrim(add_rec.telephone_number_1);
add_rec.telephone_number_2 := rtrim(add_rec.telephone_number_2);
add_rec.telephone_number_3 := rtrim(add_rec.telephone_number_3);
add_rec.town_or_city := rtrim(add_rec.town_or_city);
add_rec.addr_attribute_category := rtrim(add_rec.addr_attribute_category);
add_rec.addr_attribute1 := rtrim(add_rec.addr_attribute1);
add_rec.addr_attribute2 := rtrim(add_rec.addr_attribute2);
add_rec.addr_attribute3 := rtrim(add_rec.addr_attribute3);
add_rec.addr_attribute4 := rtrim(add_rec.addr_attribute4);
add_rec.addr_attribute5 := rtrim(add_rec.addr_attribute5);
add_rec.addr_attribute6 := rtrim(add_rec.addr_attribute6);
add_rec.addr_attribute7 := rtrim(add_rec.addr_attribute7);
add_rec.addr_attribute8 := rtrim(add_rec.addr_attribute8);
add_rec.addr_attribute9 := rtrim(add_rec.addr_attribute9);
add_rec.addr_attribute10 := rtrim(add_rec.addr_attribute10);
add_rec.addr_attribute11 := rtrim(add_rec.addr_attribute11);
add_rec.addr_attribute12 := rtrim(add_rec.addr_attribute12);
add_rec.add_information17 := rtrim(add_rec.add_information17);
add_rec.add_information18 := rtrim(add_rec.add_information18);
add_rec.add_information19 := rtrim(add_rec.add_information19);
add_rec.add_information20 := rtrim(add_rec.add_information20);
--
if ( ((add_rec.address_id = p_address_id)
or (add_rec.address_id is null
and (p_address_id is null)))
and ((add_rec.business_group_id= p_business_group_id)
or (add_rec.business_group_id is null
and (p_business_group_id is null)))
and ((add_rec.person_id= p_person_id)
or (add_rec.person_id is null
and (p_person_id is null)))
and ((add_rec.date_from= p_date_from)
or (add_rec.date_from is null
and (p_date_from is null)))
and ((add_rec.primary_flag = p_primary_flag)
or (add_rec.primary_flag is null
and (p_primary_flag is null)))
and ((add_rec.style= p_style)
or (add_rec.style is null
and (p_style is null)))
and ((add_rec.address_line1= p_address_line1)
or (add_rec.address_line1 is null
and (p_address_line1 is null)))
and ((add_rec.address_line2= p_address_line2)
or (add_rec.address_line2 is null
and (p_address_line2 is null)))
and ((add_rec.address_line3= p_address_line3)
or (add_rec.address_line3 is null
and (p_address_line3 is null)))
and ((add_rec.address_type = p_address_type)
or (add_rec.address_type is null
and (p_address_type is null)))
and ((add_rec.comments = p_comments)
or (add_rec.comments is null
and (p_comments is null)))
and ((add_rec.country= p_country)
or (add_rec.country is null
and (p_country is null)))
and ((add_rec.date_to= p_date_to)
or (add_rec.date_to is null
and (p_date_to is null)))
and ((add_rec.postal_code= p_postal_code)
or (add_rec.postal_code is null
and (p_postal_code is null)))
and ((add_rec.region_1 = p_region_1)
or (add_rec.region_1 is null
and (p_region_1 is null)))
and ((add_rec.region_2 = p_region_2)
or (add_rec.region_2 is null
and (p_region_2 is null)))
and ((add_rec.region_3 = p_region_3)
or (add_rec.region_3 is null
and (p_region_3 is null)))
and ((add_rec.telephone_number_1 = p_telephone_number_1)
or (add_rec.telephone_number_1 is null
and (p_telephone_number_1 is null)))
and ((add_rec.telephone_number_2 = p_telephone_number_2)
or (add_rec.telephone_number_2 is null
and (p_telephone_number_2 is null)))
and ((add_rec.telephone_number_3 = p_telephone_number_3)
or (add_rec.telephone_number_3 is null
and (p_telephone_number_3 is null)))
and ((add_rec.town_or_city = p_town_or_city)
or (add_rec.town_or_city is null
and (p_town_or_city is null)))
and ((add_rec.addr_attribute_category= p_addr_attribute_category)
or (add_rec.addr_attribute_category is null
and (p_addr_attribute_category is null)))
and ((add_rec.addr_attribute1= p_addr_attribute1)
or (add_rec.addr_attribute1 is null
and (p_addr_attribute1 is null)))
and ((add_rec.addr_attribute2= p_addr_attribute2)
or (add_rec.addr_attribute2 is null
and (p_addr_attribute2 is null)))
and ((add_rec.addr_attribute3= p_addr_attribute3)
or (add_rec.addr_attribute3 is null
and (p_addr_attribute3 is null)))
and ((add_rec.addr_attribute4= p_addr_attribute4)
or (add_rec.addr_attribute4 is null
and (p_addr_attribute4 is null)))
and ((add_rec.addr_attribute5= p_addr_attribute5)
or (add_rec.addr_attribute5 is null
and (p_addr_attribute5 is null)))
and ((add_rec.addr_attribute6= p_addr_attribute6)
or (add_rec.addr_attribute6 is null
and (p_addr_attribute6 is null)))
and ((add_rec.addr_attribute7= p_addr_attribute7)
or (add_rec.addr_attribute7 is null
and (p_addr_attribute7 is null)))
and ((add_rec.addr_attribute8= p_addr_attribute8)
or (add_rec.addr_attribute8 is null
and (p_addr_attribute8 is null)))
and ((add_rec.addr_attribute9= p_addr_attribute9)
or (add_rec.addr_attribute9 is null
and (p_addr_attribute9 is null)))
and ((add_rec.addr_attribute10 = p_addr_attribute10)
or (add_rec.addr_attribute10 is null
and (p_addr_attribute10 is null)))
and ((add_rec.addr_attribute11 = p_addr_attribute11)
or (add_rec.addr_attribute11 is null
and (p_addr_attribute11 is null)))
and ((add_rec.addr_attribute12 = p_addr_attribute12)
or (add_rec.addr_attribute12 is null
and (p_addr_attribute12 is null)))
and ((add_rec.addr_attribute13 = p_addr_attribute13)
or (add_rec.addr_attribute13 is null
and (p_addr_attribute13 is null)))
and ((add_rec.addr_attribute14 = p_addr_attribute14)
or (add_rec.addr_attribute14 is null
and (p_addr_attribute14 is null)))
and ((add_rec.addr_attribute15 = p_addr_attribute15)
or (add_rec.addr_attribute15 is null
and (p_addr_attribute15 is null)))
and ((add_rec.addr_attribute16 = p_addr_attribute16)
or (add_rec.addr_attribute16 is null
and (p_addr_attribute16 is null)))
and ((add_rec.addr_attribute17 = p_addr_attribute17)
or (add_rec.addr_attribute17 is null
and (p_addr_attribute17 is null)))
and ((add_rec.addr_attribute18 = p_addr_attribute18)
or (add_rec.addr_attribute18 is null
and (p_addr_attribute18 is null)))
and ((add_rec.addr_attribute19 = p_addr_attribute19)
or (add_rec.addr_attribute19 is null
and (p_addr_attribute19 is null)))
and ((add_rec.addr_attribute20 = p_addr_attribute20)
or (add_rec.addr_attribute20 is null
and (p_addr_attribute20 is null)))
and ((add_rec.add_information17 = p_add_information17)
or (add_rec.add_information17 is null
and (p_add_information17 is null)))
and ((add_rec.add_information18 = p_add_information18)
or (add_rec.add_information18 is null
and (p_add_information18 is null)))
and ((add_rec.add_information19 = p_add_information19)
or (add_rec.add_information19 is null
and (p_add_information19 is null)))
and ((add_rec.add_information20 = p_add_information20)
or (add_rec.add_information20 is null
and (p_add_information20 is null)))
) then
 return;
end if;
 fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
 app_exception.raise_exception;
exception when no_data_found then
raise;
when others then raise;
end lock_row;
--
procedure update_row(p_row_id       VARCHAR2
      ,p_address_id                 NUMBER
      ,p_business_group_id          NUMBER
      ,p_person_id                  NUMBER
      ,p_date_from                  DATE
      ,p_primary_flag               VARCHAR2
      ,p_style                      VARCHAR2
      ,p_address_line1              VARCHAR2
      ,p_address_line2              VARCHAR2
      ,p_address_line3              VARCHAR2
      ,p_address_type               VARCHAR2
      ,p_comments                   VARCHAR2
      ,p_country                    VARCHAR2
      ,p_date_to                    DATE
      ,p_postal_code                VARCHAR2
      ,p_region_1                   VARCHAR2
      ,p_region_2                   VARCHAR2
      ,p_region_3                   VARCHAR2
      ,p_telephone_number_1         VARCHAR2
      ,p_telephone_number_2         VARCHAR2
      ,p_telephone_number_3         VARCHAR2
      ,p_town_or_city               VARCHAR2
      ,p_request_id                 NUMBER
      ,p_program_application_id     NUMBER
      ,p_program_id                 NUMBER
      ,p_program_update_date        DATE
      ,p_addr_attribute_category    VARCHAR2
      ,p_addr_attribute1            VARCHAR2
      ,p_addr_attribute2            VARCHAR2
      ,p_addr_attribute3            VARCHAR2
      ,p_addr_attribute4            VARCHAR2
      ,p_addr_attribute5            VARCHAR2
      ,p_addr_attribute6            VARCHAR2
      ,p_addr_attribute7            VARCHAR2
      ,p_addr_attribute8            VARCHAR2
      ,p_addr_attribute9            VARCHAR2
      ,p_addr_attribute10           VARCHAR2
      ,p_addr_attribute11           VARCHAR2
      ,p_addr_attribute12           VARCHAR2
      ,p_addr_attribute13           VARCHAR2
      ,p_addr_attribute14           VARCHAR2
      ,p_addr_attribute15           VARCHAR2
      ,p_addr_attribute16           VARCHAR2
      ,p_addr_attribute17           VARCHAR2
      ,p_addr_attribute18           VARCHAR2
      ,p_addr_attribute19           VARCHAR2
      ,p_addr_attribute20           VARCHAR2
      ,p_add_information17          VARCHAR2
      ,p_add_information18          VARCHAR2
      ,p_add_information19          VARCHAR2
      ,p_add_information20          VARCHAR2
      ,p_end_of_time                DATE DEFAULT  to_date('31-12-4712','DD-MM-YYYY')
) is
--
-- Local Variables
--
l_default_primary VARCHAR2(1);
l_return_code       number;
l_return_text       varchar2(240);

begin
hr_utility.set_location('update_row',1);
PER_ADDRESSES_PKG.update_row(p_row_id
      ,p_address_id
      ,p_business_group_id
      ,p_person_id
      ,p_date_from
      ,p_primary_flag
      ,p_style
      ,p_address_line1
      ,p_address_line2
      ,p_address_line3
      ,p_address_type
      ,p_comments
      ,p_country
      ,p_date_to
      ,p_postal_code
      ,p_region_1
      ,p_region_2
      ,p_region_3
      ,p_telephone_number_1
      ,p_telephone_number_2
      ,p_telephone_number_3
      ,p_town_or_city
      ,p_request_id
      ,p_program_application_id
      ,p_program_id
      ,p_program_update_date
      ,p_addr_attribute_category
      ,p_addr_attribute1
      ,p_addr_attribute2
      ,p_addr_attribute3
      ,p_addr_attribute4
      ,p_addr_attribute5
      ,p_addr_attribute6
      ,p_addr_attribute7
      ,p_addr_attribute8
      ,p_addr_attribute9
      ,p_addr_attribute10
      ,p_addr_attribute11
      ,p_addr_attribute12
      ,p_addr_attribute13
      ,p_addr_attribute14
      ,p_addr_attribute15
      ,p_addr_attribute16
      ,p_addr_attribute17
      ,p_addr_attribute18
      ,p_addr_attribute19
      ,p_addr_attribute20
      ,p_add_information17
      ,p_add_information18
      ,p_add_information19
      ,p_add_information20
      ,p_end_of_time
      ,l_default_primary
);
--
--
end update_row;
--
procedure update_row(p_row_id VARCHAR2
   ,p_address_id                    NUMBER
   ,p_business_group_id             NUMBER
   ,p_person_id                     NUMBER
   ,p_date_from                     DATE
   ,p_primary_flag                  VARCHAR2
   ,p_style                         VARCHAR2
   ,p_address_line1                 VARCHAR2
   ,p_address_line2                 VARCHAR2
   ,p_address_line3                 VARCHAR2
   ,p_address_type                  VARCHAR2
   ,p_comments                      VARCHAR2
   ,p_country                       VARCHAR2
   ,p_date_to                       DATE
   ,p_postal_code                   VARCHAR2
   ,p_region_1                      VARCHAR2
   ,p_region_2                      VARCHAR2
   ,p_region_3                      VARCHAR2
   ,p_telephone_number_1            VARCHAR2
   ,p_telephone_number_2            VARCHAR2
   ,p_telephone_number_3            VARCHAR2
   ,p_town_or_city                  VARCHAR2
   ,p_request_id                    NUMBER
   ,p_program_application_id        NUMBER
   ,p_program_id                    NUMBER
   ,p_program_update_date           DATE
   ,p_addr_attribute_category       VARCHAR2
   ,p_addr_attribute1               VARCHAR2
   ,p_addr_attribute2               VARCHAR2
   ,p_addr_attribute3               VARCHAR2
   ,p_addr_attribute4               VARCHAR2
   ,p_addr_attribute5               VARCHAR2
   ,p_addr_attribute6               VARCHAR2
   ,p_addr_attribute7               VARCHAR2
   ,p_addr_attribute8               VARCHAR2
   ,p_addr_attribute9               VARCHAR2
   ,p_addr_attribute10              VARCHAR2
   ,p_addr_attribute11              VARCHAR2
   ,p_addr_attribute12              VARCHAR2
   ,p_addr_attribute13              VARCHAR2
   ,p_addr_attribute14              VARCHAR2
   ,p_addr_attribute15              VARCHAR2
   ,p_addr_attribute16              VARCHAR2
   ,p_addr_attribute17              VARCHAR2
   ,p_addr_attribute18              VARCHAR2
   ,p_addr_attribute19              VARCHAR2
   ,p_addr_attribute20              VARCHAR2
   ,p_add_information17             VARCHAR2
   ,p_add_information18             VARCHAR2
   ,p_add_information19             VARCHAR2
   ,p_add_information20             VARCHAR2
   ,p_end_of_time                   DATE DEFAULT  to_date('31-12-4712','DD-MM-YYYY')
   ,p_default_primary        IN OUT NOCOPY VARCHAR2
) is
/* Need to check that US payroll is installed.
This will now be checked in default_tax_with_validation_package */
--
/*
CURSOR get_install_info IS
SELECT fpi.status
FROM fnd_product_installations fpi,
     per_people_f ppf,
     per_business_groups pbg
WHERE fpi.application_id = 801
AND   p_person_id = ppf.person_id
AND   ppf.current_employee_flag = 'Y'
AND   p_business_group_id = pbg.business_group_id
AND   pbg.legislation_code = 'US'
AND   p_style = 'US'
AND   p_primary_flag = 'Y';
*/
/* Need to check that legislation_code of the business group,to avoid
default_tax_with_validation getting called for other legislation code except
'US'  - mmukherj */
--
CURSOR get_legislation_code  IS
SELECT  pbg.legislation_code
from    per_business_groups pbg
where   p_business_group_id = pbg.business_group_id;
--
l_status            VARCHAR2(50);
l_person_type       VARCHAR2(50);
l_return_code       number;
l_return_text       varchar2(240);
l_legislation_code  varchar2(240);
--
-- Fix for WWBUG 1408379
--
l_old               ben_add_ler.g_add_ler_rec;
l_new               ben_add_ler.g_add_ler_rec;

--
cursor c1 is
  select *
  from   per_addresses
  where  rowid = chartorowid(p_row_id);
--
l_c1 c1%rowtype;
l_c2 c1%rowtype;

l_rec_found boolean := false;
--
-- End of Fix for WWBUG 1408379
--
begin
--
 /*hr_person.validate_address(p_person_id
                ,p_business_group_id
                ,p_address_id
                ,p_date_from
                ,p_date_to
                ,p_end_of_time
                ,p_primary_flag);*/
--
-- Fix for WWBUG 1408379
--
open c1;
  --
  fetch c1 into l_c1;
  --
  if c1%found then
    --
    l_rec_found := true;
    --
  end if;
  --
close c1;
--
-- End of Fix for WWBUG 1408379
--
update per_addresses pa set
pa.address_id               = p_address_id
,pa.business_group_id       = p_business_group_id
,pa.person_id               = p_person_id
,pa.date_from               = p_date_from
,pa.primary_flag            = p_primary_flag
,pa.style                   = p_style
,pa.address_line1           = p_address_line1
,pa.address_line2           = p_address_line2
,pa.address_line3           = p_address_line3
,pa.address_type            = p_address_type
,pa.comments                = p_comments
,pa.country                 = p_country
,pa.date_to                 = p_date_to
,pa.postal_code             = p_postal_code
,pa.region_1                = p_region_1
,pa.region_2                = p_region_2
,pa.region_3                = p_region_3
,pa.telephone_number_1      = p_telephone_number_1
,pa.telephone_number_2      = p_telephone_number_2
,pa.telephone_number_3      = p_telephone_number_3
,pa.town_or_city            = p_town_or_city
,pa.request_id              = p_request_id
,pa.program_application_id  = p_program_application_id
,pa.program_id              = p_program_id
,pa.program_update_date     = p_program_update_date
,pa.addr_attribute_category = p_addr_attribute_category
,pa.addr_attribute1         = p_addr_attribute1
,pa.addr_attribute2         = p_addr_attribute2
,pa.addr_attribute3         = p_addr_attribute3
,pa.addr_attribute4         = p_addr_attribute4
,pa.addr_attribute5         = p_addr_attribute5
,pa.addr_attribute6         = p_addr_attribute6
,pa.addr_attribute7         = p_addr_attribute7
,pa.addr_attribute8         = p_addr_attribute8
,pa.addr_attribute9         = p_addr_attribute9
,pa.addr_attribute10        = p_addr_attribute10
,pa.addr_attribute11        = p_addr_attribute11
,pa.addr_attribute12        = p_addr_attribute12
,pa.addr_attribute13        = p_addr_attribute13
,pa.addr_attribute14        = p_addr_attribute14
,pa.addr_attribute15        = p_addr_attribute15
,pa.addr_attribute16        = p_addr_attribute16
,pa.addr_attribute17        = p_addr_attribute17
,pa.addr_attribute18        = p_addr_attribute18
,pa.addr_attribute19        = p_addr_attribute19
,pa.addr_attribute20        = p_addr_attribute20
,pa.add_information17       = p_add_information17
,pa.add_information18       = p_add_information18
,pa.add_information19       = p_add_information19
,pa.add_information20       = p_add_information20
where pa.rowid = chartorowid(p_row_id);
--
-- Fix for WWBUG 1408379
--
if l_rec_found then
  --
  -- Call OAB hook
  --
  l_old.person_id := l_c1.person_id;
  l_old.business_group_id := l_c1.business_group_id;
  l_old.date_from := l_c1.date_from;
  l_old.date_to := l_c1.date_to;
  l_old.primary_flag := l_c1.primary_flag;
  l_old.postal_code := l_c1.postal_code;
  l_old.region_2 := l_c1.region_2;
  l_old.address_type := l_c1.address_type;
  l_old.address_id := l_c1.address_id;

  l_new.person_id := p_person_id;
  l_new.business_group_id := p_business_group_id;
  l_new.date_from := p_date_from;
  l_new.date_to := p_date_to;
  l_new.primary_flag := p_primary_flag;
  l_new.postal_code := p_postal_code;
  l_new.region_2 := p_region_2;
  l_new.address_type := p_address_type;
  l_new.address_id := p_address_id;
  --
  ben_add_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => p_date_from);
end if;
  -- ==============================================================
  -- Call to HZ V2 Address API for updating address in HZ_LOCATIONS
  -- as per OSS HRMS integration
  -- ==============================================================
  open  c1;
  fetch c1 into l_c2;
  close c1;
  l_c2.party_id := l_c1.party_id;
  InsUpd_OSS_Person_Add
  (p_addr_rec_new   => l_c2
  ,p_addr_rec_old   => l_c1
  ,p_action         => 'UPDATE'
  ,p_effective_date => p_date_from
  );
  -- ==============================================================
--
-- End of Fix for WWBUG 1408379
--
p_default_primary := per_addresses_pkg.does_primary_exist(p_person_id
                                    ,p_business_group_id
                                    ,p_end_of_time);
--
--OPEN  get_install_info;
--FETCH get_install_info INTO l_status;
--CLOSE get_install_info;

/* Check For if this is a primary address for a
   US employee when payroll is installed will be made in default_tax_with_validation procedure
   Changes are made as an impact of datetracking of W4 form*/

--IF  l_status = 'I'   THEN
open get_legislation_code;
fetch get_legislation_code into l_legislation_code;
close get_legislation_code;

IF l_legislation_code = 'US' THEN
   pay_us_emp_dt_tax_rules.default_tax_with_validation(
                               p_assignment_id          => NULL,
                               p_person_id              => p_person_id,
                               p_effective_start_date   => p_date_from,
                               p_effective_end_date     => p_date_to,
                               p_session_date           => NULL,
                               p_business_group_id      => p_business_group_id,
                               p_from_form              => 'Address',
                               p_mode                   => NULL,
                               p_location_id            => NULL,
                               p_return_code            => l_return_code,
                               p_return_text            => l_return_text);
end if;
--
-- No need to check return, because if not possible then no
-- user message ness.
--END IF;
end update_row;
--
function does_primary_exist(p_person_id NUMBER
                           ,p_business_group_id NUMBER
                           ,p_end_of_time DATE) return VARCHAR2 is
cursor primary_address is
select  'Y'
from    per_addresses pa
,       fnd_sessions fs
where   pa.business_group_id + 0 = p_business_group_id
and     pa.person_id         = p_person_id
and     pa.primary_flag = 'Y'
and     fs.session_id(+) = userenv('sessionid')
and     nvl(fs.effective_date,sysdate) between pa.date_from
and     nvl(pa.date_to,p_end_of_time);
--
-- local variable
--
l_exists VARCHAR2(1);
begin
   open primary_address;
   fetch primary_address into l_exists;
   loop
      exit when primary_address%NOTFOUND;
      fetch primary_address into l_exists;
   end loop;
   if primary_address%ROWCOUNT <>0 then
     return 'N';
   else
     return 'Y';
   end if;
end does_primary_exist;
--
procedure find_gaps(p_person_id NUMBER
                   ,p_end_of_time DATE) is
--
--
cursor get_addr is
select 'Y'
from per_addresses pa1
where pa1.primary_flag = 'N'
and   pa1.person_id = p_person_id
and not exists (select 'x'
from per_addresses pa2
where pa2.person_id = pa1.person_id
and pa2.primary_flag = 'Y'
and pa2.address_id <> pa1.address_id
and pa2.date_from <=pa1.date_from
and nvl(pa2.date_to, p_end_of_time) >=
nvl(pa1.date_to, p_end_of_time));
--
l_gap_exists VARCHAR2(1);
--
begin
  open get_addr;
  fetch get_addr into l_gap_exists;
  if get_addr%FOUND then
   hr_utility.set_message(801,'HR_51030_ADDR_PRIM_GAP');
   hr_utility.raise_error;
  end if;
  close get_addr;
end find_gaps;
--
procedure get_default_style(p_legislation_code VARCHAR2
                           ,p_default_country IN OUT NOCOPY VARCHAR2
                           ,p_default_style IN OUT NOCOPY VARCHAR2) is
--
l_geocodes_installed varchar2(1);
l_default varchar2(80);
l_default_code varchar2(30);
--
-- Bug fix 3648688
-- Added application_id = 800 to cursors local_default and
-- global_default to improve performance.

cursor local_default is
select descriptive_flex_context_name, descriptive_flex_context_code
from fnd_descr_flex_contexts_vl
where (descriptive_flex_context_code = p_legislation_code
  or (p_legislation_code = descriptive_flex_context_code
  and p_legislation_code in ('CA','US')
  and l_geocodes_installed = 'Y'))
and descriptive_flexfield_name = 'Address Structure'
and application_id = 800 -- bug fix 3648688.
and enabled_flag = 'Y'
;
--
cursor global_default is
select descriptive_flex_context_name,descriptive_flex_context_code
from fnd_descr_flex_contexts_vl
where substr(descriptive_flex_context_code,1,2)= p_legislation_code
and descriptive_flexfield_name = 'Address Structure'
and application_id = 800 -- bug fix 3648688.
and enabled_flag = 'Y';
--
begin
--
l_geocodes_installed := hr_general.chk_geocodes_installed;
--
open local_default;
fetch local_default into l_default,l_default_code;
if local_default%notfound then
  open global_default;
  fetch global_default into l_default,l_default_code;
  close global_default;
end if;
close local_default;
--
p_default_country := l_default;
p_default_style := l_default_code;
--
hr_utility.set_location('l_default'||l_default,1);
hr_utility.set_location('l_default_code'||l_default_code,2);
end get_default_style;
--
procedure get_addresses(p_legislation_code VARCHAR2
                       ,p_default_country IN OUT NOCOPY VARCHAR2) is
begin

  -- bug fix 3648688
  -- Application_id = 800 is added to sql to improve performance.

  select ft.territory_short_name
  into   p_default_country
  from   fnd_territories_vl ft
  ,      fnd_descr_flex_contexts fdfc
  where ft.territory_code = p_legislation_code
  and   fdfc.descriptive_flex_context_code  = ft.territory_code
  and   fdfc.descriptive_flexfield_name ='Address Structure'
  and   fdfc.application_id = 800 -- bug fix 3648688
  and   fdfc.enabled_flag = 'Y';
--
  exception
    when no_data_found then
        null;
    when others then
        raise;
end get_addresses;
--
procedure form_startup1(p_person_id NUMBER
                      ,p_business_group_id NUMBER
                      ,p_end_of_time DATE
                      ,p_primary_flag IN OUT NOCOPY VARCHAR2
                      ,p_legislation_code VARCHAR2
                      ,p_default_country IN OUT NOCOPY VARCHAR2
                      ,p_default_style IN OUT NOCOPY VARCHAR2) is
begin
  p_primary_flag := per_addresses_pkg.does_primary_exist(p_person_id
                           ,p_business_group_id
                           ,p_end_of_time);
--
  per_addresses_pkg.get_default_style(p_legislation_code
                                       ,p_default_country
                                       ,p_default_style);
--
end form_startup1;
--
procedure form_startup(p_person_id NUMBER
                      ,p_business_group_id NUMBER
                      ,p_end_of_time DATE
                      ,p_primary_flag IN OUT NOCOPY VARCHAR2
                      ,p_legislation_code VARCHAR2
                      ,p_default_country IN OUT NOCOPY VARCHAR2) is
begin
  p_primary_flag := per_addresses_pkg.does_primary_exist(p_person_id
                           ,p_business_group_id
                           ,p_end_of_time);
--
  per_addresses_pkg.get_addresses(p_legislation_code
                              ,p_default_country);
--
end form_startup;
------------------------- BEGIN: validate_address --------------------
--
--NAME
--  validate_address
--DESCRIPTION
--  Validates the Address Entered.
--PARAMETERS
--  p_person_id : Unique Id of the person.
--  p_end_of_time :Ultimate date on Oracle system 31-Dec-4712.
--
-----------------------------------------------------------------------
--
PROCEDURE validate_address(p_person_id INTEGER
                          ,p_end_of_time DATE) is
  --
  v_dummy VARCHAR2(30);
  -- primary flag test.
  l_primary_flag VARCHAR2(1) :='Y';
  l_date_from date;
  l_date_to date;
  a_date_from date;
  a_date_to date;
  b_date_from date;
  b_date_to date;
  --
  cursor has_addrs is
    select 'Y'
    from per_addresses pa
    where pa.person_id = p_person_id;
  --
  cursor check_min_is_primary is
    select 'Y'
    from   per_addresses pa
    where  person_id    = p_person_id
    and    date_from    = l_date_from
    and    primary_flag = 'Y';
  --
  cursor   has_primary is
    select 'Y'
    from   per_addresses pa
    where  person_id = p_person_id
    and    primary_flag = 'Y';
  --
  cursor get_mins is
    select min(date_from)
    from   per_addresses
    where  person_id = p_person_id;
  /*
  cursor get_next(l_date_from in date) is
    select date_to
    from per_addresses pa
    where date_from = l_date_from
    and person_id = p_person_id
    and primary_flag = 'Y';
  */
  cursor get_next is
    select date_from,
           date_to
    from   per_addresses pa
    where  person_id = p_person_id
    and    primary_flag = 'Y'
    order by date_from;
  --
  cursor get_overlapping is
    select 'Y'
    from per_addresses pa
    where person_id = p_person_id
    and   primary_flag = 'Y'
    and   exists (select 'Y'
                    from per_addresses pa2
                   where pa.person_id = pa2.person_id
                     and pa.address_id <> pa2.address_id
                     and pa2.primary_flag = 'Y'
                     and ((pa2.date_from between pa.date_from and
                                         nvl(pa.date_to,to_date('31-12-4712','DD-MM-YYYY')))
                     or  (pa.date_from between pa2.date_from
                                       and nvl(pa2.date_to,to_date('31-12-4712','DD-MM-YYYY'))                     )
                    ));
  --
  cursor check_other_person_type is
    select 'Y'
    from   per_all_people_f p, per_person_types t
    where  p.person_id = p_person_id
    and    p.person_type_id = t.person_type_id
    and    t.system_person_type = 'OTHER';
  --
  -- Validate Address type Cursor
  --
  cursor validate_address_types is
    select 1
    from per_addresses pa
    where pa.address_type is not null
    and   pa.person_id = p_person_id
    and exists( select 1
    from per_addresses pa2
    where pa2.address_id <> pa.address_id
    and   pa2.address_type is not null
    and   pa.address_type = pa2.address_type
    and   pa.person_id = pa2.person_id
    and   ((pa.date_from between pa2.date_from and nvl(pa2.date_to,
                     p_end_of_time))
                  or
                   (nvl(pa.date_to,p_end_of_time) between pa2.date_from and
                    nvl(pa2.date_to, p_end_of_time))
                  ));
  --
  l_proc              VARCHAR2(50) := 'per_addresses_pkg.validate_address';
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  open has_addrs;
  fetch has_addrs into v_dummy;
  --
  if has_addrs%notfound then
    --
    hr_utility.set_location(l_proc,20);
    --
    close has_addrs;
    --
  else
    --
    close has_addrs;
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Get the start and end of the first address
    --
    open get_mins;
    fetch get_mins into l_date_from;
    --
    close get_mins;
    --
    -- Establish whether the minimum row is the primary
    --
    open check_min_is_primary;
    fetch check_min_is_primary into v_dummy;
    --
    if check_min_is_primary%NOTFOUND then
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Minimum is not a primary,
      -- does a primary exist?
      --
      close check_min_is_primary;
      --
      open has_primary;
      fetch has_primary  into v_dummy;
      --
      if has_primary%NOTFOUND then
        --
        hr_utility.set_location(l_proc,50);
        --
        -- No primary, pass relevant error back
        --
        close has_primary;
        --
        hr_utility.set_message(801,'HR_7144_PER_NO_PRIM_ADD');
        hr_utility.raise_error;
        --
      else
        --
        -- Primary exists, and as minimum not the primary
        -- a gap in the primaries also exists
        --
        close has_primary;
        --
        hr_utility.set_message(800,'PER_52473_ADDR_SEC_AFTER_PRIM');
        hr_utility.raise_error;
        --
      end if;
      --
    else
      --
      hr_utility.set_location(l_proc,60);
      --
      close check_min_is_primary;
      --
    end if;
    --
    --
    /*
    open get_next(l_date_from);
    fetch get_next into l_date_to;
    close get_next;
    if l_date_to is not null
    then
     loop
       hr_utility.set_location('hr_person.validate_address',5);
       exit when l_date_to is null;
       l_date_from := l_date_to + 1;
       open get_next(l_date_from);
       fetch get_next into l_date_to;
       hr_utility.set_location('hr_person.validate_address',6);
       if get_next%NOTFOUND
       then
         hr_utility.set_message(801,'HR_51030_ADDR_PRIM_GAP');
         hr_utility.raise_error;
       end if;
       hr_utility.set_location('hr_person.validate_address',7);
       close get_next;
     end loop;
    end if;
    */
    --
    -- Get the fist primary address
    --
    open get_next;
    fetch get_next into a_date_from, a_date_to;
    --
    hr_utility.set_location(l_proc||'/'||a_date_from||'/'||a_Date_to,65);
    --
    loop
      --
      hr_utility.set_location(l_proc,70);
      --
      fetch get_next into b_date_from, b_date_to;
      --
      hr_utility.set_location(l_proc||'/'||b_date_from||'/'||b_Date_to,75);
      --
      -- If there is another primary address then check that the
      -- dates match up so there is no gaps between the end of one
      -- primary address and the beginning of the next.
      --
      if get_next%FOUND then
        --
        hr_utility.set_location(l_proc,80);
        --
        if b_date_from <> a_date_to + 1 then
          --
          hr_utility.set_location(l_proc,90);
          --
          close get_next;
          --
          hr_utility.set_message(801,'HR_51030_ADDR_PRIM_GAP');
          hr_utility.raise_error;
          --
        end if;
        --
      else
        --
        hr_utility.set_location(l_proc,100);
        --
        open check_other_person_type;
        fetch check_other_person_type into v_dummy;
        --
        if check_other_person_type%FOUND then
          --
          hr_utility.set_location(l_proc,110);
          --
          exit;
          --
        end if;
        --
        close check_other_person_type;
        --
        -- This makes no sense if I am trying to end date an address record
        -- through fastpath and then create a new address record via fastpath.
        -- This is preventing the action from taking place hence the code has
        -- been removed. WWBUG 1814842.
        --
        -- Added back in to fix bug 2273441
        --
        if a_date_to is not null then
          --
          close get_next;
          --
          hr_utility.set_message(801,'HR_7144_PER_NO_PRIM_ADD');
          hr_utility.raise_error;
          --
        end if;
        --
      end if;
      --
      exit when a_date_to is null;
      --
      a_date_from := b_date_from;
      a_date_to   := b_date_to;
      --
    end loop;
    --
    hr_utility.set_location(l_proc,120);
    --
    close get_next;
    --
    -- Primary exists and form trying to enter primary
    -- then raise overlapping error.
    --
    open get_overlapping;
    fetch get_overlapping into v_dummy;
    --
    if get_overlapping%FOUND then
      --
      close get_overlapping;
      --
      hr_utility.set_message(801,'HR_6510_PER_PRIMARY_ADDRESS');
      hr_utility.raise_error;
      --
    end if;
    --
    close get_overlapping;
    --
  end if;
  --
  open validate_address_types;
  fetch validate_address_types into v_dummy;
  --
  if validate_address_types%FOUND then
    --
 close validate_address_types;
    --
 hr_utility.set_message(800,'PER_52244_ONE_ADD_OF_EACH_TYPE');
    hr_utility.raise_error;
    --
  end if;
  --
  close validate_address_types;
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
end validate_address;
--
END PER_ADDRESSES_PKG;

/
