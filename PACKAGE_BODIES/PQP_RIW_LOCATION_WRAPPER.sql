--------------------------------------------------------
--  DDL for Package Body PQP_RIW_LOCATION_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_LOCATION_WRAPPER" as
/* $Header: pqpriwlcwr.pkb 120.0.12010000.3 2009/08/25 15:49:01 psengupt noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
g_package  varchar2(33) := 'pqp_riw_location_wrapper.';
g_location_rec              hr_locations_all%rowtype;
g_style                     varchar2(7);
--==========================================================================
--Default Record Values
--==========================================================================
function Default_Location_Rec
         return hr_locations_all%rowtype is
  l_proc_name    constant varchar2(150) := g_package||'Default_Locations_Rec';
  l_location_rec     hr_locations_all%rowtype;
Begin
     hr_utility.set_location('Entering Default Rec' , 25);

l_location_rec.LOCATION_CODE               :=       hr_api.g_varchar2;
l_location_rec.ADDRESS_LINE_1              :=       hr_api.g_varchar2;
l_location_rec.ADDRESS_LINE_2              :=       hr_api.g_varchar2;
l_location_rec.ADDRESS_LINE_3              :=       hr_api.g_varchar2;
l_location_rec.BILL_TO_SITE_FLAG           :=       hr_api.g_varchar2;
l_location_rec.COUNTRY                     :=       hr_api.g_varchar2;
l_location_rec.DESCRIPTION                 :=       hr_api.g_varchar2;
l_location_rec.DESIGNATED_RECEIVER_ID      :=       hr_api.g_number;
l_location_rec.IN_ORGANIZATION_FLAG        :=       hr_api.g_varchar2;
l_location_rec.INACTIVE_DATE               :=       hr_api.g_date;
l_location_rec.INVENTORY_ORGANIZATION_ID   :=       hr_api.g_number;
l_location_rec.OFFICE_SITE_FLAG            :=       hr_api.g_varchar2;
l_location_rec.POSTAL_CODE                 :=       hr_api.g_varchar2;
l_location_rec.RECEIVING_SITE_FLAG         :=       hr_api.g_varchar2;
l_location_rec.REGION_1                    :=       hr_api.g_varchar2;
l_location_rec.REGION_2                    :=       hr_api.g_varchar2;
l_location_rec.REGION_3                    :=       hr_api.g_varchar2;
l_location_rec.SHIP_TO_LOCATION_ID         :=       hr_api.g_number;
l_location_rec.SHIP_TO_SITE_FLAG           :=       hr_api.g_varchar2;
l_location_rec.STYLE                       :=       g_style;
l_location_rec.TAX_NAME                    :=       hr_api.g_varchar2;
l_location_rec.TELEPHONE_NUMBER_1          :=       hr_api.g_varchar2;
l_location_rec.TELEPHONE_NUMBER_2          :=       hr_api.g_varchar2;
l_location_rec.TELEPHONE_NUMBER_3          :=       hr_api.g_varchar2;
l_location_rec.TOWN_OR_CITY                :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE_CATEGORY          :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE1                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE2                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE3                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE4                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE5                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE6                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE7                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE8                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE9                  :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE10                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE11                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE12                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE13                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE14                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE15                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE16                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE17                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE18                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE19                 :=       hr_api.g_varchar2;
l_location_rec.ATTRIBUTE20                 :=       hr_api.g_varchar2;
l_location_rec.LAST_UPDATE_DATE            :=       hr_api.g_date;
l_location_rec.LAST_UPDATED_BY             :=       hr_api.g_number;
l_location_rec.LAST_UPDATE_LOGIN           :=       hr_api.g_number;
l_location_rec.CREATED_BY                  :=       hr_api.g_number;
l_location_rec.CREATION_DATE               :=       hr_api.g_date;
l_location_rec.OBJECT_VERSION_NUMBER       :=       hr_api.g_number;
l_location_rec.TP_HEADER_ID                :=       hr_api.g_number;
l_location_rec.ECE_TP_LOCATION_CODE        :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE_CATEGORY   :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE1           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE2           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE3           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE4           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE5           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE6           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE7           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE8           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE9           :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE10          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE11          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE12          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE13          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE14          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE15          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE16          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE17          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE18          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE19          :=       hr_api.g_varchar2;
l_location_rec.GLOBAL_ATTRIBUTE20          :=       hr_api.g_varchar2;
l_location_rec.BUSINESS_GROUP_ID           :=       hr_api.g_number;
l_location_rec.LOC_INFORMATION13           :=       hr_api.g_varchar2;
l_location_rec.LOC_INFORMATION14           :=       hr_api.g_varchar2;
l_location_rec.LOC_INFORMATION15           :=       hr_api.g_varchar2;
l_location_rec.LOC_INFORMATION16           :=       hr_api.g_varchar2;
l_location_rec.LOC_INFORMATION17           :=       hr_api.g_varchar2;
l_location_rec.LOC_INFORMATION18           :=       hr_api.g_varchar2;
l_location_rec.LOC_INFORMATION19           :=       hr_api.g_varchar2;
l_location_rec.LOC_INFORMATION20           :=       hr_api.g_varchar2;
l_location_rec.DERIVED_LOCALE              :=       hr_api.g_varchar2;
l_location_rec.LEGAL_ADDRESS_FLAG          :=       hr_api.g_varchar2;
l_location_rec.TIMEZONE_CODE               :=       hr_api.g_varchar2;

  return l_location_rec;

exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Location_Rec;

-- =============================================================================
-- Get_Record_Values:
-- =============================================================================
function Get_Record_Values
        (p_interface_code in varchar2 default null)
         return hr_locations_all%rowtype is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='Y';
  --and bic.interface_col_type <> 2;

  -- To query cols which are not displayed (DFF segments)
   cursor bne_cols_no_disp(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='N';

  l_location_rec            hr_locations_all%rowtype;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_package||'Get_Record_Values';

Begin
   l_location_rec := Default_Location_Rec;

  for col_rec in bne_cols (p_interface_code)
  loop
     case col_rec.interface_col_name
     when 'p_location_code' then
        l_location_rec.location_code  := g_location_rec.location_code;
     when 'p_description' then
        l_location_rec.description  := g_location_rec.description;
     when 'p_timezone_code' then
        l_location_rec.timezone_code  := g_location_rec.timezone_code;
     when 'p_tp_header_id' then
        l_location_rec.tp_header_id   := g_location_rec.tp_header_id;
     when 'p_ece_tp_location_code' then
        l_location_rec.ece_tp_location_code  := g_location_rec.ece_tp_location_code;
     when 'p_bill_to_site_flag' then
        l_location_rec.bill_to_site_flag  := g_location_rec.bill_to_site_flag;
     when 'p_designated_receiver_id' then
        l_location_rec.designated_receiver_id := g_location_rec.designated_receiver_id;
     when 'p_in_organization_flag' then
        l_location_rec.in_organization_flag := g_location_rec.in_organization_flag;
     when 'p_inactive_date' then
        l_location_rec.inactive_date  := g_location_rec.inactive_date;
     when 'p_inventory_organization_id' then
        l_location_rec.inventory_organization_id := g_location_rec.inventory_organization_id;
     when 'p_office_site_flag' then
        l_location_rec.office_site_flag := g_location_rec.office_site_flag;
     when 'p_receiving_site_flag' then
        l_location_rec.receiving_site_flag := g_location_rec.receiving_site_flag;
     when 'p_ship_to_location_id' then
        l_location_rec.ship_to_location_id := g_location_rec.ship_to_location_id;
     when 'p_ship_to_site_flag' then
        l_location_rec.ship_to_site_flag := g_location_rec.ship_to_site_flag;
     when 'style' then
        l_location_rec.style := g_location_rec.style;
        if l_location_rec.style is not null then
           for col_rec1 in bne_cols_no_disp(p_interface_code) loop
             case col_rec1.interface_col_name
             when 'address_line_1' then
                l_location_rec.address_line_1 := g_location_rec.address_line_1;
             when 'address_line_2' then
                l_location_rec.address_line_2 := g_location_rec.address_line_2;
             when 'address_line_3' then
                l_location_rec.address_line_3 := g_location_rec.address_line_3;
             when 'country' then
                l_location_rec.country := g_location_rec.country;
             when 'postal_code' then
                l_location_rec.postal_code := g_location_rec.postal_code;
             when 'region_1' then
                l_location_rec.region_1 := g_location_rec.region_1;
             when 'region_2' then
                l_location_rec.region_2 := g_location_rec.region_2;
             when 'region_3' then
                l_location_rec.region_3 := g_location_rec.region_3;
             when 'telephone_number_1' then
                l_location_rec.telephone_number_1 := g_location_rec.telephone_number_1;
             when 'telephone_number_2' then
                l_location_rec.telephone_number_2 := g_location_rec.telephone_number_2;
             when 'telephone_number_3' then
                l_location_rec.telephone_number_3 := g_location_rec.telephone_number_3;
             when 'town_or_city' then
                l_location_rec.town_or_city := g_location_rec.town_or_city;
             when 'loc_information13' then
                l_location_rec.loc_information13 := g_location_rec.loc_information13;
             when 'loc_information14' then
                l_location_rec.loc_information14 := g_location_rec.loc_information14;
             when 'loc_information15' then
                l_location_rec.loc_information15 := g_location_rec.loc_information15;
             when 'loc_information16' then
                l_location_rec.loc_information16 := g_location_rec.loc_information16;
             when 'loc_information17' then
                l_location_rec.loc_information17 := g_location_rec.loc_information17;
             when 'loc_information18' then
                l_location_rec.loc_information18 := g_location_rec.loc_information18;
             when 'loc_information19' then
                l_location_rec.loc_information19 := g_location_rec.loc_information19;
             when 'loc_information20' then
                l_location_rec.loc_information20 := g_location_rec.loc_information20;
             else
               null;
             end case;
           end loop;
        end if;
     when 'p_tax_name' then
        l_location_rec.tax_name := g_location_rec.tax_name;
     when 'attribute_category' then
        l_location_rec.attribute_category := g_location_rec.attribute_category;
        if l_location_rec.attribute_category is not null then
           for col_rec1 in bne_cols_no_disp(p_interface_code) loop
             case col_rec1.interface_col_name
                when 'attribute1' then
                   l_location_rec.attribute1 := g_location_rec.attribute1;
                when 'attribute2' then
                   l_location_rec.attribute2 := g_location_rec.attribute2;
                when 'attribute3' then
                   l_location_rec.attribute3 := g_location_rec.attribute3;
                when 'attribute4' then
                   l_location_rec.attribute4 := g_location_rec.attribute4;
                when 'attribute5' then
                   l_location_rec.attribute5 := g_location_rec.attribute5;
                when 'attribute6' then
                   l_location_rec.attribute6 := g_location_rec.attribute6;
                when 'attribute7' then
                   l_location_rec.attribute7 := g_location_rec.attribute7;
                when 'attribute8' then
                   l_location_rec.attribute8 := g_location_rec.attribute8;
                when 'attribute9' then
                   l_location_rec.attribute9 := g_location_rec.attribute9;
                when 'attribute10' then
                   l_location_rec.attribute10 := g_location_rec.attribute10;
                when 'attribute11' then
                   l_location_rec.attribute11 := g_location_rec.attribute11;
                when 'attribute12' then
                   l_location_rec.attribute12 := g_location_rec.attribute12;
                when 'attribute13' then
                   l_location_rec.attribute13 := g_location_rec.attribute13;
                when 'attribute14' then
                   l_location_rec.attribute14 := g_location_rec.attribute14;
                when 'attribute15' then
                   l_location_rec.attribute15 := g_location_rec.attribute15;
                when 'attribute16' then
                   l_location_rec.attribute16 := g_location_rec.attribute16;
                when 'attribute17' then
                   l_location_rec.attribute17 := g_location_rec.attribute17;
                when 'attribute18' then
                   l_location_rec.attribute18 := g_location_rec.attribute18;
                when 'attribute19' then
                   l_location_rec.attribute19 := g_location_rec.attribute19;
                when 'attribute20' then
                   l_location_rec.attribute20 := g_location_rec.attribute20;
             else
                null;
             end case;
           end loop;
        end if;
     when 'global_attribute_category' then
        l_location_rec.global_attribute_category := g_location_rec.global_attribute_category;
        if l_location_rec.attribute_category is not null then
           for col_rec1 in bne_cols_no_disp(p_interface_code) loop
             case col_rec1.interface_col_name
                when 'global_attribute1' then
                   l_location_rec.global_attribute1 := g_location_rec.global_attribute1;
                when 'global_attribute2' then
                   l_location_rec.global_attribute2 := g_location_rec.global_attribute2;
                when 'global_attribute3' then
                   l_location_rec.global_attribute3 := g_location_rec.global_attribute3;
                when 'global_attribute4' then
                   l_location_rec.global_attribute4 := g_location_rec.global_attribute4;
                when 'global_attribute5' then
                   l_location_rec.global_attribute5 := g_location_rec.global_attribute5;
                when 'global_attribute6' then
                   l_location_rec.global_attribute6 := g_location_rec.global_attribute6;
                when 'global_attribute7' then
                   l_location_rec.global_attribute7 := g_location_rec.global_attribute7;
                when 'global_attribute8' then
                   l_location_rec.global_attribute8 := g_location_rec.global_attribute8;
                when 'global_attribute9' then
                   l_location_rec.global_attribute9 := g_location_rec.global_attribute9;
                when 'global_attribute10' then
                   l_location_rec.global_attribute10 := g_location_rec.global_attribute10;
                when 'global_attribute11' then
                   l_location_rec.global_attribute11 := g_location_rec.global_attribute11;
                when 'global_attribute12' then
                   l_location_rec.global_attribute12 := g_location_rec.global_attribute12;
                when 'global_attribute13' then
                   l_location_rec.global_attribute13 := g_location_rec.global_attribute13;
                when 'global_attribute14' then
                   l_location_rec.global_attribute14 := g_location_rec.global_attribute14;
                when 'global_attribute15' then
                   l_location_rec.global_attribute15 := g_location_rec.global_attribute15;
                when 'global_attribute16' then
                   l_location_rec.global_attribute16 := g_location_rec.global_attribute16;
                when 'global_attribute17' then
                   l_location_rec.global_attribute17 := g_location_rec.global_attribute17;
                when 'global_attribute18' then
                   l_location_rec.global_attribute18 := g_location_rec.global_attribute18;
                when 'global_attribute19' then
                   l_location_rec.global_attribute19 := g_location_rec.global_attribute19;
                when 'global_attribute20' then
                   l_location_rec.global_attribute20 := g_location_rec.global_attribute20;
             else
                null;
             end case;
           end loop;
        end if;
     else
        null;
     end case;
 end loop;
  return l_location_rec;
end Get_Record_Values;



PROCEDURE INSUPD_LOCATION
     (p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_code                  IN  VARCHAR2
     ,p_description                    IN  VARCHAR2  DEFAULT NULL
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT NULL
     ,p_tp_header_id                   IN  NUMBER    DEFAULT NULL
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT NULL
     ,p_bill_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_country                        IN  VARCHAR2  DEFAULT NULL
     ,p_designated_receiver_id         IN  NUMBER    DEFAULT NULL
     ,p_in_organization_flag           IN  VARCHAR2  DEFAULT 'Y'
     ,p_inactive_date                  IN  DATE      DEFAULT NULL
     ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
     ,p_inventory_organization_id      IN  NUMBER    DEFAULT NULL
     ,p_office_site_flag               IN  VARCHAR2  DEFAULT 'Y'
     ,p_postal_code                    IN  VARCHAR2  DEFAULT NULL
     ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT 'Y'
     ,p_region_1                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_2                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_3                       IN  VARCHAR2  DEFAULT NULL
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT NULL
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_style                          IN  VARCHAR2  DEFAULT NULL
     ,p_tax_name                       IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT NULL
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information13              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information14              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information15              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information16              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information17              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information18              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information19              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information20              IN  VARCHAR2  DEFAULT NULL
     ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
     ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute_category      IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute1              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute2              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute3              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute4              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute5              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute6              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute7              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute8              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute9              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute10             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute11             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute12             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute13             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute14             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute15             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute16             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute17             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute18             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute19             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute20             IN  VARCHAR2  DEFAULT NULL
     ,p_business_group_id              IN  NUMBER    DEFAULT NULL
     ,p_crt_upd                        IN  VARCHAR2  DEFAULT NULL
     ,p_migration_flag                 IN  VARCHAR2  DEFAULT NULL
     ,p_interface_code                 IN  VARCHAR2  DEFAULT NULL
     ,p_location_id                    IN  NUMBER    DEFAULT NULL
     ,p_global_flag                    IN  VARCHAR2  DEFAULT NULL) IS


     cursor c_location_rec(c_location_code  in varchar2, c_business_group_id in number) is
        select location_id from hr_locations_all where location_code = c_location_code
          and business_group_id = c_business_group_id;

  l_location_id              number;
  l_object_version_number    number;
  l_create_flag              number;

  e_upl_not_allowed exception; -- when mode is 'View Only'
  e_crt_not_allowed exception; -- when mode is 'Update Only'
  g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
  g_crt_err_msg varchar2(100) := 'Creating NOT allowed.';
  l_proc    varchar2(72) := g_package ||'PQP_RIW_LOCATION_WRAPPER';
  l_migration_flag     varchar2(10);
  l_business_group_id  number(10);

  temp_rec                   hr_locations_all%rowtype;

  begin
    hr_utility.set_location('Entered PQP_RIW_LOCATION_WRAPPER.INSUPD_LOCATION', 5);

    l_migration_flag := p_migration_flag;

    if p_global_flag = 'Y' then
        l_business_group_id := null;
    else
        l_business_group_id := p_business_group_id;
    end if;

    if (p_crt_upd = 'D') then
      raise e_upl_not_allowed;  -- View only flag is enabled but Trying to Upload
    end if;

    open c_location_rec(p_location_code, p_business_group_id);
     fetch  c_location_rec into l_location_id;
      if c_location_rec%notfound then
          if l_migration_flag = 'N' then
              if p_location_id is null then
                  l_create_flag := 1;
              else
                  l_create_flag := 2;
                  l_location_id := p_location_id;
              end if;
          else
              l_create_flag := 1;
          end if;
          close c_location_rec;
      else
          l_create_flag := 2;
          close c_location_rec;
      end if;

     if(l_create_flag = 1) then
        if (p_crt_upd = 'U') then
            raise e_crt_not_allowed;  -- Update only flag is enabled but Trying to Create
         end if;
         hr_location_api.create_location
               (p_validate    => false
               ,p_effective_date   => p_effective_date
               ,p_language_code    => p_language_code
               ,p_location_code    => p_location_code
               ,p_description      => p_description
               ,p_timezone_code    => p_timezone_code
               ,p_tp_header_id     => p_tp_header_id
               ,p_ece_tp_location_code => p_ece_tp_location_code
               ,p_address_line_1       => p_address_line_1
               ,p_address_line_2       => p_address_line_2
               ,p_address_line_3       => p_address_line_3
               ,p_bill_to_site_flag   => p_bill_to_site_flag
               ,p_country              => p_country
               ,p_designated_receiver_id  => p_designated_receiver_id
               ,p_in_organization_flag     => p_in_organization_flag
               ,p_inactive_date        => p_inactive_date
               ,p_operating_unit_id    => p_operating_unit_id
               ,p_inventory_organization_id    => p_inventory_organization_id
               ,p_office_site_flag         => p_office_site_flag
               ,p_postal_code          => p_postal_code
               ,p_receiving_site_flag   => p_receiving_site_flag
               ,p_region_1              => p_region_1
               ,p_region_2            => p_region_2
               ,p_region_3           => p_region_3
               ,p_ship_to_location_id   => p_ship_to_location_id
               ,p_ship_to_site_flag     => p_ship_to_site_flag
               ,p_style              => p_style
               ,p_tax_name          => p_tax_name
               ,p_telephone_number_1    => p_telephone_number_1
               ,p_telephone_number_2     => p_telephone_number_2
               ,p_telephone_number_3    => p_telephone_number_3
               ,p_town_or_city       => p_town_or_city
               ,p_loc_information13   => p_loc_information13
               ,p_loc_information14   => p_loc_information14
               ,p_loc_information15   => p_loc_information15
               ,p_loc_information16   => p_loc_information16
               ,p_loc_information17   => p_loc_information17
               ,p_loc_information18   => p_loc_information18
               ,p_loc_information19   => p_loc_information19
               ,p_loc_information20   => p_loc_information20
               ,p_attribute_category  => p_attribute_category
               ,p_attribute1           => p_attribute1
               ,p_attribute2           => p_attribute2
               ,p_attribute3           => p_attribute3
               ,p_attribute4          => p_attribute4
               ,p_attribute5           => p_attribute5
               ,p_attribute6            => p_attribute6
               ,p_attribute7           => p_attribute7
               ,p_attribute8           => p_attribute8
               ,p_attribute9           => p_attribute9
               ,p_attribute10          => p_attribute10
               ,p_attribute11          => p_attribute11
               ,p_attribute12          => p_attribute12
               ,p_attribute13          => p_attribute13
               ,p_attribute14          => p_attribute14
               ,p_attribute15          => p_attribute15
               ,p_attribute16          => p_attribute16
               ,p_attribute17           => p_attribute17
               ,p_attribute18          => p_attribute18
               ,p_attribute19           => p_attribute19
               ,p_attribute20          => p_attribute20
               ,p_global_attribute_category    => p_global_attribute_category
               ,p_global_attribute1           => p_global_attribute1
               ,p_global_attribute2           => p_global_attribute2
               ,p_global_attribute3           => p_global_attribute3
               ,p_global_attribute4          => p_global_attribute4
               ,p_global_attribute5           => p_global_attribute5
               ,p_global_attribute6            => p_global_attribute6
               ,p_global_attribute7           => p_global_attribute7
               ,p_global_attribute8           => p_global_attribute8
               ,p_global_attribute9           => p_global_attribute9
               ,p_global_attribute10          => p_global_attribute10
               ,p_global_attribute11          => p_global_attribute11
               ,p_global_attribute12          => p_global_attribute12
               ,p_global_attribute13          => p_global_attribute13
               ,p_global_attribute14          => p_global_attribute14
               ,p_global_attribute15          => p_global_attribute15
               ,p_global_attribute16          => p_global_attribute16
               ,p_global_attribute17           => p_global_attribute17
               ,p_global_attribute18          => p_global_attribute18
               ,p_global_attribute19           => p_global_attribute19
               ,p_global_attribute20          => p_global_attribute20
               ,p_business_group_id           => l_business_group_id
               ,p_location_id                => l_location_id
               ,p_object_version_number      => l_object_version_number
               );
     else

            select style into g_style from hr_locations_all where location_id = l_location_id;

               g_location_rec.location_code    := p_location_code;
               g_location_rec.description      := p_description;
               g_location_rec.timezone_code    := p_timezone_code;
               g_location_rec.tp_header_id     := p_tp_header_id;
               g_location_rec.ece_tp_location_code := p_ece_tp_location_code;
               g_location_rec.address_line_1       := p_address_line_1;
               g_location_rec.address_line_2       := p_address_line_2;
               g_location_rec.address_line_3       := p_address_line_3;
               g_location_rec.bill_to_site_flag   := p_bill_to_site_flag;
               g_location_rec.country              := p_country;
               g_location_rec.designated_receiver_id  := p_designated_receiver_id;
               g_location_rec.in_organization_flag     := p_in_organization_flag;
               g_location_rec.inactive_date        := p_inactive_date;
               g_location_rec.inventory_organization_id    := p_inventory_organization_id;
               g_location_rec.office_site_flag         := p_office_site_flag;
               g_location_rec.postal_code          := p_postal_code;
               g_location_rec.receiving_site_flag   := p_receiving_site_flag;
               g_location_rec.region_1              := p_region_1 ;
               g_location_rec.region_2            := p_region_2 ;
               g_location_rec.region_3           := p_region_3  ;
               g_location_rec.ship_to_location_id   := p_ship_to_location_id;
               g_location_rec.ship_to_site_flag     := p_ship_to_site_flag;
               g_location_rec.style              := p_style;
               g_location_rec.tax_name          := p_tax_name;
               g_location_rec.telephone_number_1    := p_telephone_number_1  ;
               g_location_rec.telephone_number_2     := p_telephone_number_2;
               g_location_rec.telephone_number_3    := p_telephone_number_3;
               g_location_rec.town_or_city       := p_town_or_city ;
               g_location_rec.loc_information13   := p_loc_information13;
               g_location_rec.loc_information14   := p_loc_information14;
               g_location_rec.loc_information15   := p_loc_information15;
               g_location_rec.loc_information16   := p_loc_information16;
               g_location_rec.loc_information17   := p_loc_information17;
               g_location_rec.loc_information18   := p_loc_information18;
               g_location_rec.loc_information19   := p_loc_information19;
               g_location_rec.loc_information20   := p_loc_information20;
               g_location_rec.attribute_category  := p_attribute_category;
               g_location_rec.attribute1           := p_attribute1;
               g_location_rec.attribute2           := p_attribute2;
               g_location_rec.attribute3           := p_attribute3;
               g_location_rec.attribute4          := p_attribute4;
               g_location_rec.attribute5           := p_attribute5;
               g_location_rec.attribute6            := p_attribute6;
               g_location_rec.attribute7           := p_attribute7;
               g_location_rec.attribute8           := p_attribute8;
               g_location_rec.attribute9           := p_attribute9;
               g_location_rec.attribute10          := p_attribute10;
               g_location_rec.attribute11          := p_attribute11;
               g_location_rec.attribute12          := p_attribute12;
               g_location_rec.attribute13          := p_attribute13;
               g_location_rec.attribute14          := p_attribute14;
               g_location_rec.attribute15          := p_attribute15;
               g_location_rec.attribute16          := p_attribute16;
               g_location_rec.attribute17           := p_attribute17;
               g_location_rec.attribute18          := p_attribute18;
               g_location_rec.attribute19           := p_attribute19;
               g_location_rec.attribute20          := p_attribute20;
               g_location_rec.global_attribute_category    := p_global_attribute_category;
               g_location_rec.global_attribute1           := p_global_attribute1;
               g_location_rec.global_attribute2           := p_global_attribute2;
               g_location_rec.global_attribute3           := p_global_attribute3;
               g_location_rec.global_attribute4          := p_global_attribute4;
               g_location_rec.global_attribute5           := p_global_attribute5;
               g_location_rec.global_attribute6            := p_global_attribute6;
               g_location_rec.global_attribute7           := p_global_attribute7;
               g_location_rec.global_attribute8           := p_global_attribute8;
               g_location_rec.global_attribute9           := p_global_attribute9;
               g_location_rec.global_attribute10          := p_global_attribute10;
               g_location_rec.global_attribute11          := p_global_attribute11;
               g_location_rec.global_attribute12          := p_global_attribute12;
               g_location_rec.global_attribute13          := p_global_attribute13;
               g_location_rec.global_attribute14          := p_global_attribute14;
               g_location_rec.global_attribute15          := p_global_attribute15;
               g_location_rec.global_attribute16          := p_global_attribute16;
               g_location_rec.global_attribute17           := p_global_attribute17;
               g_location_rec.global_attribute18          := p_global_attribute18;
               g_location_rec.global_attribute19           := p_global_attribute19;
               g_location_rec.global_attribute20          := p_global_attribute20;


               temp_rec := Get_Record_Values(p_interface_code => p_interface_code);

               select object_version_number into l_object_version_number from
                      hr_locations_all where location_id = l_location_id;

               hr_location_api.update_location(
                p_validate    => false
               ,p_effective_date   => p_effective_date
               ,p_location_id      => l_location_id
               ,p_language_code    => p_language_code
               ,p_location_code    => temp_rec.location_code
               ,p_description      => temp_rec.description
               ,p_timezone_code    => temp_rec.timezone_code
               ,p_tp_header_id     => temp_rec.tp_header_id
               ,p_ece_tp_location_code => temp_rec.ece_tp_location_code
               ,p_address_line_1       => temp_rec.address_line_1
               ,p_address_line_2       => temp_rec.address_line_2
               ,p_address_line_3       => temp_rec.address_line_3
               ,p_bill_to_site_flag   => temp_rec.bill_to_site_flag
               ,p_country              => temp_rec.country
               ,p_designated_receiver_id  => temp_rec.designated_receiver_id
               ,p_in_organization_flag     => temp_rec.in_organization_flag
               ,p_inactive_date        => temp_rec.inactive_date
               ,p_operating_unit_id    => p_operating_unit_id
               ,p_inventory_organization_id    => temp_rec.inventory_organization_id
               ,p_office_site_flag         => temp_rec.office_site_flag
               ,p_postal_code          => temp_rec.postal_code
               ,p_receiving_site_flag   => temp_rec.receiving_site_flag
               ,p_region_1              => temp_rec.region_1
               ,p_region_2            => temp_rec.region_2
               ,p_region_3           => temp_rec.region_3
               ,p_ship_to_location_id   => temp_rec.ship_to_location_id
               ,p_ship_to_site_flag     => temp_rec.ship_to_site_flag
               ,p_style              => temp_rec.style
               ,p_tax_name          => temp_rec.tax_name
               ,p_telephone_number_1    => temp_rec.telephone_number_1
               ,p_telephone_number_2     => temp_rec.telephone_number_2
               ,p_telephone_number_3    => temp_rec.telephone_number_3
               ,p_town_or_city       => temp_rec.town_or_city
               ,p_loc_information13   => temp_rec.loc_information13
               ,p_loc_information14   => temp_rec.loc_information14
               ,p_loc_information15   => temp_rec.loc_information15
               ,p_loc_information16   => temp_rec.loc_information16
               ,p_loc_information17   => temp_rec.loc_information17
               ,p_loc_information18   => temp_rec.loc_information18
               ,p_loc_information19   => temp_rec.loc_information19
               ,p_loc_information20   => temp_rec.loc_information20
               ,p_attribute_category  => temp_rec.attribute_category
               ,p_attribute1           => temp_rec.attribute1
               ,p_attribute2           => temp_rec.attribute2
               ,p_attribute3           => temp_rec.attribute3
               ,p_attribute4          => temp_rec.attribute4
               ,p_attribute5           => temp_rec.attribute5
               ,p_attribute6            => temp_rec.attribute6
               ,p_attribute7           => temp_rec.attribute7
               ,p_attribute8           => temp_rec.attribute8
               ,p_attribute9           => temp_rec.attribute9
               ,p_attribute10          => temp_rec.attribute10
               ,p_attribute11          => temp_rec.attribute11
               ,p_attribute12          => temp_rec.attribute12
               ,p_attribute13          => temp_rec.attribute13
               ,p_attribute14          => temp_rec.attribute14
               ,p_attribute15          => temp_rec.attribute15
               ,p_attribute16          => temp_rec.attribute16
               ,p_attribute17           => temp_rec.attribute17
               ,p_attribute18          => temp_rec.attribute18
               ,p_attribute19           => temp_rec.attribute19
               ,p_attribute20          => temp_rec.attribute20
               ,p_global_attribute_category    => temp_rec.global_attribute_category
               ,p_global_attribute1           => temp_rec.global_attribute1
               ,p_global_attribute2           => temp_rec.global_attribute2
               ,p_global_attribute3           => temp_rec.global_attribute3
               ,p_global_attribute4          => temp_rec.global_attribute4
               ,p_global_attribute5           => temp_rec.global_attribute5
               ,p_global_attribute6            => temp_rec.global_attribute6
               ,p_global_attribute7           => temp_rec.global_attribute7
               ,p_global_attribute8           => temp_rec.global_attribute8
               ,p_global_attribute9           => temp_rec.global_attribute9
               ,p_global_attribute10          => temp_rec.global_attribute10
               ,p_global_attribute11          => temp_rec.global_attribute11
               ,p_global_attribute12          => temp_rec.global_attribute12
               ,p_global_attribute13          => temp_rec.global_attribute13
               ,p_global_attribute14          => temp_rec.global_attribute14
               ,p_global_attribute15          => temp_rec.global_attribute15
               ,p_global_attribute16          => temp_rec.global_attribute16
               ,p_global_attribute17           => temp_rec.global_attribute17
               ,p_global_attribute18          => temp_rec.global_attribute18
               ,p_global_attribute19           => temp_rec.global_attribute19
               ,p_global_attribute20          => temp_rec.global_attribute20
               ,p_object_version_number      => l_object_version_number
               );

     end if;



exception
--  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    --rollback to enrollment_proc;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
--    p_object_version_number        := null;
  --  p_finance_line_id              := l_finance_line_id;
--    p_return_status := hr_multi_message.get_return_status_disable;
--    hr_utility.set_location(' Leaving:' || l_proc, 30);
--  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
  --  rollback to enrollment_proc;


  when e_upl_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_upl_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 90);
    hr_utility.raise_error;
  when e_crt_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_crt_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 100);
    hr_utility.raise_error;
  when others then
   --l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_location('SQLERRM :' || SQLERRM,90);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,500) );
   hr_utility.set_location('Leaving: ' || l_proc, 110);
   hr_utility.raise_error;
    --if hr_multi_message.unexpected_error_add(l_proc) then
      -- hr_utility.set_location(' Leaving:' || l_proc,40);
       --raise;
    --end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
--    p_object_version_number        := null;
--    p_finance_line_id              := l_finance_line_id;
    --p_return_status := hr_multi_message.get_return_status_disable;
 --   hr_utility.set_location(' Leaving:' || l_proc,50);


  end INSUPD_LOCATION;
end PQP_RIW_LOCATION_WRAPPER;

/
