--------------------------------------------------------
--  DDL for Package Body HR_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOCATIONS_PKG" as
/* $Header: peloc01t.pkb 115.5 2002/12/06 11:27:29 pkakar ship $ */

 /*-----------------------------------------------------------------------------
 -- Name                                                                    --
 --   set_ship_to_location                                              --
 -- Purpose                                                                 --
 --   called from within insert and update in this pkg in so that the       --
 --   ship-to-locatin-id is set to be the same as the location-id IF        --
 --   ship-to-location is NULL						    --
 -- Arguments                                                               --
 --   see below                                                             --
 ============================================================================*/
 --
 procedure set_ship_to_location(p_Purchasing_Ins in varchar2,
                   p_Inventory_Ins in varchar2,
                   p_Ship_To_Location in varchar2,
                   p_Location_Id in number,
                   p_Ship_To_Location_Id in out nocopy number,
		   p_location_code in varchar2	)
 is
 begin
   if (p_Purchasing_Ins = 'Y' or p_Inventory_Ins = 'Y') and
                p_Ship_To_Location = p_location_code
   then
         p_Ship_To_Location_Id := p_Location_Id;
   else
	p_Ship_To_Location_Id := p_Ship_To_Location_Id;
   end if;
 end;
--
--
 /*-----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_des_rec                                              --
 -- Purpose                                                                 --
 --   Called from post-query because designated receiver is linked to a date --
 --    tracked table and designated receiver may not exist at session date  --
 --	it assumes that designated reseiver id is NOT NULL
 --	Persons cannot be deleted off the system so if the person is not seen
 --      at session date then only a search of person ahead of session date
 --      need be done.
 -- Arguments                                                               --
 --   See Below.                                                            --
 --									    --
 ============================================================================*/
--
--
procedure get_des_rec (
p_designated_receiver_id in number,
p_designated_receiver in out nocopy varchar2) is
--
cursor c1 is
	select ppf.full_name
	from   per_people_f ppf
	,      fnd_sessions ses
	where  ses.session_id = userenv('sessionid')
	and    person_id = p_designated_receiver_id
	and    ses.effective_date
		between ppf.effective_start_date
                    and ppf.effective_end_date;
--
cursor c2 is
	  select ppf.full_name
          from   per_people_f ppf
	  where  ppf.person_id = p_designated_receiver_id
	  and    ppf.effective_start_date = (
          		select min(ppf2.effective_start_date)
          		from   per_people_f ppf2
			where  ppf2.person_id = ppf.person_id );
--
begin
--
hr_utility.set_location('hr_location_pkg.get_des_rec',1);
--
open c1;
--
  fetch c1 into p_designated_receiver;
  IF c1%notfound THEN
     close c1;
     open c2;
     hr_utility.set_location('hr_location_pkg.get_des_rec',2);
     fetch c2 into p_designated_receiver;
     close c2;
  END IF;
  close c1;
--
end get_des_rec;
--
 /*-----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_inv_org                                              --
 -- Purpose                                                                 --
 --   Called from post-query because inventory organization is non db       --
 --    and requires an explicit population
 -- Arguments                                                               --
 --   See Below.                                                            --
 --									    --
 ============================================================================*/
--
--
procedure get_inv_org (
p_inventory_orgnization_id in number,
p_organization_name out nocopy varchar2) is
--
cursor c3 is
	select  OOD.ORGANIZATION_CODE ||'-'||
                OOD.ORGANIZATION_NAME
	FROM ORG_ORGANIZATION_DEFINITIONS OOD
        where OOD.ORGANIZATION_ID = p_inventory_orgnization_id ;
--
begin
--
open c3;
--
  fetch c3 into p_organization_name;
--
close c3;
--
end get_inv_org;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_start_data                                              --
 -- Purpose                                                                 --
 --   Called from hr_init_forms so that only one journey to the db is       --
 --    made instead of 3
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --				                                         --
 -----------------------------------------------------------------------------
procedure get_start_data (
	p_resp_appl_id      in  number,
	p_legislation_code  in  varchar2,
	p_short_name        in out nocopy varchar2,
	p_resp_name         in out nocopy varchar2,
	p_country           in out nocopy varchar2,
	p_territory_code    in out nocopy varchar2) is
--
cursor c4 is
	select application_name
	from fnd_application_vl
	where application_id = p_resp_appl_id;
--
cursor c5 is
        SELECT FT.TERRITORY_SHORT_NAME,FT.TERRITORY_CODE
       	FROM FND_TERRITORIES_VL FT,
       	FND_DESCR_FLEX_CONTEXTS FDFC
       	WHERE FT.TERRITORY_CODE = p_legislation_code
       	AND substr(FDFC.DESCRIPTIVE_FLEX_CONTEXT_CODE,1,2) = FT.TERRITORY_CODE
	AND  FDFC.DESCRIPTIVE_FLEXFIELD_NAME = 'Address Location'
       	AND  FDFC.ENABLED_FLAG = 'Y';
--
begin
--
hr_utility.set_location('hr_locations_pkg.get_start_data',1);
--
if p_resp_appl_id is not null then
open c4;
--
  fetch c4 into p_resp_name;
--
close c4;
--
end if;
--
hr_utility.set_location('hr_locations_pkg.get_start_data',2);
--
open c5;
--
  fetch c5 into p_country,
		p_territory_code;
--
close c5;
--
end get_start_data;
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   validate_insert_location                                              --
 -- Purpose                                                                 --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   1. Is the location code unique.                                        --
 -----------------------------------------------------------------------------
--
 procedure validate_insert_location
  ( p_location_code 	varchar2,
        p_location_id           number,
    p_inventory_organization_id number  ) is
v_location_id number;
--
cursor csr_location_exists is
     SELECT l.location_id
     from   hr_locations l
     where  upper(l.location_code) = upper(p_location_code)
       and  (l.location_id <> p_location_id or
             p_location_id is null)
       AND (l.inventory_organization_id = p_inventory_organization_id
            OR p_inventory_organization_id is NULL);
--
begin
--
hr_utility.set_location('hr_location_pkg.validate_insert_location',1);
--
open csr_location_exists;
--
     fetch csr_location_exists into v_location_id;
     IF csr_location_exists%found then
     close csr_location_exists;
     hr_utility.set_message(801,'PAY_7681_USER_LOC_TABLE_UNIQUE');
     hr_utility.raise_error;
     END IF;
--
close csr_location_exists;
--
end validate_insert_location;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Location_Id                         IN OUT NOCOPY NUMBER,
                     X_Entered_By                          NUMBER,
                     X_Location_Code                       VARCHAR2,
                     X_Address_Line_1                      VARCHAR2,
                     X_Address_Line_2                      VARCHAR2,
                     X_Address_Line_3                      VARCHAR2,
                     X_Bill_To_Site_Flag                   VARCHAR2,
                     X_Country                             VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Designated_Receiver_Id              NUMBER,
                     X_In_Organization_Flag                VARCHAR2,
                     X_Inactive_Date                       DATE,
                     X_Inventory_Organization_Id           NUMBER,
                     X_Office_Site_Flag                    VARCHAR2,
                     X_Postal_Code                         VARCHAR2,
                     X_Receiving_Site_Flag                 VARCHAR2,
                     X_Region_1                            VARCHAR2,
                     X_Region_2                            VARCHAR2,
                     X_Region_3                            VARCHAR2,
                     X_Ship_To_Location_Id             IN OUT NOCOPY    NUMBER,
                     X_Ship_To_Site_Flag                   VARCHAR2,
                     X_Style                               VARCHAR2,
                     X_Tax_Name                            VARCHAR2,
		     X_Ece_Tp_Location_Code                VARCHAR2,
                     X_Telephone_Number_1                  VARCHAR2,
                     X_Telephone_Number_2                  VARCHAR2,
                     X_Telephone_Number_3                  VARCHAR2,
                     X_Town_Or_City                        VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE ,
		     X_C_Purchasing_Ins                     VARCHAR2,
                     X_C_Inventory_Ins                      VARCHAR2,
		     X_Ship_To_Location			    VARCHAR2,
		     X_Global_Attribute_Category           VARCHAR2,
		     X_Global_Attribute1                   VARCHAR2,
		     X_Global_Attribute2                   VARCHAR2,
		     X_Global_Attribute3                   VARCHAR2,
		     X_Global_Attribute4                   VARCHAR2,
		     X_Global_Attribute5                   VARCHAR2,
		     X_Global_Attribute6                   VARCHAR2,
		     X_Global_Attribute7                   VARCHAR2,
		     X_Global_Attribute8                   VARCHAR2,
		     X_Global_Attribute9                   VARCHAR2,
		     X_Global_Attribute10                  VARCHAR2,
		     X_Global_Attribute11                  VARCHAR2,
		     X_Global_Attribute12                  VARCHAR2,
		     X_Global_Attribute13                  VARCHAR2,
		     X_Global_Attribute14                  VARCHAR2,
		     X_Global_Attribute15                  VARCHAR2,
		     X_Global_Attribute16                  VARCHAR2,
		     X_Global_Attribute17                  VARCHAR2,
		     X_Global_Attribute18                  VARCHAR2,
		     X_Global_Attribute19                  VARCHAR2,
		     X_Global_Attribute20                  VARCHAR2,
                     X_Loc_Information17                   VARCHAR2,
                     X_Loc_Information18                   VARCHAR2,
                     X_Loc_Information19                   VARCHAR2,
                     X_Loc_Information20                   VARCHAR2
) IS
   CURSOR C IS SELECT rowid FROM hr_locations
             WHERE location_id = X_Location_Id;
--
    CURSOR C2 IS SELECT hr_locations_s.nextval FROM sys.dual;
BEGIN
   hr_locations_pkg.validate_insert_location
	(X_Location_code,
         X_Location_id,
         X_Inventory_Organization_Id  );
   if (X_Location_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Location_Id;
     CLOSE C2;
   end if;
  set_ship_to_location(X_C_Purchasing_Ins,
		   X_C_Inventory_Ins,
		   X_Ship_To_Location,
		   X_Location_Id,
		   X_Ship_To_Location_Id,
                   X_Location_Code);
--
  INSERT INTO hr_locations(
          location_id,
          entered_by,
          location_code,
          address_line_1,
          address_line_2,
          address_line_3,
          bill_to_site_flag,
          country,
          description,
          designated_receiver_id,
          in_organization_flag,
          inactive_date,
          inventory_organization_id,
          office_site_flag,
          postal_code,
          receiving_site_flag,
          region_1,
          region_2,
          region_3,
          ship_to_location_id,
          ship_to_site_flag,
          style,
          tax_name,
	  ece_tp_location_code,
          telephone_number_1,
          telephone_number_2,
          telephone_number_3,
          town_or_city,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date,
	  global_attribute_category,
	  global_attribute1,
	  global_attribute2,
	  global_attribute3,
	  global_attribute4,
	  global_attribute5,
	  global_attribute6,
	  global_attribute7,
	  global_attribute8,
	  global_attribute9,
	  global_attribute10,
	  global_attribute11,
	  global_attribute12,
	  global_attribute13,
	  global_attribute14,
	  global_attribute15,
	  global_attribute16,
	  global_attribute17,
	  global_attribute18,
	  global_attribute19,
	  global_attribute20,
          loc_information17,
          loc_information18,
          loc_information19,
          loc_information20
          ) VALUES (
          X_Location_Id,
          X_Entered_By,
          X_Location_Code,
          X_Address_Line_1,
          X_Address_Line_2,
          X_Address_Line_3,
          X_Bill_To_Site_Flag,
          X_Country,
          X_Description,
          X_Designated_Receiver_Id,
          X_In_Organization_Flag,
          X_Inactive_Date,
          X_Inventory_Organization_Id,
          X_Office_Site_Flag,
          X_Postal_Code,
          X_Receiving_Site_Flag,
          X_Region_1,
          X_Region_2,
          X_Region_3,
          X_Ship_To_Location_Id,
          X_Ship_To_Site_Flag,
          X_Style,
          X_Tax_Name,
	  X_Ece_Tp_Location_Code,
          X_Telephone_Number_1,
          X_Telephone_Number_2,
          X_Telephone_Number_3,
          X_Town_Or_City,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Created_By,
          X_Creation_Date,
	  X_Global_Attribute_Category,
	  X_Global_Attribute1,
	  X_Global_Attribute2,
	  X_Global_Attribute3,
	  X_Global_Attribute4,
	  X_Global_Attribute5,
	  X_Global_Attribute6,
	  X_Global_Attribute7,
	  X_Global_Attribute8,
	  X_Global_Attribute9,
	  X_Global_Attribute10,
	  X_Global_Attribute11,
	  X_Global_Attribute12,
	  X_Global_Attribute13,
	  X_Global_Attribute14,
	  X_Global_Attribute15,
	  X_Global_Attribute16,
	  X_Global_Attribute17,
	  X_Global_Attribute18,
	  X_Global_Attribute19,
	  X_Global_Attribute20,
          X_Loc_Information17,
          X_Loc_Information18,
          X_Loc_Information19,
          X_Loc_Information20
  );
--
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                      'hr_locations_pkg.insert_row');
         hr_utility.set_message_token('STEP','2');
         hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Location_Id                           NUMBER,
                   X_Entered_By                            NUMBER,
                   X_Location_Code                         VARCHAR2,
                   X_Address_Line_1                        VARCHAR2,
                   X_Address_Line_2                        VARCHAR2,
                   X_Address_Line_3                        VARCHAR2,
                   X_Bill_To_Site_Flag                     VARCHAR2,
                   X_Country                               VARCHAR2,
                   X_Description                           VARCHAR2,
                   X_Designated_Receiver_Id                NUMBER,
                   X_In_Organization_Flag                  VARCHAR2,
                   X_Inactive_Date                         DATE,
                   X_Inventory_Organization_Id             NUMBER,
                   X_Office_Site_Flag                      VARCHAR2,
                   X_Postal_Code                           VARCHAR2,
                   X_Receiving_Site_Flag                   VARCHAR2,
                   X_Region_1                              VARCHAR2,
                   X_Region_2                              VARCHAR2,
                   X_Region_3                              VARCHAR2,
                   X_Ship_To_Location_Id                   NUMBER,
                   X_Ship_To_Site_Flag                     VARCHAR2,
                   X_Style                                 VARCHAR2,
                   X_Tax_Name                              VARCHAR2,
		   X_Ece_Tp_Location_Code                  VARCHAR2,
                   X_Telephone_Number_1                    VARCHAR2,
                   X_Telephone_Number_2                    VARCHAR2,
                   X_Telephone_Number_3                    VARCHAR2,
                   X_Town_Or_City                          VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2,
		   X_Global_Attribute_Category              VARCHAR2,
		   X_Global_Attribute1                      VARCHAR2,
		   X_Global_Attribute2                      VARCHAR2,
		   X_Global_Attribute3                      VARCHAR2,
		   X_Global_Attribute4                      VARCHAR2,
		   X_Global_Attribute5                      VARCHAR2,
		   X_Global_Attribute6                      VARCHAR2,
		   X_Global_Attribute7                      VARCHAR2,
		   X_GLobal_Attribute8                      VARCHAR2,
		   X_Global_Attribute9                      VARCHAR2,
		   X_Global_Attribute10                     VARCHAR2,
		   X_Global_Attribute11                     VARCHAR2,
		   X_Global_Attribute12                     VARCHAR2,
		   X_Global_Attribute13                     VARCHAR2,
		   X_Global_Attribute14                     VARCHAR2,
		   X_Global_Attribute15                     VARCHAR2,
                   X_Global_Attribute16                     VARCHAR2,
		   X_Global_Attribute17                     VARCHAR2,
		   X_Global_Attribute18                     VARCHAR2,
		   X_Global_Attribute19                     VARCHAR2,
		   X_Global_Attribute20                     VARCHAR2,
                   X_Loc_Information17                      VARCHAR2,
                   X_Loc_Information18                      VARCHAR2,
                   X_Loc_Information19                      VARCHAR2,
                   X_Loc_Information20                      VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   hr_locations
      WHERE  rowid = chartorowid(X_Rowid)
      FOR UPDATE of Location_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;

  end if;
  CLOSE C;

recinfo.tax_name := rtrim(recinfo.tax_name);
recinfo.ece_tp_location_code := rtrim(recinfo.ece_tp_location_code);
recinfo.telephone_number_1 := rtrim(recinfo.telephone_number_1);
recinfo.telephone_number_2 := rtrim(recinfo.telephone_number_2);
recinfo.telephone_number_3 := rtrim(recinfo.telephone_number_3);
recinfo.town_or_city := rtrim(recinfo.town_or_city);
recinfo.attribute_category := rtrim(recinfo.attribute_category);
recinfo.attribute1 := rtrim(recinfo.attribute1);
recinfo.attribute2 := rtrim(recinfo.attribute2);
recinfo.attribute3 := rtrim(recinfo.attribute3);
recinfo.attribute4 := rtrim(recinfo.attribute4);
recinfo.attribute5 := rtrim(recinfo.attribute5);
recinfo.attribute6 := rtrim(recinfo.attribute6);
recinfo.attribute7 := rtrim(recinfo.attribute7);
recinfo.attribute8 := rtrim(recinfo.attribute8);
recinfo.attribute9 := rtrim(recinfo.attribute9);
recinfo.attribute10 := rtrim(recinfo.attribute10);
recinfo.attribute11 := rtrim(recinfo.attribute11);
recinfo.attribute12 := rtrim(recinfo.attribute12);
recinfo.attribute13 := rtrim(recinfo.attribute13);
recinfo.attribute14 := rtrim(recinfo.attribute14);
recinfo.attribute15 := rtrim(recinfo.attribute15);
recinfo.attribute16 := rtrim(recinfo.attribute16);
recinfo.attribute17 := rtrim(recinfo.attribute17);
recinfo.attribute18 := rtrim(recinfo.attribute18);
recinfo.attribute19 := rtrim(recinfo.attribute19);
recinfo.attribute20 := rtrim(recinfo.attribute20);
recinfo.location_code := rtrim(recinfo.location_code);
recinfo.address_line_1 := rtrim(recinfo.address_line_1);
recinfo.address_line_2 := rtrim(recinfo.address_line_2);
recinfo.address_line_3 := rtrim(recinfo.address_line_3);
recinfo.bill_to_site_flag := rtrim(recinfo.bill_to_site_flag);
recinfo.country := rtrim(recinfo.country);
recinfo.description := rtrim(recinfo.description);
recinfo.in_organization_flag := rtrim(recinfo.in_organization_flag);
recinfo.office_site_flag := rtrim(recinfo.office_site_flag);
recinfo.postal_code := rtrim(recinfo.postal_code);
recinfo.receiving_site_flag := rtrim(recinfo.receiving_site_flag);
recinfo.region_1 := rtrim(recinfo.region_1);
recinfo.region_2 := rtrim(recinfo.region_2);
recinfo.region_3 := rtrim(recinfo.region_3);
recinfo.ship_to_site_flag := rtrim(recinfo.ship_to_site_flag);
recinfo.style := rtrim(recinfo.style);
recinfo.global_attribute_category := rtrim(recinfo.global_attribute_category);
recinfo.global_attribute1 := rtrim(recinfo.global_attribute1);
recinfo.global_attribute2 := rtrim(recinfo.global_attribute2);
recinfo.global_attribute3 := rtrim(recinfo.global_attribute3);
recinfo.global_attribute4 := rtrim(recinfo.global_attribute4);
recinfo.global_attribute5 := rtrim(recinfo.global_attribute5);
recinfo.global_attribute6 := rtrim(recinfo.global_attribute6);
recinfo.global_attribute7 := rtrim(recinfo.global_attribute7);
recinfo.global_attribute8 := rtrim(recinfo.global_attribute8);
recinfo.global_attribute9 := rtrim(recinfo.global_attribute9);
recinfo.global_attribute10 := rtrim(recinfo.global_attribute10);
recinfo.global_attribute11 := rtrim(recinfo.global_attribute11);
recinfo.global_attribute12 := rtrim(recinfo.global_attribute12);
recinfo.global_attribute13 := rtrim(recinfo.global_attribute13);
recinfo.global_attribute14 := rtrim(recinfo.global_attribute14);
recinfo.global_attribute15 := rtrim(recinfo.global_attribute15);
recinfo.global_attribute16 := rtrim(recinfo.global_attribute16);
recinfo.global_attribute17 := rtrim(recinfo.global_attribute17);
recinfo.global_attribute18 := rtrim(recinfo.global_attribute18);
recinfo.global_attribute19 := rtrim(recinfo.global_attribute19);
recinfo.global_attribute20 := rtrim(recinfo.global_attribute20);
recinfo.loc_information17 := rtrim(recinfo.loc_information17);                  recinfo.loc_information18 := rtrim(recinfo.loc_information18);                  recinfo.loc_information19 := rtrim(recinfo.loc_information19);
recinfo.loc_information20 := rtrim(recinfo.loc_information20);
if (
          (   (Recinfo.location_id = X_Location_Id)
           OR (    (Recinfo.location_id IS NULL)
               AND (X_Location_Id IS NULL)))
      AND (   (Recinfo.entered_by = X_Entered_By)
           OR (    (Recinfo.entered_by IS NULL)
               AND (X_Entered_By IS NULL)))
      AND (   (Recinfo.location_code = X_Location_Code)
           OR (    (Recinfo.location_code IS NULL)
               AND (X_Location_Code IS NULL)))
      AND (   (Recinfo.address_line_1 = X_Address_Line_1)
           OR (    (Recinfo.address_line_1 IS NULL)
               AND (X_Address_Line_1 IS NULL)))
      AND (   (Recinfo.address_line_2 = X_Address_Line_2)
           OR (    (Recinfo.address_line_2 IS NULL)
               AND (X_Address_Line_2 IS NULL)))
      AND (   (Recinfo.address_line_3 = X_Address_Line_3)
           OR (    (Recinfo.address_line_3 IS NULL)
               AND (X_Address_Line_3 IS NULL)))
      AND (   (Recinfo.bill_to_site_flag = X_Bill_To_Site_Flag)
           OR (    (Recinfo.bill_to_site_flag IS NULL)
               AND (X_Bill_To_Site_Flag IS NULL)))
      AND (   (Recinfo.country = X_Country)
           OR (    (Recinfo.country IS NULL)
               AND (X_Country IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.designated_receiver_id = X_Designated_Receiver_Id)
           OR (    (Recinfo.designated_receiver_id IS NULL)
               AND (X_Designated_Receiver_Id IS NULL)))
      AND (   (Recinfo.in_organization_flag = X_In_Organization_Flag)
           OR (    (Recinfo.in_organization_flag IS NULL)
               AND (X_In_Organization_Flag IS NULL)))
      AND (   (Recinfo.inactive_date = X_Inactive_Date)
           OR (    (Recinfo.inactive_date IS NULL)
               AND (X_Inactive_Date IS NULL)))
      AND (   (Recinfo.inventory_organization_id = X_Inventory_Organization_Id)
           OR (    (Recinfo.inventory_organization_id IS NULL)
               AND (X_Inventory_Organization_Id IS NULL)))
      AND (   (Recinfo.office_site_flag = X_Office_Site_Flag)
           OR (    (Recinfo.office_site_flag IS NULL)
               AND (X_Office_Site_Flag IS NULL)))
      AND (   (Recinfo.postal_code = X_Postal_Code)
           OR (    (Recinfo.postal_code IS NULL)
               AND (X_Postal_Code IS NULL)))
      AND (   (Recinfo.receiving_site_flag = X_Receiving_Site_Flag)
           OR (    (Recinfo.receiving_site_flag IS NULL)
               AND (X_Receiving_Site_Flag IS NULL)))
      AND (   (Recinfo.region_1 = X_Region_1)
           OR (    (Recinfo.region_1 IS NULL)
               AND (X_Region_1 IS NULL)))
      AND (   (Recinfo.region_2 = X_Region_2)
           OR (    (Recinfo.region_2 IS NULL)
               AND (X_Region_2 IS NULL)))
      AND (   (Recinfo.region_3 = X_Region_3)
           OR (    (Recinfo.region_3 IS NULL)
               AND (X_Region_3 IS NULL)))
      AND (   (Recinfo.ship_to_location_id = X_Ship_To_Location_Id)
           OR (    (Recinfo.ship_to_location_id IS NULL)
               AND (X_Ship_To_Location_Id IS NULL)))
      AND (   (Recinfo.ship_to_site_flag = X_Ship_To_Site_Flag)
           OR (    (Recinfo.ship_to_site_flag IS NULL)
               AND (X_Ship_To_Site_Flag IS NULL)))
      AND (   (Recinfo.style = X_Style)
           OR (    (Recinfo.style IS NULL)
               AND (X_Style IS NULL)))
      AND (   (Recinfo.tax_name = X_Tax_Name)
           OR (    (Recinfo.tax_name IS NULL)
               AND (X_Tax_Name IS NULL)))
     AND (   (Recinfo.ece_tp_location_code = X_Ece_Tp_Location_Code)
		OR (    (Recinfo.ece_tp_location_code IS NULL)
			       AND (X_Ece_Tp_Location_Code IS NULL)))
      AND (   (Recinfo.telephone_number_1 = X_Telephone_Number_1)
           OR (    (Recinfo.telephone_number_1 IS NULL)
               AND (X_Telephone_Number_1 IS NULL)))
      AND (   (Recinfo.telephone_number_2 = X_Telephone_Number_2)
           OR (    (Recinfo.telephone_number_2 IS NULL)
               AND (X_Telephone_Number_2 IS NULL)))
      AND (   (Recinfo.telephone_number_3 = X_Telephone_Number_3)
           OR (    (Recinfo.telephone_number_3 IS NULL)
               AND (X_Telephone_Number_3 IS NULL)))
      AND (   (Recinfo.town_or_city = X_Town_Or_City)
           OR (    (Recinfo.town_or_city IS NULL)
               AND (X_Town_Or_City IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.attribute16 = X_Attribute16)
           OR (    (Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (Recinfo.attribute17 = X_Attribute17)
           OR (    (Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (Recinfo.attribute18 = X_Attribute18)
           OR (    (Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (Recinfo.attribute19 = X_Attribute19)
           OR (    (Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
      AND (   (Recinfo.global_attribute_category = X_Global_Attribute_Category)
           OR (    (Recinfo.global_attribute_category IS NULL)
       	       AND (X_Global_Attribute_Category IS NULL)))

      AND (   (Recinfo.global_attribute1 = X_Global_Attribute1)
           OR (    (Recinfo.global_attribute1 IS NULL)
	       AND (X_Global_Attribute1 IS NULL)))

      AND (   (Recinfo.global_attribute2 = X_Global_Attribute2)
	  OR (    (Recinfo.global_attribute2 IS NULL)
              AND (X_Global_Attribute2 IS NULL)))

      AND (   (Recinfo.global_attribute3 = X_Global_Attribute3)
	   OR (    (Recinfo.global_attribute3 IS NULL)
       	       AND (X_Global_Attribute3 IS NULL)))

      AND (   (Recinfo.global_attribute4 = X_Global_Attribute4)
	  OR (    (Recinfo.global_attribute4 IS NULL)
              AND (X_GLobal_Attribute4 IS NULL)))

      AND (   (Recinfo.global_attribute5 = X_Global_Attribute5)
	  OR (    (Recinfo.global_attribute5 IS NULL)
              AND (X_Global_Attribute5 IS NULL)))

      AND (   (Recinfo.global_attribute6 = X_Global_Attribute6)
	  OR (    (Recinfo.global_attribute6 IS NULL)
	      AND (X_Global_Attribute6 IS NULL)))

      AND (   (Recinfo.global_attribute7 = X_Global_Attribute7)
	  OR (    (Recinfo.global_attribute7 IS NULL)
	      AND (X_Global_Attribute7 IS NULL)))

      AND (   (Recinfo.global_attribute8 = X_Global_Attribute8)
	  OR (    (Recinfo.global_attribute8 IS NULL)
	      AND (X_Global_Attribute8 IS NULL)))

      AND (   (Recinfo.global_attribute9 = X_Global_Attribute9)
	  OR (    (Recinfo.global_attribute9 IS NULL)
	      AND (X_Global_Attribute9 IS NULL)))

      AND (   (Recinfo.global_attribute10 = X_Global_Attribute10)
	  OR (    (Recinfo.global_attribute10 IS NULL)
	      AND (X_Global_Attribute10 IS NULL)))

      AND (   (Recinfo.global_attribute11 = X_Global_Attribute11)
	   OR (    (Recinfo.global_attribute11 IS NULL)
               AND (X_Global_Attribute11 IS NULL)))

      AND (   (Recinfo.global_attribute12 = X_Global_Attribute12)
	  OR (    (Recinfo.global_attribute12 IS NULL)
	      AND (X_Global_Attribute12 IS NULL)))

      AND (   (Recinfo.global_attribute13 = X_Global_Attribute13)
	 OR (    (Recinfo.global_attribute13 IS NULL)
             AND (X_Global_Attribute13 IS NULL)))

      AND (   (Recinfo.global_attribute14 = X_Global_Attribute14)
         OR (    (Recinfo.global_attribute14 IS NULL)
             AND (X_Global_Attribute14 IS NULL)))

      AND (   (Recinfo.global_attribute15 = X_Global_Attribute15)
         OR (    (Recinfo.global_attribute15 IS NULL)
             AND (X_Global_Attribute15 IS NULL)))

      AND (   (Recinfo.global_attribute16 = X_Global_Attribute16)
         OR (    (Recinfo.global_attribute16 IS NULL)
             AND (X_Global_Attribute16 IS NULL)))

      AND (   (Recinfo.global_attribute17 = X_Global_Attribute17)
	 OR (    (Recinfo.global_attribute17 IS NULL)
             AND (X_Global_Attribute17 IS NULL)))

      AND (   (Recinfo.global_attribute18 = X_Global_Attribute18)
	 OR (    (Recinfo.global_attribute18 IS NULL)
        	AND (X_Global_Attribute18 IS NULL)))

      AND (   (Recinfo.global_attribute19 = X_Global_Attribute19)
         OR (    (Recinfo.global_attribute19 IS NULL)
             AND (X_Global_Attribute19 IS NULL)))

             AND (   (Recinfo.global_attribute20 = X_Global_Attribute20)
	 OR (    (Recinfo.global_attribute20 IS NULL)
             AND (X_Global_Attribute20 IS NULL)))


             AND (   (Recinfo.loc_information17 = X_Loc_Information17)
	 OR (    (Recinfo.loc_information17 IS NULL)
             AND (X_Loc_information17 IS NULL)))

             AND (   (Recinfo.loc_information18 = X_Loc_Information18)
	 OR (    (Recinfo.loc_information18 IS NULL)
             AND (X_Loc_information18 IS NULL)))

             AND (   (Recinfo.loc_information19 = X_Loc_Information19)
	 OR (    (Recinfo.loc_information19 IS NULL)
             AND (X_Loc_information19 IS NULL)))

             AND (   (Recinfo.loc_information20 = X_Loc_Information20)
	 OR (    (Recinfo.loc_information20 IS NULL)
             AND (X_Loc_information20 IS NULL)))

	 ) then

    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Location_Id                         NUMBER,
                     X_Entered_By                          NUMBER,
                     X_Location_Code                       VARCHAR2,
                     X_Address_Line_1                      VARCHAR2,
                     X_Address_Line_2                      VARCHAR2,
                     X_Address_Line_3                      VARCHAR2,
                     X_Bill_To_Site_Flag                   VARCHAR2,
                     X_Country                             VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Designated_Receiver_Id              NUMBER,
                     X_In_Organization_Flag                VARCHAR2,
                     X_Inactive_Date                       DATE,
                     X_Inventory_Organization_Id           NUMBER,
                     X_Office_Site_Flag                    VARCHAR2,
                     X_Postal_Code                         VARCHAR2,
                     X_Receiving_Site_Flag                 VARCHAR2,
                     X_Region_1                            VARCHAR2,
                     X_Region_2                            VARCHAR2,
                     X_Region_3                            VARCHAR2,
                     X_Ship_To_Location_Id              IN OUT NOCOPY NUMBER,
                     X_Ship_To_Site_Flag                   VARCHAR2,
                     X_Style                               VARCHAR2,
                     X_Tax_Name                            VARCHAR2,
		     X_Ece_Tp_Location_Code                   VARCHAR2,
                     X_Telephone_Number_1                  VARCHAR2,
                     X_Telephone_Number_2                  VARCHAR2,
                     X_Telephone_Number_3                  VARCHAR2,
                     X_Town_Or_City                        VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER  ,
                     X_C_Purchasing_Ins                     VARCHAR2,
                     X_C_Inventory_Ins                      VARCHAR2,
		     X_Ship_To_Location			   VARCHAR2,
		     X_Global_Attribute_Category            VARCHAR2,
		     X_Global_Attribute1                    VARCHAR2,
		     X_Global_Attribute2                    VARCHAR2,
		     X_Global_Attribute3                    VARCHAR2,
		     X_Global_Attribute4                    VARCHAR2,
		     X_Global_Attribute5                    VARCHAR2,
		     X_Global_Attribute6                    VARCHAR2,
		     X_Global_Attribute7                    VARCHAR2,
		     X_Global_Attribute8                    VARCHAR2,
		     X_Global_Attribute9                    VARCHAR2,
		     X_Global_Attribute10                   VARCHAR2,
		     X_Global_Attribute11                   VARCHAR2,
		     X_Global_Attribute12                   VARCHAR2,
		     X_Global_Attribute13                   VARCHAR2,
                     X_Global_Attribute14                   VARCHAR2,
		     X_Global_Attribute15                   VARCHAR2,
		     X_Global_Attribute16                   VARCHAR2,
		     X_Global_Attribute17                   VARCHAR2,
		     X_Global_Attribute18                   VARCHAR2,
		     X_Global_Attribute19                   VARCHAR2,
		     X_Global_Attribute20                   VARCHAR2,
                     X_Loc_Information17                    VARCHAR2,
                     X_Loc_Information18                    VARCHAR2,
                     X_Loc_Information19                    VARCHAR2,
                     X_Loc_Information20                    VARCHAR2
) IS
BEGIN
  set_ship_to_location(X_C_Purchasing_Ins,
                   X_C_Inventory_Ins,
                   X_Ship_To_Location,
                   X_Location_Id,
                   X_Ship_To_Location_Id,
		   X_Location_Code);
--
  UPDATE hr_locations
  SET
    location_id                               =    X_Location_Id,
    entered_by                                =    X_Entered_By,
    location_code                             =    X_Location_Code,
    address_line_1                            =    X_Address_Line_1,
    address_line_2                            =    X_Address_Line_2,
    address_line_3                            =    X_Address_Line_3,
    bill_to_site_flag                         =    X_Bill_To_Site_Flag,
    country                                   =    X_Country,
    description                               =    X_Description,
    designated_receiver_id                    =    X_Designated_Receiver_Id,
    in_organization_flag                      =    X_In_Organization_Flag,
    inactive_date                             =    X_Inactive_Date,
    inventory_organization_id                 =    X_Inventory_Organization_Id,
    office_site_flag                          =    X_Office_Site_Flag,
    postal_code                               =    X_Postal_Code,
    receiving_site_flag                       =    X_Receiving_Site_Flag,
    region_1                                  =    X_Region_1,
    region_2                                  =    X_Region_2,
    region_3                                  =    X_Region_3,
    ship_to_location_id                       =    X_Ship_To_Location_Id,
    ship_to_site_flag                         =    X_Ship_To_Site_Flag,
    style                                     =    X_Style,
    tax_name                                  =    X_Tax_Name,
    ece_tp_location_code                      =    X_Ece_Tp_Location_Code,
    telephone_number_1                        =    X_Telephone_Number_1,
    telephone_number_2                        =    X_Telephone_Number_2,
    telephone_number_3                        =    X_Telephone_Number_3,
    town_or_city                              =    X_Town_Or_City,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    global_attribute_category                 =    X_Global_Attribute_Category,
    global_attribute1                         =    X_Global_Attribute1,
    global_attribute2                         =    X_Global_Attribute2,
    global_attribute3                         =    X_Global_Attribute3,
    global_attribute4                         =    X_Global_Attribute4,
    global_attribute5                         =    X_Global_Attribute5,
    global_attribute6                         =    X_Global_Attribute6,
    global_attribute7                         =    X_Global_Attribute7,
    global_attribute8                         =    X_Global_Attribute8,
    global_attribute9                         =    X_Global_Attribute9,
    global_attribute10                        =    X_Global_Attribute10,
    global_attribute11                        =    X_Global_Attribute11,
    global_attribute12                        =    X_Global_Attribute12,
    global_attribute13                        =    X_Global_Attribute13,
    global_attribute14                        =    X_Global_Attribute14,
    global_attribute15                        =    X_Global_Attribute15,
    global_attribute16                        =    X_Global_Attribute16,
    global_attribute17                        =    X_Global_Attribute17,
    global_attribute18                        =    X_Global_Attribute18,
    global_attribute19                        =    X_Global_Attribute19,
    global_attribute20                        =    X_Global_Attribute20,
    loc_information17                         =    X_Loc_Information17,
    loc_information18                         =    X_Loc_Information18,
    loc_information19                         =    X_Loc_Information19,
    loc_information20                         =    X_Loc_Information20
  WHERE rowid = chartorowid(X_rowid);
--
  if (SQL%NOTFOUND) then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                      'hr_locations_pkg.update_row');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
  end if;
--
END Update_Row;
--
END HR_LOCATIONS_PKG;

/
