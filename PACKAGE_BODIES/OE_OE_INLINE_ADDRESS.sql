--------------------------------------------------------
--  DDL for Package Body OE_OE_INLINE_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_INLINE_ADDRESS" AS
/* $Header: OEXFINLB.pls 120.0.12010000.3 2008/12/31 06:24:01 smanian ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'oe_oe_inline_address';
G_CREATED_BY_MODULE           CONSTANT VARCHAR2(30) := 'ONT_UI_ADD_CUSTOMER';



FUNCTION find_lookup_meaning(in_lookup_type in varchar2,
                             in_lookup_code in varchar2
                            ) return varchar2 IS

    CURSOR c_meaning is
        SELECT meaning
          from ar_lookups
          where lookup_type = in_lookup_type
            and lookup_code = in_lookup_code;
    l_meaning varchar2(200);

    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

    OPEN c_meaning;
    FETCH c_meaning
     INTO l_meaning;
    if c_meaning%NOTFOUND then
        CLOSE c_meaning;
        return null;
    elsif c_meaning%FOUND then
        CLOSE c_meaning;
        return l_meaning;
    end if;

    return null;

EXCEPTION
    when others then
        if c_meaning%ISOPEN then
            close c_meaning;
        end if;
        return null;


END find_lookup_meaning;


PROCEDURE Create_contact
                    ( p_contact_last_name in varchar2,
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
                  in_phone_country_code   in varchar2 default null
                  ) IS

l_person_rec hz_party_v2pub.person_rec_type;
l_party_rec hz_party_v2pub.party_rec_type;

x_party_id number;
x_party_number varchar2(50);
x_profile_id number;

x_rel_party_id number;
x_rel_party_number hz_parties.party_number%TYPE;
x_party_relationship_id number;

l_org_contact_rec hz_party_contact_v2pub.org_contact_rec_type;
x_org_contact_id number;

x_cust_account_role_id       number;

l_cust_acct_roles_rec hz_cust_account_role_v2pub.cust_account_role_rec_type;

l_gen_party_number varchar2(1);
l_gen_contact_number varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_person_rec.person_first_name:=p_contact_first_name;
    l_person_rec.person_last_name:=p_contact_last_name;
    l_person_rec.person_pre_name_adjunct:=p_contact_title;
    l_person_rec.created_by_module :=  NVL(p_created_by_module,G_CREATED_BY_MODULE);

    l_gen_party_number := nvl(fnd_profile.value('HZ_GENERATE_PARTY_NUMBER'),'Y');
    --l_gen_contact_number := nvl(fnd_profile.value('AR_AUTOMATIC_CONTACT_NUMBERING'),'Y');
    l_gen_contact_number := nvl(fnd_profile.value('HZ_GENERATE_CONTACT_NUMBER'),'Y');

    -- if the party_number is not automatically generated then get it
    -- from the sequence
    if l_gen_party_number = 'N' then
       select hz_party_number_s.nextval
         into l_party_rec.party_number
         from dual;
    end if;

    l_person_rec.party_rec := l_party_rec;

    HZ_PARTY_V2PUB.Create_Person(
                      p_person_rec        => l_person_rec,
                      x_party_id          => x_party_id,
                      x_party_number      => x_party_number,
                      x_profile_id        => x_profile_id,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data
                      );

    if x_return_status in ('E','U') then
      return;
    end if;


    if l_gen_party_number = 'N' then
        select hz_party_number_s.nextval
	    into l_org_contact_rec.party_rel_rec.party_rec.party_number
	    from dual;
    end if;

    l_org_contact_rec.party_rel_rec.subject_id := x_party_id;
    l_org_contact_rec.party_rel_rec.object_id := p_party_id;
    l_org_contact_rec.party_rel_rec.relationship_type := 'CONTACT';
    l_org_contact_rec.party_rel_rec.relationship_code := 'CONTACT_OF';
    l_org_contact_rec.party_rel_rec.start_date := sysdate;
    l_org_contact_rec.party_rel_rec.subject_table_name   := 'HZ_PARTIES';
    l_org_contact_rec.party_rel_rec.object_table_name    := 'HZ_PARTIES';
    l_org_contact_rec.party_rel_rec.subject_type := 'PERSON';
    l_org_contact_rec.party_rel_rec.created_by_module    := NVL(p_created_by_module,G_CREATED_BY_MODULE);


    Select party_type
    Into l_org_contact_rec.party_rel_rec.object_type
    From HZ_PARTIES
    Where party_id = p_party_id;

    if l_gen_contact_number = 'N' then

        select hz_contact_numbers_s.nextval
		into l_org_contact_rec.contact_number
		from dual;
    end if;

    l_org_contact_rec.title:= p_contact_title;
    l_org_contact_rec.created_by_module   := G_CREATED_BY_MODULE;


   HZ_PARTY_CONTACT_V2PUB.Create_Org_Contact (
                      p_org_contact_rec  => l_org_contact_rec,
                      x_party_id         => x_rel_party_id,
                      x_party_number     => x_rel_party_number,
                      x_party_rel_id     => x_party_relationship_id,
                      x_org_contact_id   => x_org_contact_id,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data
                                          );

    if x_return_status in ('E','U') then
      return;
    end if;


    if p_email is not null then

        create_contact_point(
                             in_contact_point_type =>'EMAIL',
                             in_owner_table_id=>x_rel_party_id,
                             in_email=>p_email,
                             in_phone_area_code =>NULL,
                             in_phone_number=>NULL,
                             in_phone_extension=>NULL,
			     p_created_by_module => p_created_by_module,
			     p_orig_system => p_orig_system,
			     p_orig_system_reference => p_orig_system_reference,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data
                             );
        if x_return_status in ('E','U') then
          return;
        end if;

    end if;


    if p_area_code is not null or p_phone_number is not null then

        create_contact_point(
                             in_contact_point_type =>'PHONE',
                             in_owner_table_id=>x_rel_party_id,
                             in_email=>NULL,
                             in_phone_area_code =>p_area_code,
                             in_phone_number=>p_phone_number,
                             in_phone_extension=>p_extension,
                             in_phone_country_Code=>in_phone_country_code,
			     p_created_by_module => p_created_by_module,
			     p_orig_system => p_orig_system,
			     p_orig_system_reference => p_orig_system_reference,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data,
                 c_attribute_category=>c2_attribute_category,
                 c_attribute1=>c2_attribute1,
                 c_attribute2=>c2_attribute2,
                 c_attribute3=>c2_attribute3,
                 c_attribute4=>c2_attribute4,
                 c_attribute5=>c2_attribute5,
                 c_attribute6=>c2_attribute6,
                 c_attribute7=>c2_attribute7,
                 c_attribute8=>c2_attribute8,
                 c_attribute9=>c2_attribute9,
                 c_attribute10=>c2_attribute10,
                 c_attribute11=>c2_attribute11,
                 c_attribute12=>c2_attribute12,
                 c_attribute13=>c2_attribute13,
                 c_attribute14=>c2_attribute14,
                 c_attribute15=>c2_attribute15,
                 c_attribute16=>c2_attribute16,
                 c_attribute17=>c2_attribute17,
                 c_attribute18=>c2_attribute18,
                 c_attribute19=>c2_attribute19,
                 c_attribute20=>c2_attribute20
					    );
        if x_return_status in ('E','U') then
          return;
        end if;

    end if;



    l_cust_acct_roles_rec.party_id := x_rel_party_id;
    l_cust_acct_roles_rec.cust_account_id := p_acct_id;
    l_cust_acct_roles_rec.role_type := 'CONTACT';
    l_cust_acct_roles_rec.cust_acct_site_id := NULL;
    l_cust_acct_roles_rec.attribute_category := c_attribute_category;
    l_cust_acct_roles_rec.attribute1 := c_attribute1;
    l_cust_acct_roles_rec.attribute2 := c_attribute2;
    l_cust_acct_roles_rec.attribute3 := c_attribute3;
    l_cust_acct_roles_rec.attribute4 := c_attribute4;
    l_cust_acct_roles_rec.attribute5 := c_attribute5;
    l_cust_acct_roles_rec.attribute6 := c_attribute6;
    l_cust_acct_roles_rec.attribute7 := c_attribute7;
    l_cust_acct_roles_rec.attribute8 := c_attribute8;
    l_cust_acct_roles_rec.attribute9 := c_attribute9;
    l_cust_acct_roles_rec.attribute10 := c_attribute10;
    l_cust_acct_roles_rec.attribute11 := c_attribute11;
    l_cust_acct_roles_rec.attribute12 := c_attribute12;
    l_cust_acct_roles_rec.attribute13 := c_attribute13;
    l_cust_acct_roles_rec.attribute14 := c_attribute14;
    l_cust_acct_roles_rec.attribute15 := c_attribute15;
    l_cust_acct_roles_rec.attribute16 := c_attribute16;
    l_cust_acct_roles_rec.attribute17 := c_attribute17;
    l_cust_acct_roles_rec.attribute18 := c_attribute18;
    l_cust_acct_roles_rec.attribute19 := c_attribute19;
    l_cust_acct_roles_rec.attribute20 := c_attribute20;
    l_cust_acct_roles_rec.created_by_module := NVL(p_created_by_module,G_CREATED_BY_MODULE);
    l_cust_acct_roles_rec.orig_system := p_orig_system; --ER7675548
    l_cust_acct_roles_rec.orig_system_reference := p_orig_system_reference; --ER7675548


    HZ_CUST_ACCOUNT_ROLE_V2PUB.Create_Cust_Account_Role(
                p_cust_account_role_rec  => l_cust_acct_roles_rec,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data,
                x_cust_account_role_id   => x_cust_account_role_id
                );

    if x_return_status in ('E','U') then
      return;
    end if;

    select party_name
	 into x_contact_name
	 from hz_parties
     where party_id = x_party_id;

    x_contact_id := x_cust_account_role_id;


END create_contact;


PROCEDURE create_acct_contact
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
                  ) IS

x_cust_account_role_id       number;
l_cust_acct_roles_rec hz_cust_account_role_v2pub.cust_account_role_rec_type;

    /*CURSOR c_email IS
        SELECT email_address
          FROM hz_contact_points
         WHERE owner_table_id = p_contact_party_id
           AND owner_table_name = 'HZ_PARTIES'
           AND contact_point_type = 'EMAIL'
           AND primary_flag = 'Y'
           AND status       = 'A'; */

    CURSOR c_email IS
        SELECT email_address
          fROM hz_parties
         where party_id = p_contact_party_id;

    l_email hz_parties.email_address%TYPE;
    l_create_email boolean := FALSE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


    /*-- if email is given by the add customer form, then we check that
    -- email is not the one found from the lov or there are no email address
    -- previously defined
    if p_email is not null then
        OPEN c_email;
        FETCH c_email
         INTO l_email;
        IF c_email%FOUND then

            if l_email is not null and p_email != l_email then
                l_create_email := FALSE;
            end if;
        ELSIF c_email%NOTFOUND then
            l_create_email := TRUE;
        END IF;
        CLOSE c_email;

        IF l_create_email then
             create_contact_point(
                             in_contact_point_type =>'EMAIL',
                             in_owner_table_id=>p_contact_party_id,
                             in_email=>p_email,
                             in_phone_area_code =>NULL,
                             in_phone_number=>NULL,
                             in_phone_extension=>NULL,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data
                            );
            if x_return_status in ('E','U') then
                return;
            end if;
        END IF;

    end if;


    if p_area_code is not nul or p_phone_number is not null then

        create_contact_point(
                             in_contact_point_type =>'PHONE',
                             in_owner_table_id=>p_contact_party_id,
                             in_email=>NULL,
                             in_phone_area_code =>p_area_code,
                             in_phone_number=>p_phone_number,
                             in_phone_extension=>p_extension,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data,
                 c_attribute_category=>c2_attribute_category,
                 c_attribute1=>c2_attribute1,
                 c_attribute2=>c2_attribute2,
                 c_attribute3=>c2_attribute3,
                 c_attribute4=>c2_attribute4,
                 c_attribute5=>c2_attribute5,
                 c_attribute6=>c2_attribute6,
                 c_attribute7=>c2_attribute7,
                 c_attribute8=>c2_attribute8,
                 c_attribute9=>c2_attribute9,
                 c_attribute10=>c2_attribute10,
                 c_attribute11=>c2_attribute11,
                 c_attribute12=>c2_attribute12,
                 c_attribute13=>c2_attribute13,
                 c_attribute14=>c2_attribute14,
                 c_attribute15=>c2_attribute15,
                 c_attribute16=>c2_attribute16,
                 c_attribute17=>c2_attribute17,
                 c_attribute18=>c2_attribute18,
                 c_attribute19=>c2_attribute19,
                 c_attribute20=>c2_attribute20
					    );
        if x_return_status in ('E','U') then
          return;
        end if;

    end if;  */


    l_cust_acct_roles_rec.party_id := p_contact_party_id;
    l_cust_acct_roles_rec.cust_account_id := p_acct_id;
    l_cust_acct_roles_rec.role_type := 'CONTACT';
    l_cust_acct_roles_rec.cust_acct_site_id := NULL;

    -- If created by module is sent from outside like Automatic Acct Creation
    IF in_Created_by_module is not null then
      l_cust_acct_roles_rec.created_by_module := in_created_by_module;

    ELSE
      l_cust_acct_roles_rec.created_by_module := G_CREATED_BY_MODULE;
    END IF;

    l_cust_acct_roles_rec.attribute_category := c_attribute_category;
    l_cust_acct_roles_rec.attribute1 := c_attribute1;
    l_cust_acct_roles_rec.attribute2 := c_attribute2;
    l_cust_acct_roles_rec.attribute3 := c_attribute3;
    l_cust_acct_roles_rec.attribute4 := c_attribute4;
    l_cust_acct_roles_rec.attribute5 := c_attribute5;
    l_cust_acct_roles_rec.attribute6 := c_attribute6;
    l_cust_acct_roles_rec.attribute7 := c_attribute7;
    l_cust_acct_roles_rec.attribute8 := c_attribute8;
    l_cust_acct_roles_rec.attribute9 := c_attribute9;
    l_cust_acct_roles_rec.attribute10 := c_attribute10;
    l_cust_acct_roles_rec.attribute11 := c_attribute11;
    l_cust_acct_roles_rec.attribute12 := c_attribute12;
    l_cust_acct_roles_rec.attribute13 := c_attribute13;
    l_cust_acct_roles_rec.attribute14 := c_attribute14;
    l_cust_acct_roles_rec.attribute15 := c_attribute15;
    l_cust_acct_roles_rec.attribute16 := c_attribute16;
    l_cust_acct_roles_rec.attribute17 := c_attribute17;
    l_cust_acct_roles_rec.attribute18 := c_attribute18;
    l_cust_acct_roles_rec.attribute19 := c_attribute19;
    l_cust_acct_roles_rec.attribute20 := c_attribute20;



    HZ_CUST_ACCOUNT_ROLE_V2PUB.Create_Cust_Account_Role(
                p_cust_account_role_rec  => l_cust_acct_roles_rec,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data,
                x_cust_account_role_id   => x_cust_account_role_id
                );

    if x_return_status in ('E','U') then
      return;
    end if;

    x_contact_id := x_cust_account_role_id;

EXCEPTION
    when others then
        if c_email%ISOPEN then
            CLOSE c_email;
        end if;

END create_acct_contact;




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
                  in_phone_country_code  in varchar2 default null,
		  p_created_by_module IN VARCHAR2 DEFAULT NULL,
		  p_orig_system IN VARCHAR2 DEFAULT NULL, --ER7675548
		  p_orig_system_reference IN VARCHAR2 DEFAULT NULL --ER7675548
						) IS

x_contact_point_id number;

l_contact_points_rec HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
l_email_rec          HZ_CONTACT_POINT_V2PUB.email_rec_type;
l_phone_rec          HZ_CONTACT_POINT_V2PUB.phone_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_contact_points_rec.contact_point_type := in_contact_point_type;
    l_contact_points_rec.status := 'A';
    l_contact_points_rec.owner_table_name := 'HZ_PARTIES';
    l_contact_points_rec.owner_table_id := in_owner_table_id;
    l_contact_points_rec.primary_flag := 'Y';
    l_contact_points_rec.created_by_module  := NVL(p_created_by_module,G_CREATED_BY_MODULE);

    l_contact_points_rec.orig_system  := p_orig_system; --ER7675548
    l_contact_points_rec.orig_system_reference  := p_orig_system_reference; --ER7675548

    select hz_contact_points_s.nextval
      into l_contact_points_rec.contact_point_id
      from dual;


    IF in_contact_point_type = 'EMAIL' then
        l_email_rec.email_address := in_email;

       HZ_CONTACT_POINT_V2PUB.Create_Contact_Point(
                  p_contact_point_rec         =>  l_contact_points_rec,
                  p_email_rec                  =>  l_email_rec,
                  x_return_status              =>  x_return_status,
                  x_msg_count                  =>  x_msg_count,
                  x_msg_data                   =>  x_msg_data,
                  x_contact_point_id           =>  x_contact_point_id
                  );

    ELSIF in_contact_point_type = 'PHONE' then

        l_phone_rec.phone_area_code := in_phone_area_code;
        l_phone_rec.phone_number := in_phone_number;
        l_phone_rec.phone_extension := in_phone_extension;
        l_phone_rec.phone_country_code := in_phone_country_code;
        l_phone_rec.phone_line_type := 'GEN';

        l_contact_points_rec.attribute_category := c_attribute_category;
        l_contact_points_rec.attribute1 := c_attribute1;
        l_contact_points_rec.attribute2 := c_attribute2;
        l_contact_points_rec.attribute3 := c_attribute3;
        l_contact_points_rec.attribute4 := c_attribute4;
        l_contact_points_rec.attribute5 := c_attribute5;
        l_contact_points_rec.attribute6 := c_attribute6;
        l_contact_points_rec.attribute7 := c_attribute7;
        l_contact_points_rec.attribute8 := c_attribute8;
        l_contact_points_rec.attribute9 := c_attribute9;
        l_contact_points_rec.attribute10 := c_attribute10;
        l_contact_points_rec.attribute11 := c_attribute11;
        l_contact_points_rec.attribute12 := c_attribute12;
        l_contact_points_rec.attribute13 := c_attribute13;
        l_contact_points_rec.attribute14 := c_attribute14;
        l_contact_points_rec.attribute15 := c_attribute15;
        l_contact_points_rec.attribute16 := c_attribute16;
        l_contact_points_rec.attribute17 := c_attribute17;
        l_contact_points_rec.attribute18 := c_attribute18;
        l_contact_points_rec.attribute19 := c_attribute19;
        l_contact_points_rec.attribute20 := c_attribute20;

        HZ_CONTACT_POINT_V2PUB.Create_Contact_Point(
                  p_contact_point_rec         =>  l_contact_points_rec,
                  p_phone_rec                  =>  l_phone_rec,
                  x_return_status              =>  x_return_status,
                  x_msg_count                  =>  x_msg_count,
                  x_msg_data                   =>  x_msg_data,
                  x_contact_point_id           =>  x_contact_point_id
                  );

    END IF;


END create_contact_point;



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
x_location_id OUT NOCOPY Number,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

                  ) IS

l_location_rec       HZ_LOCATION_V2PUB.location_rec_type;
l_msg_count number;
l_msg_data  Varchar2(4000);
l_return_status Varchar2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_location_rec.country :=p_country;
   l_location_rec.address1 :=p_address1;
   l_location_rec.address2 :=p_address2;
   l_location_rec.address3 :=p_address3;
   l_location_rec.address4 :=p_address4;
   l_location_rec.city :=p_city;
   l_location_rec.state :=p_state;
   l_location_rec.postal_code:=p_postal_code;
   l_location_rec.province:=p_province;
   l_location_rec.county:=p_county;
   l_location_rec.address_style:=p_address_style;
   l_location_rec.address_lines_phonetic:=p_address_line_phonetic;	--Bug# 7575444
   l_location_rec.attribute_category := c_attribute_category;
   l_location_rec.attribute1 := c_attribute1;
   l_location_rec.attribute2 := c_attribute2;
   l_location_rec.attribute3 := c_attribute3;
   l_location_rec.attribute4 := c_attribute4;
   l_location_rec.attribute5 := c_attribute5;
   l_location_rec.attribute6 := c_attribute6;
   l_location_rec.attribute7 := c_attribute7;
   l_location_rec.attribute8 := c_attribute8;
   l_location_rec.attribute9 := c_attribute9;
   l_location_rec.attribute10 := c_attribute10;
   l_location_rec.attribute11 := c_attribute11;
   l_location_rec.attribute12 := c_attribute12;
   l_location_rec.attribute13 := c_attribute13;
   l_location_rec.attribute14 := c_attribute14;
   l_location_rec.attribute15 := c_attribute15;
   l_location_rec.attribute16 := c_attribute16;
   l_location_rec.attribute17 := c_attribute17;
   l_location_rec.attribute18 := c_attribute18;
   l_location_rec.attribute19 := c_attribute19;
   l_location_rec.attribute20 := c_attribute20;

   l_location_rec.created_by_module := NVL(p_created_by_module,G_CREATED_BY_MODULE); --ER7675548
   l_location_rec.orig_system := p_orig_system; --ER7675548
   l_location_rec.orig_system_reference := p_orig_system_reference ; --ER7675548

   HZ_LOCATION_V2PUB.Create_Location(
                                     p_init_msg_list  => Null
                                    ,p_location_rec   => l_location_rec
                                    ,x_return_status  => l_return_status
                                    ,x_msg_count      => l_msg_count
                                    ,x_msg_data       => l_msg_data
                                    ,x_location_id    => x_location_id
                                    );

    IF l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting oe_oe_inline_address.create_location', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE CREATE_LOCATION EXC ERROR' , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE CREATE_LOCATION UNEXPECTED ERROR' , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE CREATE_LOCATION WHEN OTHERS' , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Location'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_Location;


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

                  )IS
l_party_site_rec           HZ_PARTY_SITE_V2PUB.party_site_rec_type;
tmp_var VARCHAR2(2000);
tmp_var1 VARCHAR2(2000);
x  number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER.CREATE_PARTY_SITE' , 1 ) ;
    END IF;
  l_party_site_rec.party_id:=  p_party_id;
  l_party_site_rec.location_id:=p_location_id;
  -- Party Site Number Should be sent only if auto-numbering set off . Add
  --  Validation to check this
  IF p_party_site_Number IS NOT NULL THEN
   l_party_site_rec.party_site_number:=p_party_site_number;
  END IF;

  l_party_site_rec.created_by_module := NVL(p_created_by_module,G_CREATED_BY_MODULE); --ER7675548
  l_party_site_rec.orig_system := p_orig_system; --ER7675548
  l_party_site_rec.orig_system_reference := p_orig_system_reference; --ER7675548



     HZ_PARTY_SITE_V2PUB.Create_Party_Site
                          (
                           p_party_site_rec => l_party_site_rec,
                           x_party_site_id => x_party_site_id,
                           x_party_site_number => x_party_site_number,
                           x_return_status => x_return_status,
                           x_msg_count => x_msg_count,
                           x_msg_data =>  x_msg_data
                          );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALL HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE'||X_RETURN_STATUS , 1 ) ;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALL HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE MSG'||X_MSG_DATA , 1 ) ;
    END IF;

    IF x_msg_count = 1 THEN
      --x_msg_data := x_msg_data || '**CREATE_PARTY_SITE**';
      return;
   ELSIF
      x_msg_count > 1 THEN
      FOR x IN 1..x_msg_count LOOP
      tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
      tmp_var1 := tmp_var1 || ' ' || tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
      --x_msg_data := x_msg_data || '**CREATE_PARTY_SITE**';
      return;
   END IF;

    IF x_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Location'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_Party_Site;


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
                  ) IS
l_account_site_rec         HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
tmp_var VARCHAR2(2000);
tmp_var1 VARCHAR2(2000);
x  number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_account_site_rec.party_site_id:=p_party_site_id;
   l_account_site_rec.cust_account_id:=p_cust_account_id;

   l_account_site_rec.attribute_category := c_attribute_category;
   l_account_site_rec.attribute1 := c_attribute1;
   l_account_site_rec.attribute2 := c_attribute2;
   l_account_site_rec.attribute3 := c_attribute3;
   l_account_site_rec.attribute4 := c_attribute4;
   l_account_site_rec.attribute5 := c_attribute5;
   l_account_site_rec.attribute6 := c_attribute6;
   l_account_site_rec.attribute7 := c_attribute7;
   l_account_site_rec.attribute8 := c_attribute8;
   l_account_site_rec.attribute9 := c_attribute9;
   l_account_site_rec.attribute10 := c_attribute10;
   l_account_site_rec.attribute11 := c_attribute11;
   l_account_site_rec.attribute12 := c_attribute12;
   l_account_site_rec.attribute13 := c_attribute13;
   l_account_site_rec.attribute14 := c_attribute14;
   l_account_site_rec.attribute15 := c_attribute15;
   l_account_site_rec.attribute16 := c_attribute16;
   l_account_site_rec.attribute17 := c_attribute17;
   l_account_site_rec.attribute18 := c_attribute18;
   l_account_site_rec.attribute19 := c_attribute19;
   l_account_site_rec.attribute20 := c_attribute20;

   -- If created by module is sent from outside like Automatic Acct Creation
   IF in_Created_by_module is not null then
     l_account_site_rec.created_by_module := in_created_by_module;

   ELSE
     l_account_site_rec.created_by_module := G_CREATED_BY_MODULE;
   END IF;

   l_account_site_rec.orig_system := p_orig_system; --ER7675548
   l_account_site_rec.orig_system_reference := p_orig_system_reference; --ER7675548

   HZ_CUST_ACCOUNT_SITE_V2PUB.Create_Cust_Acct_Site
                              (
                               p_cust_acct_site_rec => l_account_site_rec,
                               x_return_status => x_return_status,
                               x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data,
                               x_cust_acct_site_id => x_customer_site_id
                              );

    IF x_msg_count = 1 THEN
      --x_msg_data := x_msg_data || '**CREATE_PARTY_SITE**';
      return;
   ELSIF
      x_msg_count > 1 THEN
      FOR x IN 1..x_msg_count LOOP
      tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
      tmp_var1 := tmp_var1 || ' ' || tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
      --x_msg_data := x_msg_data || '**CREATE_PARTY_SITE**';
      return;
   END IF;

    IF x_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Location'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END  Create_Account_Site;




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
                  ) IS

l_acct_site_uses           HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
l_cust_profile_rec         HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 l_acct_site_uses.cust_acct_site_id := p_cust_acct_site_id;
 l_acct_site_uses.site_use_code := p_site_use_code;
 l_acct_site_uses.location := p_location;
 l_acct_site_uses.attribute_category := c_attribute_category;
 l_acct_site_uses.attribute1 := c_attribute1;
 l_acct_site_uses.attribute2 := c_attribute2;
 l_acct_site_uses.attribute3 := c_attribute3;
 l_acct_site_uses.attribute4 := c_attribute4;
 l_acct_site_uses.attribute5 := c_attribute5;
 l_acct_site_uses.attribute6 := c_attribute6;
 l_acct_site_uses.attribute7 := c_attribute7;
 l_acct_site_uses.attribute8 := c_attribute8;
 l_acct_site_uses.attribute9 := c_attribute9;
 l_acct_site_uses.attribute10 := c_attribute10;
 l_acct_site_uses.attribute11 := c_attribute11;
 l_acct_site_uses.attribute12 := c_attribute12;
 l_acct_site_uses.attribute13 := c_attribute13;
 l_acct_site_uses.attribute14 := c_attribute14;
 l_acct_site_uses.attribute15 := c_attribute15;
 l_acct_site_uses.attribute16 := c_attribute16;
 l_acct_site_uses.attribute17 := c_attribute17;
 l_acct_site_uses.attribute18 := c_attribute18;
 l_acct_site_uses.attribute19 := c_attribute19;
 l_acct_site_uses.attribute20 := c_attribute20;
 l_acct_site_uses.attribute21 := c_attribute21;
 l_acct_site_uses.attribute22 := c_attribute22;
 l_acct_site_uses.attribute23 := c_attribute23;
 l_acct_site_uses.attribute24 := c_attribute24;
 l_acct_site_uses.attribute25 := c_attribute25;

 IF in_primary_flag IS NOT NULL THEN
   l_acct_site_uses.primary_flag         := in_primary_flag;
 END IF;

 -- If created by module is sent from outside like Automatic Acct Creation
 IF in_Created_by_module is not null then
   l_acct_site_uses.created_by_module := in_created_by_module;

 ELSE
   l_acct_site_uses.created_by_module := G_CREATED_BY_MODULE;
 END IF;


 HZ_CUST_ACCOUNT_SITE_V2PUB.Create_Cust_Site_Use
             (
              p_cust_site_use_rec => l_acct_site_uses,
              p_customer_profile_rec => l_cust_profile_rec,
              p_create_profile => FND_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data,
              x_site_use_id => x_site_use_id
             );

END Create_Acct_Site_Uses;




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
			   p_orig_system IN VARCHAR2 DEFAULT NULL, --ER7675548
			   p_orig_system_reference IN VARCHAR2 DEFAULT NULL, --ER7675548
 		           p_account_description   IN VARCHAR2 DEFAULT NULL --ER7675548
                           ) IS

l_person_rec        HZ_PARTY_V2PUB.person_rec_type;
l_organization_rec  HZ_PARTY_V2PUB.organization_rec_type;
l_party_rec         HZ_PARTY_V2PUB.party_rec_type;
l_cust_profile_rec  HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
l_account_rec       HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;

x_profile_id NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF p_account_description IS NOT NULL THEN
	l_account_rec.account_name := p_account_description; --ER7675548
   END IF;
   l_account_rec.account_number := x_cust_account_number;
   l_account_rec.attribute_category := c_attribute_category;
   l_account_rec.attribute1 := c_attribute1;
   l_account_rec.attribute2 := c_attribute2;
   l_account_rec.attribute3 := c_attribute3;
   l_account_rec.attribute4 := c_attribute4;
   l_account_rec.attribute5 := c_attribute5;
   l_account_rec.attribute6 := c_attribute6;
   l_account_rec.attribute7 := c_attribute7;
   l_account_rec.attribute8 := c_attribute8;
   l_account_rec.attribute9 := c_attribute9;
   l_account_rec.attribute10 := c_attribute10;
   l_account_rec.attribute11 := c_attribute11;
   l_account_rec.attribute12 := c_attribute12;
   l_account_rec.attribute13 := c_attribute13;
   l_account_rec.attribute14 := c_attribute14;
   l_account_rec.attribute15 := c_attribute15;
   l_account_rec.attribute16 := c_attribute16;
   l_account_rec.attribute17 := c_attribute17;
   l_account_rec.attribute18 := c_attribute18;
   l_account_rec.attribute19 := c_attribute19;
   l_account_rec.attribute20 := c_attribute20;

   l_account_rec.global_attribute_category := c_global_attribute_category;
   l_account_rec.global_attribute1 := c_global_attribute1;
   l_account_rec.global_attribute2 := c_global_attribute2;
   l_account_rec.global_attribute3 := c_global_attribute3;
   l_account_rec.global_attribute4 := c_global_attribute4;
   l_account_rec.global_attribute5 := c_global_attribute5;
   l_account_rec.global_attribute6 := c_global_attribute6;
   l_account_rec.global_attribute7 := c_global_attribute7;
   l_account_rec.global_attribute8 := c_global_attribute8;
   l_account_rec.global_attribute9 := c_global_attribute9;
   l_account_rec.global_attribute10 := c_global_attribute10;
   l_account_rec.global_attribute11 := c_global_attribute11;
   l_account_rec.global_attribute12 := c_global_attribute12;
   l_account_rec.global_attribute13 := c_global_attribute13;
   l_account_rec.global_attribute14 := c_global_attribute14;
   l_account_rec.global_attribute15 := c_global_attribute15;
   l_account_rec.global_attribute16 := c_global_attribute16;
   l_account_rec.global_attribute17 := c_global_attribute17;
   l_account_rec.global_attribute18 := c_global_attribute18;
   l_account_rec.global_attribute19 := c_global_attribute19;
   l_account_rec.global_attribute20 := c_global_attribute20;


   -- If created by module is sent from outside like Automatic Acct Creation
   IF in_Created_by_module is not null then
     l_account_rec.created_by_module := in_created_by_module;

   ELSE
     l_account_rec.created_by_module := G_CREATED_BY_MODULE;
   END IF;

l_account_rec.orig_system := p_orig_system; --ER7675548
l_account_rec.orig_system_reference := p_orig_system_reference; --ER7675548

 if p_party_type = 'PERSON' then

   l_person_rec.person_first_name:=p_first_name;
   l_person_rec.person_last_name:=p_last_name;
   l_person_rec.person_middle_name:=p_middle_name;
   l_person_rec.tax_reference:=p_tax_reference;
   l_person_rec.jgzz_fiscal_code:=p_taxpayer_id;
   l_person_rec.person_name_suffix:=p_name_suffix;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CUSTOMER PERSON TITLE='||P_TITLE ) ;
   END IF;
   l_person_rec.person_pre_name_adjunct := p_title;
   l_party_rec.party_number := p_party_number;

   If p_party_id is not null then
       l_party_rec.party_id := p_party_id;
   end if;
   l_person_rec.party_rec := l_party_rec;


 else
   l_organization_rec.organization_name:=p_organization_name;
   l_organization_rec.organization_name_phonetic:=p_alternate_name;
   l_organization_rec.tax_reference:=p_tax_reference;
   l_organization_rec.jgzz_fiscal_code:=p_taxpayer_id;
   l_party_rec.party_number := p_party_number;

   if p_party_id is not null then
       l_party_rec.party_id := p_party_id;
   end if;
   l_organization_rec.party_rec := l_party_rec;

  end if;

 IF p_party_type = 'PERSON' then

     HZ_CUST_ACCOUNT_V2PUB.Create_Cust_Account
                 (
                  p_person_rec           =>  l_person_rec,
                  p_cust_account_rec          =>  l_account_rec,
                  p_customer_profile_rec     =>  l_cust_profile_rec,
                  x_party_id             =>  x_party_id,
                  x_party_number         =>  x_party_number,
                  x_cust_account_id      =>  x_cust_account_id,
                  x_account_number  =>  x_cust_account_number,
                  x_profile_id           =>  x_profile_id,
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data
                 );

  ELSE

     HZ_CUST_ACCOUNT_V2PUB.Create_Cust_Account
                 (
                  p_organization_rec     =>  l_organization_rec,
                  p_cust_account_rec     =>  l_account_rec,
                  p_customer_profile_rec =>  l_cust_profile_rec,
                  x_party_id             =>  x_party_id,
                  x_party_number         =>  x_party_number,
                  x_cust_account_id      =>  x_cust_account_id,
                  x_account_number       =>  x_cust_account_number,
                  x_profile_id           =>  x_profile_id,
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data
                 );

  END IF;


END Create_Account;




PROCEDURE Create_Party_relationship(
                           p_object_party_id       IN Number,
                           p_subject_party_id      IN Number,
                           p_reciprocal_flag       IN Varchar2,
x_party_relationship_id OUT NOCOPY Number,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

					  ) IS

x_party_id number;
x_party_number hz_parties.party_number%TYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     -- commmented out as it is not used anywhere
     NULL;

END create_party_relationship;




PROCEDURE Create_Cust_relationship(
                           p_cust_acct_id          IN Number,
                           p_related_cust_acct_id   IN Number,
                           p_reciprocal_flag       IN Varchar2,
  p_created_by_module IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

					  ) IS

l_cust_rel_rec   HZ_CUST_ACCOUNT_V2PUB.cust_acct_relate_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     l_cust_rel_rec.cust_account_id := p_cust_acct_id;
     l_cust_rel_rec.related_cust_account_id := p_related_cust_acct_id;
     l_cust_rel_rec.relationship_type := 'ALL';
     l_cust_rel_rec.customer_reciprocal_flag := p_reciprocal_flag;
     l_cust_rel_rec.created_by_module := NVL(p_created_by_module,G_CREATED_BY_MODULE);



   HZ_CUST_ACCOUNT_V2PUB.Create_Cust_Acct_Relate
                    (
                    p_cust_acct_relate_rec    =>  l_cust_rel_rec,
                    x_return_status           =>  x_return_status,
                    x_msg_count               =>  x_msg_count,
                    x_msg_data                =>  x_msg_data
                    );

   oe_debug_pub.add('status='||x_return_status||
                 ' msg_count='||x_msg_count||
                 ' msg_data='||x_msg_data||
                 ' cust_acct_related_id='||l_cust_rel_rec.related_cust_account_id||
                 ' cust_acct_id='||l_cust_rel_rec.cust_account_id||
                 ' ship_to_flag='||l_cust_rel_rec.ship_to_flag||
                 ' bill_to_flag='||l_cust_rel_rec.bill_to_flag
                   );


END create_cust_relationship;



PROCEDURE Commit_Changes IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  commit;

END commit_changes;



PROCEDURE Rollback_Changes IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  Rollback;

END rollback_changes;



PROCEDURE Create_Person
                  (
                  p_first_name   IN NUMBER,
                  p_party_number IN OUT NOCOPY /* file.sql.39 change */ Varchar2,
x_party_id OUT NOCOPY NUMBER,

x_profile_id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

                  ) IS

l_person_rec        HZ_PARTY_V2PUB.person_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 l_person_rec.person_first_name:=p_first_name;
 if p_party_number is not null then
   --l_person_rec.party_rec.party_number := p_party_number;
   null;
 end if;

 HZ_PARTY_V2PUB.Create_Person(
                      p_person_rec        => l_person_rec,
                      x_party_id          => x_party_id,
                      x_party_number      => p_party_number,
                      x_profile_id        => x_profile_id,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data
                      );

END Create_Person;


PROCEDURE Create_Organization
                  (
                  p_organization_name   IN NUMBER,
                  p_party_number IN OUT NOCOPY /* file.sql.39 change */ Varchar2,
x_party_id OUT NOCOPY NUMBER,

x_profile_id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

                  ) IS
l_organization_rec  HZ_PARTY_V2PUB.organization_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 l_organization_rec.organization_name:=p_organization_name;
 if p_party_number is not null then
   --l_organization_rec.party_rec.party_number := p_party_number;
   null;
 end if;

END Create_Organization;



PROCEDURE Create_role_resp
                  (
                  p_cust_acct_role_id   IN NUMBER,
                  p_usage_type       IN  VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

x_responsibility_id OUT NOCOPY NUMBER

                  ) IS

l_role_resp_rec    HZ_CUST_ACCOUNT_ROLE_V2PUB.role_responsibility_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_role_resp_rec.cust_account_role_id := p_cust_acct_role_id;
    l_role_resp_rec.responsibility_type  := p_usage_type;
    l_role_resp_rec.primary_flag         := 'Y';
    l_role_resp_rec.created_by_module    := G_CREATED_BY_MODULE;

   HZ_CUST_ACCOUNT_ROLE_V2PUB.Create_Role_Responsibility(
          p_role_responsibility_rec   => l_role_resp_rec,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          x_responsibility_id  => x_responsibility_id
                              );
END create_role_resp;



PROCEDURE add_customer_startup(
                 out_auto_site_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_auto_location_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_auto_cust_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_email_required out NOCOPY /* file.sql.39 change */ varchar2,
                 out_auto_party_numbering out NOCOPY /* file.sql.39 change */ varchar2,
                 out_default_country_code out NOCOPY /* file.sql.39 change */ varchar2,
                 out_default_country out NOCOPY /* file.sql.39 change */ varchar2,
                 out_address_style out NOCOPY /* file.sql.39 change */ varchar2
                               ) IS

    sysparm   ar_system_parameters%rowtype;

BEGIN


    BEGIN
       select *
         into sysparm
         from ar_system_parameters;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
         NULL;
        WHEN TOO_MANY_ROWS THEN
         NULL;
        WHEN OTHERS THEN
         NULL;

    END;


    out_auto_cust_numbering :=sysparm.generate_customer_number;
    --g_home_country_code := sysparm.default_country;
    fnd_profile.get('DEFAULT_COUNTRY',out_default_country_code);
    fnd_profile.get('ONT_MANDATE_CUSTOMER_EMAIL',out_email_required);

    IF out_default_country_code is not null THEN
      select territory_short_name,address_style
       into     out_default_country,out_address_style
       from     fnd_territories_vl
       where  territory_code = out_default_country_code;
    END IF;

    fnd_profile.get('HZ_GENERATE_PARTY_NUMBER',out_auto_party_numbering);
    fnd_profile.get('HZ_GENERATE_PARTY_SITE_NUMBER',out_auto_site_numbering);

    if out_auto_site_numbering is null then
         out_auto_site_numbering :='Y';
    end if;

    -- for location numbering we use the system option site_numbering
    out_auto_location_numbering := nvl(sysparm.auto_site_numbering,'N');


END add_customer_startup;


PROCEDURE Add_Customer(
                        in_cust_account_id in number,
                        in_cust_type varchar2,
                        in_party_Number in varchar2,
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
                    ) IS

x_party_id number;
x_party_number varchar2(100);
l_cust_number varchar2(100);
x_location_id number;
x_party_site_id number;
x_party_site_number varchar2(100);
x_customer_site_id number;
x_cust_account_id number;
x_site_use_id number;


BEGIN

  oe_msg_pub.initialize;
  savepoint add_customer;
  l_cust_number := in_cust_number;

  IF in_cust_account_id is null then

    oe_oe_inline_address.create_account(
                 p_party_number=>null,
                 p_organization_name=>in_cust_name,
                 p_alternate_name=>null,
                 p_tax_reference=>NULL,
                 p_taxpayer_id=>NULL,
                 p_party_id=>null,
                 p_first_name=>in_cust_first_name,
                 p_last_name=>in_cust_last_name,
                 p_middle_name=>in_cust_middle_name,
                 p_name_suffix=>null,
                 p_title=>in_cust_title,
                 p_party_type=>in_cust_type,
                 p_email=>in_cust_email,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
	         c_attribute20=>null,
                 c_global_attribute_category=>null,
                 c_global_attribute1=>null,
                 c_global_attribute2=>null,
                 c_global_attribute3=>null,
                 c_global_attribute4=>null,
                 c_global_attribute5=>null,
                 c_global_attribute6=>null,
                 c_global_attribute7=>null,
                 c_global_attribute8=>null,
                 c_global_attribute9=>null,
                 c_global_attribute10=>null,
                 c_global_attribute11=>null,
                 c_global_attribute12=>null,
                 c_global_attribute13=>null,
                 c_global_attribute14=>null,
                 c_global_attribute15=>null,
                 c_global_attribute16=>null,
                 c_global_attribute17=>null,
                 c_global_attribute18=>null,
                 c_global_attribute19=>null,
                 c_global_attribute20=>null,
                 x_party_id=>x_party_id,
                 x_party_number=>x_party_number,
                 x_cust_Account_id=>x_cust_account_id,
                 x_cust_account_number=>l_cust_number,
                 x_return_status=>x_return_status,
                 x_msg_count=>x_msg_count,
                 x_msg_data=>x_msg_data
                );


    out_cust_Number := l_cust_number;
    out_party_number := x_party_number;
    out_cust_id := x_cust_account_id;


    if x_return_status in ('E','U') then

      /*  OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
      */

      rollback;
      return;

    end if;


    select party_name
      into out_cust_name
     from hz_parties
    where party_id = x_party_id;

   else
     out_cust_id := in_cust_account_id;
     x_cust_account_id := in_cust_account_id;

     select party.party_id,
            party.party_name,
            acct.account_number,
            party.party_number

       into x_party_id,
            out_cust_name,
            out_cust_number,
            out_party_number
       from hz_cust_accounts acct,
            hz_parties party
      where acct.cust_account_id = in_cust_account_id
        and party.party_id = acct.party_id;


   end if; -- if in_cust_account_id is null

    if in_cust_email is not null then


        create_contact_point(
                             in_contact_point_type =>'EMAIL',
                             in_owner_table_id=>x_party_id,
                             in_email=>in_cust_email,
                             in_phone_area_code =>NULL,
                             in_phone_number=>NULL,
                             in_phone_extension=>NULL,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data
                             );
        if x_return_status in ('E','U') then

          rollback;
          return;
        end if;

    end if;


    if in_cust_phone_number is not null then

        create_contact_point(
                             in_contact_point_type =>'PHONE',
                             in_owner_table_id=>x_party_id,
                             in_email=>NULL,
                             in_phone_area_code =>null,
                             in_phone_number=>in_cust_phone_number,
                             in_phone_extension=>in_cust_phone_ext,
                             in_phone_country_code=>in_cust_country_code,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data,
                             c_attribute_category=>null,
                             c_attribute1=>null,
                             c_attribute2=>null,
                             c_attribute3=>null,
                             c_attribute4=>null,
                             c_attribute5=>null,
                             c_attribute6=>null,
                             c_attribute7=>null,
                             c_attribute8=>null,
                             c_attribute9=>null,
                             c_attribute10=>null,
                             c_attribute11=>null,
                             c_attribute12=>null,
                             c_attribute13=>null,
                             c_attribute14=>null,
                             c_attribute15=>null,
                             c_attribute16=>null,
                             c_attribute17=>null,
                             c_attribute18=>null,
                             c_attribute19=>null,
                             c_attribute20=>null
					    );

        if x_return_status in ('E','U') then
          rollback;
          return;
        end if;

    end if;

    IF in_addr_line1 is not null then

      oe_oe_inline_address.Create_Location
                  (
                  p_country => in_addr_country_Code,
                  p_address1=> in_addr_line1,
                  p_address2 =>in_addr_line2,
                  p_address3 =>in_addr_line3,
                  p_address4 =>null,
                  p_city     =>in_addr_city,
                  p_postal_code =>in_addr_zip,
                  p_state    =>in_addr_state,
                  p_province =>null,
                  p_county  => in_county,
                  p_address_style =>null,
                  p_address_line_phonetic => Null,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_global_attribute_category=>null,
                 c_global_attribute1=>null,
                 c_global_attribute2=>null,
                 c_global_attribute3=>null,
                 c_global_attribute4=>null,
                 c_global_attribute5=>null,
                 c_global_attribute6=>null,
                 c_global_attribute7=>null,
                 c_global_attribute8=>null,
                 c_global_attribute9=>null,
                 c_global_attribute10=>null,
                 c_global_attribute11=>null,
                 c_global_attribute12=>null,
                 c_global_attribute13=>null,
                 c_global_attribute14=>null,
                 c_global_attribute15=>null,
                 c_global_attribute16=>null,
                 c_global_attribute17=>null,
                 c_global_attribute18=>null,
                 c_global_attribute19=>null,
                 c_global_attribute20=>null,
                 x_location_id => x_location_id,
                 x_return_status=>x_return_status ,
                 x_msg_count=>x_msg_count,
                 x_msg_data=> x_msg_data
                  ) ;



   if x_return_status in ('E','U') then
          rollback;
          return;
   end if;


   --x_location_id := 1048;

   oe_oe_inline_address.Create_Party_Site
                  (
                  p_party_id => x_party_id,
                  p_location_id=>x_location_id ,
                  p_party_site_number =>in_party_site_number,
                  x_party_site_id =>x_party_site_id  ,
                  x_party_site_number =>x_party_site_number,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data
                  ) ;
    if x_return_status in ('E','U') then
      rollback;
      return;
    end if;

  oe_oe_inline_address.Create_Account_Site
                  (
                  p_cust_account_id =>x_cust_account_id,
                  p_party_site_id   =>x_party_site_id,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 x_customer_site_id =>x_customer_site_id  ,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data
                  ) ;

    if x_return_status in ('E','U') then
      rollback;
      return;
    end if;

    -- if SHIPTO needs to be created
    if in_ship_usage = 'Y' then

      oe_oe_inline_address.Create_Acct_Site_Uses
                  (
                  p_cust_acct_site_id =>x_customer_site_id,
                  p_location   =>in_addr_location,
                  p_site_use_code   =>'SHIP_TO',
                  x_site_use_id =>x_site_use_id  ,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_attribute21=>null,
                 c_attribute22=>null,
                 c_attribute23=>null,
                 c_attribute24=>null,
                 c_attribute25=>null
                  );


      if x_return_status in ('E','U') then
        return;
      end if;


      out_ship_to_site_use_id := x_site_use_id;

      -- if location is system generated then we fetch the location number
      -- after creation
      if in_addr_location is null then
        select location
          into out_ship_to_location
          from hz_cust_site_uses_all
          where site_use_id = x_site_use_id;
      else
        out_ship_to_location := in_addr_location;
      end if;

    end if; -- if shipto needs to be created


    -- if BILLTO needs to be created
    if in_bill_usage = 'Y' then

      oe_oe_inline_address.Create_Acct_Site_Uses
                  (
                  p_cust_acct_site_id =>x_customer_site_id,
                  p_location   =>in_addr_location,
                  p_site_use_code   =>'BILL_TO',
                  x_site_use_id =>x_site_use_id  ,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_attribute21=>null,
                 c_attribute22=>null,
                 c_attribute23=>null,
                 c_attribute24=>null,
                 c_attribute25=>null
                  );


      if x_return_status in ('E','U') then
        return;
      end if;

      out_bill_to_site_use_id := x_site_use_id;

      -- if location is system generated then we fetch the location number
      -- after creation

      if in_addr_location is null then
        select location
          into out_bill_to_location
          from hz_cust_site_uses_all
          where site_use_id = x_site_use_id;
      else
        out_bill_to_location := in_addr_location;
      end if;
    end if; -- if billto needs to be created


    -- if DELIVERTO needs to be created
    if in_deliver_usage = 'Y' then


      oe_oe_inline_address.Create_Acct_Site_Uses
                  (
                  p_cust_acct_site_id =>x_customer_site_id,
                  p_location   =>in_addr_location,
                  p_site_use_code   =>'DELIVER_TO',
                  x_site_use_id =>x_site_use_id  ,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_attribute21=>null,
                 c_attribute22=>null,
                 c_attribute23=>null,
                 c_attribute24=>null,
                 c_attribute25=>null
                  );



      if x_return_status in ('E','U') then
        return;
      end if;

      out_deliver_to_site_use_id := x_site_use_id;

      -- if location is system generated then we fetch the location number
      -- after creation
      if in_addr_location is null then
        select location
          into out_deliver_to_location
          from hz_cust_site_uses_all
          where site_use_id = x_site_use_id;

      else
        out_deliver_to_location := in_addr_location;
      end if;
    end if; -- if deliver_to needs to be created


    -- if SOLDTO needs to be created
    if in_sold_usage = 'Y' then

      oe_oe_inline_address.Create_Acct_Site_Uses
                  (
                  p_cust_acct_site_id =>x_customer_site_id,
                  p_location   =>in_addr_location,
                  p_site_use_code   =>'SOLD_TO',
                  x_site_use_id =>x_site_use_id  ,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_attribute21=>null,
                 c_attribute22=>null,
                 c_attribute23=>null,
                 c_attribute24=>null,
                 c_attribute25=>null
                  );


      if x_return_status in ('E','U') then
        return;
      end if;

      out_sold_to_site_use_id := x_site_use_id;


      -- if location is system generated then we fetch the location number
      -- after creation
      if in_addr_location is null then
        select location
          into out_sold_to_location
          from hz_cust_site_uses_all
          where site_use_id = x_site_use_id;
      else
        out_sold_to_location := in_addr_location;
      end if;
    end if; -- if soldto location needs to be created




  end if; -- if address1 is not null


  IF in_cont_last_name is not null then

    oe_oe_inline_address.Create_contact
               (p_contact_last_name  =>in_cont_last_name,
                p_contact_first_name =>in_cont_first_name,
                p_contact_title      =>in_cont_title,
                p_email              =>in_cont_email,
                p_area_code          =>null,
                p_phone_number       =>in_cont_phone_number,
                p_extension          =>in_cont_phone_ext,
                p_acct_id            =>x_cust_account_id,
                p_party_id           =>x_party_id,
                x_return_status      =>x_return_status,
                x_msg_count          =>x_msg_count,
                x_msg_data           =>x_msg_data,
                x_contact_id         =>out_cont_id,
                x_contact_name       =>out_cont_name,
                c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_attribute21=>null,
                 c_attribute22=>null,
                 c_attribute23=>null,
                 c_attribute24=>null,
                 c_attribute25=>null,
                 c2_attribute_category=>null,
                 c2_attribute1=>null,
                 c2_attribute2=>null,
                 c2_attribute3=>null,
                 c2_attribute4=>null,
                 c2_attribute5=>null,
                 c2_attribute6=>null,
                 c2_attribute7=>null,
                 c2_attribute8=>null,
                 c2_attribute9=>null,
                 c2_attribute10=>null,
                 c2_attribute11=>null,
                 c2_attribute12=>null,
                 c2_attribute13=>null,
                 c2_attribute14=>null,
                 c2_attribute15=>null,
                 c2_attribute16=>null,
                 c2_attribute17=>null,
                 c2_attribute18=>null,
                 c2_attribute19=>null,
                 c2_attribute20=>null,
                 in_phone_country_code=>in_cont_country_Code
                  );


    if x_return_status in ('E','U') then
      return;
    end if;

    -- this is done in order to match with the concatanation style of the
    -- view oe_contacts_v which is used in the sales order form

    select in_cont_last_name||
        DECODE(in_cont_first_name,NULL,NULL,', '||in_cont_first_name)||
        DECODE(in_cont_title,NULL,NULL,' '||in_cont_title)
      into out_cont_Name
      from dual;

  END IF; -- if contact information is passed

END Add_Customer;


END oe_oe_inline_address;

/
