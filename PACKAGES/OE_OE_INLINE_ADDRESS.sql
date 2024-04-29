--------------------------------------------------------
--  DDL for Package OE_OE_INLINE_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_INLINE_ADDRESS" AUTHID CURRENT_USER AS
/* $Header: OEXFINLS.pls 120.0.12010000.2 2008/12/31 06:22:15 smanian ship $ */

FUNCTION find_lookup_meaning(in_lookup_type in varchar2,
                             in_lookup_code in varchar2
                            ) return varchar2;
PROCEDURE Create_contact
                 ( p_contact_last_name  in varchar2,
                   p_contact_first_name in varchar2,
                   p_contact_title      in varchar2,
                   p_email              in varchar2,
                   p_area_code          in varchar2,
                   p_phone_number       in varchar2,
                   p_extension          in varchar2,
                   p_acct_id            in number,
                   p_party_id           in number,
                   p_created_by_module IN VARCHAR2 DEFAULT NULL,
		   p_orig_system IN VARCHAR2 DEFAULT NULL, --ER7675548
		   p_orig_system_reference IN VARCHAR2 DEFAULT NULL, --ER7675548
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

x_contact_id out nocopy number,

x_contact_name out nocopy varchar2,

                  c_Attribute_Category   IN VARCHAR2,
                  c_Attribute1           IN VARCHAR2,
                  c_Attribute2           IN VARCHAR2,
                  c_Attribute3           IN VARCHAR2,
                  c_Attribute4           IN VARCHAR2,
                  c_Attribute5           IN VARCHAR2,
                  c_Attribute6           IN VARCHAR2,
                  c_Attribute7           IN VARCHAR2,
                  c_Attribute8           IN VARCHAR2,
                  c_Attribute9           IN VARCHAR2,
                  c_Attribute10          IN VARCHAR2,
                  c_Attribute11          IN VARCHAR2,
                  c_Attribute12          IN VARCHAR2,
                  c_Attribute13          IN VARCHAR2,
                  c_Attribute14          IN VARCHAR2,
                  c_Attribute15          IN VARCHAR2,
                  c_Attribute16          IN VARCHAR2,
                  c_Attribute17          IN VARCHAR2,
                  c_Attribute18          IN VARCHAR2,
                  c_Attribute19          IN VARCHAR2,
                  c_Attribute20          IN VARCHAR2,
                  c_Attribute21          IN VARCHAR2,
                  c_Attribute22          IN VARCHAR2,
                  c_Attribute23          IN VARCHAR2,
                  c_Attribute24          IN VARCHAR2,
                  c_Attribute25          IN VARCHAR2,
                  c2_Attribute_Category   IN VARCHAR2,
                  c2_Attribute1           IN VARCHAR2,
                  c2_Attribute2           IN VARCHAR2,
                  c2_Attribute3           IN VARCHAR2,
                  c2_Attribute4           IN VARCHAR2,
                  c2_Attribute5           IN VARCHAR2,
                  c2_Attribute6           IN VARCHAR2,
                  c2_Attribute7           IN VARCHAR2,
                  c2_Attribute8           IN VARCHAR2,
                  c2_Attribute9           IN VARCHAR2,
                  c2_Attribute10          IN VARCHAR2,
                  c2_Attribute11          IN VARCHAR2,
                  c2_Attribute12          IN VARCHAR2,
                  c2_Attribute13          IN VARCHAR2,
                  c2_Attribute14          IN VARCHAR2,
                  c2_Attribute15          IN VARCHAR2,
                  c2_Attribute16          IN VARCHAR2,
                  c2_Attribute17          IN VARCHAR2,
                  c2_Attribute18          IN VARCHAR2,
                  c2_Attribute19          IN VARCHAR2,
                  c2_Attribute20          IN VARCHAR2,
                  in_phone_country_Code  in varchar2 default null
                  );


PROCEDURE Create_acct_contact
                    (
                      p_acct_id            in number,
                      p_contact_party_id   in number,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

x_contact_id out nocopy number,

                  c_Attribute_Category   IN VARCHAR2,
                  c_Attribute1           IN VARCHAR2,
                  c_Attribute2           IN VARCHAR2,
                  c_Attribute3           IN VARCHAR2,
                  c_Attribute4           IN VARCHAR2,
                  c_Attribute5           IN VARCHAR2,
                  c_Attribute6           IN VARCHAR2,
                  c_Attribute7           IN VARCHAR2,
                  c_Attribute8           IN VARCHAR2,
                  c_Attribute9           IN VARCHAR2,
                  c_Attribute10          IN VARCHAR2,
                  c_Attribute11          IN VARCHAR2,
                  c_Attribute12          IN VARCHAR2,
                  c_Attribute13          IN VARCHAR2,
                  c_Attribute14          IN VARCHAR2,
                  c_Attribute15          IN VARCHAR2,
                  c_Attribute16          IN VARCHAR2,
                  c_Attribute17          IN VARCHAR2,
                  c_Attribute18          IN VARCHAR2,
                  c_Attribute19          IN VARCHAR2,
                  c_Attribute20          IN VARCHAR2,
                  c_Attribute21          IN VARCHAR2,
                  c_Attribute22          IN VARCHAR2,
                  c_Attribute23          IN VARCHAR2,
                  c_Attribute24          IN VARCHAR2,
                  c_Attribute25          IN VARCHAR2,
                  c2_Attribute_Category   IN VARCHAR2,
                  c2_Attribute1           IN VARCHAR2,
                  c2_Attribute2           IN VARCHAR2,
                  c2_Attribute3           IN VARCHAR2,
                  c2_Attribute4           IN VARCHAR2,
                  c2_Attribute5           IN VARCHAR2,
                  c2_Attribute6           IN VARCHAR2,
                  c2_Attribute7           IN VARCHAR2,
                  c2_Attribute8           IN VARCHAR2,
                  c2_Attribute9           IN VARCHAR2,
                  c2_Attribute10          IN VARCHAR2,
                  c2_Attribute11          IN VARCHAR2,
                  c2_Attribute12          IN VARCHAR2,
                  c2_Attribute13          IN VARCHAR2,
                  c2_Attribute14          IN VARCHAR2,
                  c2_Attribute15          IN VARCHAR2,
                  c2_Attribute16          IN VARCHAR2,
                  c2_Attribute17          IN VARCHAR2,
                  c2_Attribute18          IN VARCHAR2,
                  c2_Attribute19          IN VARCHAR2,
                  c2_Attribute20          IN VARCHAR2,
                  in_created_by_module in varchar2 default null
                  );

PROCEDURE create_contact_point(
                       in_contact_point_type in varchar2,
                       in_owner_table_id in number,
                       in_email in varchar2,
                       in_phone_area_code in varchar2,
                       in_phone_number    in varchar2,
                       in_phone_extension in varchar2,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

                  c_Attribute_Category   IN VARCHAR2 default null,
                  c_Attribute1           IN VARCHAR2 default null,
                  c_Attribute2           IN VARCHAR2 default null,
                  c_Attribute3           IN VARCHAR2 default null,
                  c_Attribute4           IN VARCHAR2 default null,
                  c_Attribute5           IN VARCHAR2 default null,
                  c_Attribute6           IN VARCHAR2 default null,
                  c_Attribute7           IN VARCHAR2 default null,
                  c_Attribute8           IN VARCHAR2 default null,
                  c_Attribute9           IN VARCHAR2 default null,
                  c_Attribute10          IN VARCHAR2 default null,
                  c_Attribute11          IN VARCHAR2 default null,
                  c_Attribute12          IN VARCHAR2 default null,
                  c_Attribute13          IN VARCHAR2 default null,
                  c_Attribute14          IN VARCHAR2 default null,
                  c_Attribute15          IN VARCHAR2 default null,
                  c_Attribute16          IN VARCHAR2 default null,
                  c_Attribute17          IN VARCHAR2 default null,
                  c_Attribute18          IN VARCHAR2 default null,
                  c_Attribute19          IN VARCHAR2 default null,
                  c_Attribute20          IN VARCHAR2 default null,
                  in_phone_country_Code  in varchar2 default null,
		  p_created_by_module IN VARCHAR2 DEFAULT NULL,
		  p_orig_system IN VARCHAR2 DEFAULT NULL, --ER7675548
		  p_orig_system_reference IN VARCHAR2 DEFAULT NULL --ER7675548
                       );



PROCEDURE Create_Location
			   (
		   p_country  IN Varchar2,
		   p_address1 IN Varchar2,
		   p_address2 IN Varchar2,
		   p_address3 IN Varchar2,
		   p_address4 IN Varchar2,
                   p_city     IN Varchar2,
		   p_postal_code  IN Varchar2,
		   p_state    IN Varchar2,
		   p_province IN varchar2,
		   p_county   IN Varchar2,
		   p_address_style IN Varchar2,
		   p_address_line_phonetic IN Varchar2,
		   p_created_by_module IN VARCHAR2 DEFAULT NULL,
		   p_orig_system IN VARCHAR2 DEFAULT NULL, --ER7675548
		  p_orig_system_reference IN VARCHAR2 DEFAULT NULL, --ER7675548
                  c_Attribute_Category   IN VARCHAR2,
                  c_Attribute1           IN VARCHAR2,
                  c_Attribute2           IN VARCHAR2,
                  c_Attribute3           IN VARCHAR2,
                  c_Attribute4           IN VARCHAR2,
                  c_Attribute5           IN VARCHAR2,
                  c_Attribute6           IN VARCHAR2,
                  c_Attribute7           IN VARCHAR2,
                  c_Attribute8           IN VARCHAR2,
                  c_Attribute9           IN VARCHAR2,
                  c_Attribute10          IN VARCHAR2,
                  c_Attribute11          IN VARCHAR2,
                  c_Attribute12          IN VARCHAR2,
                  c_Attribute13          IN VARCHAR2,
                  c_Attribute14          IN VARCHAR2,
                  c_Attribute15          IN VARCHAR2,
                  c_Attribute16          IN VARCHAR2,
                  c_Attribute17          IN VARCHAR2,
                  c_Attribute18          IN VARCHAR2,
                  c_Attribute19          IN VARCHAR2,
                  c_Attribute20          IN VARCHAR2,
                  c_global_Attribute_Category   IN VARCHAR2,
                  c_global_Attribute1           IN VARCHAR2,
                  c_global_Attribute2           IN VARCHAR2,
                  c_global_Attribute3           IN VARCHAR2,
                  c_global_Attribute4           IN VARCHAR2,
                  c_global_Attribute5           IN VARCHAR2,
                  c_global_Attribute6           IN VARCHAR2,
                  c_global_Attribute7           IN VARCHAR2,
                  c_global_Attribute8           IN VARCHAR2,
                  c_global_Attribute9           IN VARCHAR2,
                  c_global_Attribute10          IN VARCHAR2,
                  c_global_Attribute11          IN VARCHAR2,
                  c_global_Attribute12          IN VARCHAR2,
                  c_global_Attribute13          IN VARCHAR2,
                  c_global_Attribute14          IN VARCHAR2,
                  c_global_Attribute15          IN VARCHAR2,
                  c_global_Attribute16          IN VARCHAR2,
                  c_global_Attribute17          IN VARCHAR2,
                  c_global_Attribute18          IN VARCHAR2,
                  c_global_Attribute19          IN VARCHAR2,
                  c_global_Attribute20          IN VARCHAR2,
x_location_id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2


			   );

PROCEDURE Create_Party_Site
			   (
		   p_party_id IN Number,
		   p_location_id IN Number,
		   p_party_site_number IN VARCHAR2,
  p_created_by_module IN VARCHAR2 DEFAULT NULL,
  p_orig_system IN VARCHAR2 DEFAULT NULL, --ER7675548
  p_orig_system_reference IN VARCHAR2 DEFAULT NULL, --ER7675548
x_party_site_id OUT NOCOPY NUMBER,

x_party_site_number OUT NOCOPY VARCHAR2,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

			   );

PROCEDURE Create_Account_Site
			   (
		   p_cust_account_id  IN NUMBER,
		   p_party_site_id    IN NUMBER,
		   p_orig_system IN VARCHAR2 DEFAULT NULL, --ER7675548
                   p_orig_system_reference IN VARCHAR2 DEFAULT NULL, --ER7675548
                  c_Attribute_Category   IN VARCHAR2,
                  c_Attribute1           IN VARCHAR2,
                  c_Attribute2           IN VARCHAR2,
                  c_Attribute3           IN VARCHAR2,
                  c_Attribute4           IN VARCHAR2,
                  c_Attribute5           IN VARCHAR2,
                  c_Attribute6           IN VARCHAR2,
                  c_Attribute7           IN VARCHAR2,
                  c_Attribute8           IN VARCHAR2,
                  c_Attribute9           IN VARCHAR2,
                  c_Attribute10          IN VARCHAR2,
                  c_Attribute11          IN VARCHAR2,
                  c_Attribute12          IN VARCHAR2,
                  c_Attribute13          IN VARCHAR2,
                  c_Attribute14          IN VARCHAR2,
                  c_Attribute15          IN VARCHAR2,
                  c_Attribute16          IN VARCHAR2,
                  c_Attribute17          IN VARCHAR2,
                  c_Attribute18          IN VARCHAR2,
                  c_Attribute19          IN VARCHAR2,
                  c_Attribute20          IN VARCHAR2,
x_customer_site_id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

                  in_created_by_module in varchar2 default null
			   );


PROCEDURE Create_Acct_Site_Uses
			   (
			   p_cust_acct_site_id  IN NUMBER,
			   p_location           IN Varchar2,
			   p_site_use_code      IN Varchar2,
x_site_use_id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

                  c_Attribute_Category   IN VARCHAR2,
                  c_Attribute1           IN VARCHAR2,
                  c_Attribute2           IN VARCHAR2,
                  c_Attribute3           IN VARCHAR2,
                  c_Attribute4           IN VARCHAR2,
                  c_Attribute5           IN VARCHAR2,
                  c_Attribute6           IN VARCHAR2,
                  c_Attribute7           IN VARCHAR2,
                  c_Attribute8           IN VARCHAR2,
                  c_Attribute9           IN VARCHAR2,
                  c_Attribute10          IN VARCHAR2,
                  c_Attribute11          IN VARCHAR2,
                  c_Attribute12          IN VARCHAR2,
                  c_Attribute13          IN VARCHAR2,
                  c_Attribute14          IN VARCHAR2,
                  c_Attribute15          IN VARCHAR2,
                  c_Attribute16          IN VARCHAR2,
                  c_Attribute17          IN VARCHAR2,
                  c_Attribute18          IN VARCHAR2,
                  c_Attribute19          IN VARCHAR2,
                  c_Attribute20          IN VARCHAR2,
                  c_Attribute21          IN VARCHAR2,
                  c_Attribute22          IN VARCHAR2,
                  c_Attribute23          IN VARCHAR2,
                  c_Attribute24          IN VARCHAR2,
                  c_Attribute25          IN VARCHAR2,
                  in_created_by_module in varchar2 default null,
                  in_primary_flag in varchar2 default null
			   );

PROCEDURE Create_Account
                          (
                           p_party_number         IN Varchar2,
                           p_organization_name    IN Varchar2,
                           p_alternate_name       IN Varchar2,
                           p_tax_reference        IN Varchar2,
                           p_taxpayer_id          IN Varchar2,
                           p_party_id             IN Number,
                           p_first_name           IN Varchar2,
                           p_last_name            IN Varchar2,
                           p_middle_name          IN Varchar2,
                           p_name_suffix          IN Varchar2,
                           p_title                IN Varchar2,
                           p_party_type           IN Varchar2,
                           p_email                IN Varchar2,
                           c_Attribute_Category   IN VARCHAR2,
                           c_Attribute1           IN VARCHAR2,
                           c_Attribute2           IN VARCHAR2,
                           c_Attribute3           IN VARCHAR2,
                           c_Attribute4           IN VARCHAR2,
                           c_Attribute5           IN VARCHAR2,
                           c_Attribute6           IN VARCHAR2,
                           c_Attribute7           IN VARCHAR2,
                           c_Attribute8           IN VARCHAR2,
                           c_Attribute9           IN VARCHAR2,
                           c_Attribute10          IN VARCHAR2,
                           c_Attribute11          IN VARCHAR2,
                           c_Attribute12          IN VARCHAR2,
                           c_Attribute13          IN VARCHAR2,
                           c_Attribute14          IN VARCHAR2,
                           c_Attribute15          IN VARCHAR2,
                           c_Attribute16          IN VARCHAR2,
                           c_Attribute17          IN VARCHAR2,
                           c_Attribute18          IN VARCHAR2,
                           c_Attribute19          IN VARCHAR2,
                           c_Attribute20          IN VARCHAR2,
                           c_global_Attribute_Category   IN VARCHAR2,
                           c_global_Attribute1           IN VARCHAR2,
                           c_global_Attribute2           IN VARCHAR2,
                           c_global_Attribute3           IN VARCHAR2,
                           c_global_Attribute4           IN VARCHAR2,
                           c_global_Attribute5           IN VARCHAR2,
                           c_global_Attribute6           IN VARCHAR2,
                           c_global_Attribute7           IN VARCHAR2,
                           c_global_Attribute8           IN VARCHAR2,
                           c_global_Attribute9           IN VARCHAR2,
                           c_global_Attribute10          IN VARCHAR2,
                           c_global_Attribute11          IN VARCHAR2,
                           c_global_Attribute12          IN VARCHAR2,
                           c_global_Attribute13          IN VARCHAR2,
                           c_global_Attribute14          IN VARCHAR2,
                           c_global_Attribute15          IN VARCHAR2,
                           c_global_Attribute16          IN VARCHAR2,
                           c_global_Attribute17          IN VARCHAR2,
                           c_global_Attribute18          IN VARCHAR2,
                           c_global_Attribute19          IN VARCHAR2,
                           c_global_Attribute20          IN VARCHAR2,
x_party_id OUT NOCOPY Number,

x_party_number OUT NOCOPY Varchar2,

x_cust_Account_id OUT NOCOPY NUMBER,

x_cust_account_number  IN OUT NOCOPY /* file.sql.39 change */ varchar2,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

                           in_created_by_module in varchar2 default null,
			   p_orig_system IN VARCHAR2 DEFAULT NULL,          --ER7675548
			   p_orig_system_reference IN VARCHAR2 DEFAULT NULL,--ER7675548
			   p_account_description   IN VARCHAR2 DEFAULT NULL --ER7675548
                           );


PROCEDURE Create_Party_relationship(
                           p_object_party_id       IN Number,
                           p_subject_party_id      IN Number,
			  p_reciprocal_flag       IN Varchar2,
x_party_relationship_id OUT NOCOPY Number,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

					  );

PROCEDURE Create_Cust_relationship(
                           p_cust_acct_id          IN Number,
                           p_related_cust_acct_id  IN Number,
			  p_reciprocal_flag       IN Varchar2,
p_created_by_module IN VARCHAR2 DEFAULT NULL,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

					  );

PROCEDURE Commit_Changes;

PROCEDURE Rollback_Changes;

PROCEDURE Create_Person
                  (
                  p_first_name   IN NUMBER,
                  p_party_number IN OUT NOCOPY /* file.sql.39 change */ Varchar2,
x_party_id OUT NOCOPY NUMBER,

x_profile_id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

                  );

PROCEDURE Create_Organization
                  (
                  p_organization_name   IN NUMBER,
                  p_party_number IN OUT NOCOPY /* file.sql.39 change */ Varchar2,
x_party_id OUT NOCOPY NUMBER,

x_profile_id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

                  );


PROCEDURE Create_role_resp
                  (
                  p_cust_acct_role_id   IN NUMBER,
                  p_usage_type       IN VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

x_responsibility_id OUT NOCOPY NUMBER

                  );


PROCEDURE add_customer_startup(
                 out_auto_site_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_auto_location_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_auto_cust_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_email_required out NOCOPY /* file.sql.39 change */ varchar2,
                 out_auto_party_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_default_country_code out NOCOPY /* file.sql.39 change */ varchar2,
                 out_default_country out NOCOPY /* file.sql.39 change */ varchar2,
                 out_address_style out NOCOPY /* file.sql.39 change */ varchar2
                               );



PROCEDURE Add_Customer(
                        in_cust_account_id in number,
                        in_cust_type in varchar2,
                        in_party_number in varchar2,
                        in_cust_name in varchar2,
                        in_cust_first_name in varchar2,
                        in_cust_middle_name in varchar2,
                        in_cust_last_name in varchar2,
                        in_cust_title in varchar2,
                        in_Cust_Number in varchar2,
                        in_cust_email  in varchar2,
                        in_cust_country_code in varchar2,
                        in_cust_phone_number in varchar2,
                        in_cust_phone_ext in varchar2,
                        in_addr_location in varchar2,
                        in_addr_country_Code in varchar2,
                        in_addr_line1 in varchar2,
                        in_addr_line2 in varchar2,
                        in_addr_line3 in varchar2,
                        in_addr_city in varchar2,
                        in_addr_state in varchar2,
                        in_addr_zip in varchar2,
                        in_ship_usage in varchar2,
                        in_bill_usage in varchar2,
                        in_deliver_usage in varchar2,
                        in_sold_usage in varchar2,
                        in_cont_first_name in varchar2,
                        in_cont_last_name in varchar2,
                        in_cont_title in varchar2,
                        in_cont_email in varchar2,
                        in_cont_country_Code in varchar2,
                        in_cont_phone_number in varchar2,
                        in_cont_phone_ext in varchar2,
                        out_cust_name out nocopy varchar2,
                        out_cust_number out nocopy varchar2,
                        out_cust_id out nocopy number,
                        out_party_number out nocopy varchar2,
                        out_ship_to_site_use_id out NOCOPY /* file.sql.39 change */ varchar2,
                        out_bill_to_site_use_id out NOCOPY /* file.sql.39 change */ varchar2,
                        out_deliver_to_site_use_id out NOCOPY /* file.sql.39 change */ varchar2,
                        out_sold_to_site_use_id out NOCOPY /* file.sql.39 change */ varchar2,
                        out_ship_to_location out nocopy varchar2,
                        out_bill_to_location out nocopy varchar2,
                        out_deliver_to_location out nocopy varchar2,
                        out_sold_to_location out nocopy varchar2,
                        out_cont_id out nocopy number,
                        out_cont_name out nocopy varchar2,
                        x_return_status out NOCOPY /* file.sql.39 change */ varchar2,
                        x_msg_data out NOCOPY /* file.sql.39 change */ varchar2,
                        x_msg_count out NOCOPY /* file.sql.39 change */ number,
                        in_county in varchar2,
                        in_party_site_number in varchar2
                    );


END oe_oe_inline_address;

/
