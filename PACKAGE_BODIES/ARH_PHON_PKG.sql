--------------------------------------------------------
--  DDL for Package Body ARH_PHON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_PHON_PKG" as
/* $Header: ARHPHONB.pls 120.2 2005/06/16 21:14:19 jhuang ship $*/
--
-- PROCEDURE
--     get_level
--
-- DESCRIPTION
--		This procedure detemermins which level the phone
--		is connected to cust|addr|cont
--
-- SCOPE - PROVATE
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_customer_id
--			p_address_id
--			p_contact_id
--			p_type
--			p_id
--              OUT:
--                    None
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--

  FUNCTION INIT_SWITCH
  ( p_date   IN DATE,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN DATE
  IS
   res_date date;
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_date IS NULL THEN
       res_date := FND_API.G_MISS_DATE;
     ELSE
       res_date := p_date;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_date = FND_API.G_MISS_DATE THEN
       res_date := NULL;
     ELSE
       res_date := p_date;
     END IF;
   ELSE
     res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
   END IF;
   RETURN res_date;
  END;

  FUNCTION INIT_SWITCH
  ( p_char   IN VARCHAR2,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN VARCHAR2
  IS
   res_char varchar2(2000);
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_char IS NULL THEN
       return FND_API.G_MISS_CHAR;
     ELSE
       return p_char;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_char = FND_API.G_MISS_CHAR THEN
       return NULL;
     ELSE
       return p_char;
     END IF;
   ELSE
     return ('INCORRECT_P_SWITCH');
   END IF;
  END;

  FUNCTION INIT_SWITCH
  ( p_num   IN NUMBER,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN NUMBER
  IS
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_num IS NULL THEN
       return FND_API.G_MISS_NUM;
     ELSE
       return p_num;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_num = FND_API.G_MISS_NUM THEN
       return NULL;
     ELSE
       return p_num;
     END IF;
   ELSE
     return ('9999999999');
   END IF;
  END;

  PROCEDURE object_version_select
  (p_table_name                  IN VARCHAR2,
   p_col_id                      IN VARCHAR2,
   x_rowid                       IN OUT NOCOPY ROWID,
   x_object_version_number       IN OUT NOCOPY NUMBER,
   x_last_update_date            IN OUT NOCOPY DATE,
   x_id_value                    IN OUT NOCOPY NUMBER,
   x_return_status               IN OUT NOCOPY VARCHAR2,
   x_msg_count                   IN OUT NOCOPY NUMBER,
   x_msg_data                    IN OUT NOCOPY VARCHAR2 )
  IS
     CURSOR cu_contact_point_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            NULL
       FROM HZ_CONTACT_POINTS
      WHERE CONTACT_POINT_ID = p_col_id;

    l_last_update_date   DATE;

  BEGIN
    IF p_table_name = 'HZ_CONTACT_POINTS' THEN
         OPEN cu_contact_point_version;
         FETCH cu_contact_point_version INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_contact_point_version;
    END IF;

    IF x_rowid IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD',p_table_name);
        FND_MESSAGE.SET_TOKEN('ID',p_col_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
     IF TO_CHAR(x_last_update_date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', p_table_name);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

  END;


procedure get_level(	p_customer_id 	in number,
			p_address_id 	in number,
			p_contact_id 	in number,
			p_type 		out NOCOPY varchar2,
			p_id 		out NOCOPY number ) is
begin
	if ( p_contact_id is not null ) then
		p_type := 'CONT';
		p_id   := p_contact_id;
	elsif (p_address_id is not null ) then
	    	p_type := 'ADDR';
		p_id   := p_address_id;
	else
		p_type := 'CUST';
		p_id   := p_customer_id;
	end if;
	--
end get_level;
--
--
-- PROCEDURE
--
--     check_primary
--
-- DESCRIPTION
--		This procedure ensure that a cust|addr|cont only
--		has one primary telephone.
--
-- SCOPE -
--		PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_phone_id
--			p_type      (CUST|ADDR|CONT)
--			p_id
--              OUT:
--                    None
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
PROCEDURE check_primary(p_phone_id 	in number,
			  p_type	in varchar2,
			  p_id 		in number ) is
  --
  --
  primary_count number;
  --
BEGIN
       --
       if (p_type = 'CUST') then

		select 	count(1)
        	into    primary_count
		from	hz_contact_points cont_point,
                        hz_cust_account_roles car
		where	car.party_id = cont_point.owner_table_id
                and     cont_point.owner_table_name = 'HZ_PARTIES'
                and     cont_point.contact_point_type not
                                    in ('EDI','EMAIL','WEB')
                and     car.cust_account_id = p_id
		and	car.cust_acct_site_id  is null
		and	car.cust_account_role_id  is null
		and  	cont_point.primary_flag = 'Y'
		and     ( (p_phone_id is null)
                         or cont_point.contact_point_id <> p_phone_id );
		--
		if ( primary_count >= 1 ) then
			fnd_message.set_name('AR','AR_CUST_ONE_PRIMARY_PHONE');
			app_exception.raise_exception;
		end if;
		--
	elsif (p_type = 'ADDR' ) then
	--
		select 	count(1)
        	into    primary_count
		from	hz_contact_points cont_point,
                        hz_cust_account_roles car
		where   car.party_id = cont_point.owner_table_id
                and     cont_point.owner_table_name = 'HZ_PARTIES'
                and     cont_point.contact_point_type not
                                in ('EDI','EMAIL','WEB')
                and     car.cust_acct_site_id	= p_id
		and	car.cust_account_role_id is null
		and  	cont_point.primary_flag = 'Y'
		and     ( (p_phone_id is null)
                         or cont_point.contact_point_id <> p_phone_id );
 		--
		if ( primary_count >= 1 ) then
			fnd_message.set_name('AR','AR_CUST_ADDR_ONE_PRIMARY_PHONE');
			app_exception.raise_exception;
		end if;
	elsif (p_type = 'CONT' ) then
	--
		select 	count(1)
        	into    primary_count
                from    hz_contact_points cont_point,
                        hz_cust_account_roles car
                where   car.party_id = cont_point.owner_table_id
                and     cont_point.owner_table_name = 'HZ_PARTIES'
                and     cont_point.contact_point_type not
                                in ('EDI','EMAIL','WEB')
		and	car.cust_account_role_id  	= p_id
		and  	cont_point.primary_flag = 'Y'
		and     ( (p_phone_id is null)
                         or cont_point.contact_point_id <> p_phone_id );
		--
		if ( primary_count >= 1 ) then
			fnd_message.set_name('AR','AR_CUST_CONT_ONE_PRIMARY_PHONE');
			app_exception.raise_exception;
		end if;
	else
		app_exception.invalid_argument('arp_phones_pkg.check_primary','p_type',p_type);

	end if;
	--
END check_primary;
--
--
--
PROCEDURE Insert_Row(
                       X_Phone_Id                IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Country_Code                   VARCHAR2,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       x_party_id                       NUMBER,
                       x_party_site_id                  NUMBER,
                       x_primary_by_purpose             VARCHAR2,
                       x_contact_point_purpose          VARCHAR2,
                       x_email_format                   VARCHAR2,
                       x_email_address                  VARCHAR2,
                       x_url                            VARCHAR2,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2
) IS
  --
  l_type varchar2(4);
  l_id   number(15);
  --
--  email_rec       hz_contact_point_pub.email_rec_type;
--  edi_rec         hz_contact_point_pub.edi_rec_type;
--  phone_rec       hz_contact_point_pub.phone_rec_type;
--  telex_rec       hz_contact_point_pub.telex_rec_type;
--  web_rec         hz_contact_point_pub.web_rec_type;
--  cpoint_rec      hz_contact_point_pub.contact_points_rec_type;
--  cust_point_rec  hz_customer_accounts_pub.cust_contact_pt_rec_type;
  --
  email_rec       hz_contact_point_v2pub.email_rec_type;
  edi_rec         hz_contact_point_v2pub.edi_rec_type;
  phone_rec       hz_contact_point_v2pub.phone_rec_type;
  telex_rec       hz_contact_point_v2pub.telex_rec_type;
  web_rec         hz_contact_point_v2pub.web_rec_type;
  cpoint_rec      hz_contact_point_v2pub.contact_point_rec_type;
  --
  x_cust_acct_profile_amt_id    NUMBER;
  x_owner_table                 VARCHAR2(30);
  x_owner_table_id              NUMBER;
  tmp_var                       VARCHAR2(2000);
  i                             NUMBER;
  tmp_var1                      VARCHAR2(2000);
  x_cust_contact_point_id       NUMBER;
  l_count                       NUMBER;
  --
BEGIN
       --

       -- if (x_primary_flag = 'Y') then
		--
		--
       		get_level(p_customer_id => x_customer_id,
			  p_address_id  => x_address_id,
			  p_contact_id  => x_contact_id,
			  p_type        => l_type,
			  p_id          => l_id);
		--
       		--
       if l_type = 'CUST' then
           x_owner_table := 'HZ_PARTIES';
           x_owner_table_id := x_party_id;
       end if;

       if l_type = 'ADDR' then
           x_owner_table := 'HZ_PARTY_SITES';
           x_owner_table_id := x_party_site_id;
       end if;

       if l_type = 'CONT' then
           x_owner_table := 'HZ_PARTIES';
           x_owner_table_id := x_party_id;
       end if;

       if (x_primary_flag = 'Y') then
       		check_primary(p_phone_id => x_phone_id,
			      p_type  	 => l_type,
			      p_id       => l_id );
		--
       		--
       end if;
  --

      l_count := 1;

      while l_count > 0 loop
           SELECT  hz_contact_points_s.nextval
           INTO    x_phone_id
           FROM    dual;

          select count(*) into l_count from hz_contact_points
          where contact_point_id  = x_phone_id ;

          END LOOP;
  --
  SELECT  hz_cust_contact_points_s.nextval
  into    x_cust_contact_point_id
  from    dual;
  --
  IF ( x_orig_system_reference is null)
  THEN
    x_orig_system_reference := x_phone_id;
  END IF;
  --
  cpoint_rec.contact_point_id       := x_phone_Id;
  cpoint_rec.contact_point_type     := X_Phone_Type;
  cpoint_rec.status                 := x_status;
  cpoint_rec.owner_table_name       := x_owner_table;
  cpoint_rec.owner_table_id         := x_owner_table_id;
  cpoint_rec.primary_flag           := x_primary_flag;
  cpoint_rec.orig_system_reference  := x_orig_system_reference;
  cpoint_rec.attribute_category     := x_attribute_category;
  cpoint_rec.attribute1             := x_attribute1;
  cpoint_rec.attribute2             := x_attribute2;
  cpoint_rec.attribute3             := x_attribute3;
  cpoint_rec.attribute4             := x_attribute4;
  cpoint_rec.attribute5             := x_attribute5;
  cpoint_rec.attribute6             := x_attribute6;
  cpoint_rec.attribute7             := x_attribute7;
  cpoint_rec.attribute8             := x_attribute8;
  cpoint_rec.attribute9             := x_attribute9;
  cpoint_rec.attribute10            := x_attribute10;
  cpoint_rec.attribute11            := x_attribute11;
  cpoint_rec.attribute12            := x_attribute12;
  cpoint_rec.attribute13            := x_attribute13;
  cpoint_rec.attribute14            := x_attribute14;
  cpoint_rec.attribute15            := x_attribute15;
  cpoint_rec.attribute16            := x_attribute16;
  cpoint_rec.attribute17            := x_attribute17;
  cpoint_rec.attribute18            := x_attribute18;
  cpoint_rec.attribute19            := x_attribute19;
  cpoint_rec.attribute20            := x_attribute20;
  cpoint_rec.created_by_module      := 'TCA_FORM_WRAPPER';
  cpoint_rec.contact_point_purpose  := x_contact_point_purpose;
  cpoint_rec.primary_by_purpose     := x_primary_by_purpose;
    IF x_phone_type = 'TLX' THEN
      telex_rec.telex_number       := x_phone_number;
    END IF;

    IF x_phone_type = 'TLX' AND x_area_code IS NOT NULL THEN
      telex_rec.telex_number       := x_area_code ||'-'||x_phone_number;
    END IF;

    IF x_phone_type NOT IN ( 'TLX','EMAIL','WEB') THEN
      phone_rec.phone_line_type     := x_phone_type;
      cpoint_rec.contact_point_type := 'PHONE';
      phone_rec.phone_number        := x_phone_number;
      phone_rec.phone_country_code  := x_country_code;
      phone_rec.phone_area_code     := x_area_code;
      phone_rec.phone_extension     := x_extension;
    END IF;
    IF x_phone_type = 'WEB' THEN
       web_rec.url                  := x_email_address;
       cpoint_rec.contact_point_type := 'WEB';
       web_rec.web_type             :=   'WEB';
    END IF;
    IF x_phone_type = 'EMAIL' THEN
       email_rec.email_format                   := x_email_format;
       email_rec.email_address                  := x_email_address;
       cpoint_rec.contact_point_type            :=  x_phone_type;
    END IF;
    -- call V2 API.
    HZ_CONTACT_POINT_V2PUB.create_contact_point (
        p_contact_point_rec                 => cpoint_rec,
        p_edi_rec                           => edi_rec,
        p_email_rec                         => email_rec,
        p_phone_rec                         => phone_rec,
        p_telex_rec                         => telex_rec,
        p_web_rec                           => web_rec,
        x_contact_point_id                  => x_phone_id,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );


    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> 'S' THEN
      return;
    END IF;

 END Insert_Row;

 PROCEDURE Update_Row(
                       X_Phone_Id                       NUMBER,
                       X_Last_Update_Date          IN OUT     NOCOPY DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Country_code                   VARCHAR2,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       x_cust_contact_point_id          NUMBER,
                       x_primary_by_purpose             VARCHAR2,
                       x_contact_point_purpose          VARCHAR2,
                       x_email_format                   VARCHAR2,
                       x_email_address                  VARCHAR2,
                       x_url                            VARCHAR2,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
                       x_object_version          IN OUT NOCOPY NUMBER

  ) IS

  l_type               VARCHAR2(4);
  l_id                 NUMBER(15);
  email_rec            hz_contact_point_v2pub.email_rec_type;
  edi_rec              hz_contact_point_v2pub.edi_rec_type;
  phone_rec            hz_contact_point_v2pub.phone_rec_type;
  telex_rec            hz_contact_point_v2pub.telex_rec_type;
  web_rec              hz_contact_point_v2pub.web_rec_type;
  cpoint_rec           hz_contact_point_v2pub.contact_point_rec_type;
  tmp_var              VARCHAR2(2000);
  i                    NUMBER;
  tmp_var1             VARCHAR2(2000);
  l_update_date        DATE;
  l_rowid              ROWID;
  l_object_version     NUMBER;
  l_dummy              NUMBER;

 BEGIN
    --
    if (x_primary_flag = 'Y' ) then
		get_level(x_customer_id,x_address_id,x_contact_id,l_type,l_id);
    		--
    		check_primary(x_phone_id,l_type,l_id);
    		--
    end if;
    --
    cpoint_rec.contact_point_id       := x_phone_Id;
    cpoint_rec.status                 := INIT_SWITCH(x_status);
    cpoint_rec.primary_flag           := INIT_SWITCH(x_primary_flag);
    cpoint_rec.attribute_category     := INIT_SWITCH(x_attribute_category);
    cpoint_rec.attribute1             := INIT_SWITCH(x_attribute1);
    cpoint_rec.attribute2             := INIT_SWITCH(x_attribute2);
    cpoint_rec.attribute3             := INIT_SWITCH(x_attribute3);
    cpoint_rec.attribute4             := INIT_SWITCH(x_attribute4);
    cpoint_rec.attribute5             := INIT_SWITCH(x_attribute5);
    cpoint_rec.attribute6             := INIT_SWITCH(x_attribute6);
    cpoint_rec.attribute7             := INIT_SWITCH(x_attribute7);
    cpoint_rec.attribute8             := INIT_SWITCH(x_attribute8);
    cpoint_rec.attribute9             := INIT_SWITCH(x_attribute9);
    cpoint_rec.attribute10            := INIT_SWITCH(x_attribute10);
    cpoint_rec.attribute11            := INIT_SWITCH(x_attribute11);
    cpoint_rec.attribute12            := INIT_SWITCH(x_attribute12);
    cpoint_rec.attribute13            := INIT_SWITCH(x_attribute13);
    cpoint_rec.attribute14            := INIT_SWITCH(x_attribute14);
    cpoint_rec.attribute15            := INIT_SWITCH(x_attribute15);
    cpoint_rec.attribute16            := INIT_SWITCH(x_attribute16);
    cpoint_rec.attribute17            := INIT_SWITCH(x_attribute17);
    cpoint_rec.attribute18            := INIT_SWITCH(x_attribute18);
    cpoint_rec.attribute19            := INIT_SWITCH(x_attribute19);
    cpoint_rec.attribute20            := INIT_SWITCH(x_attribute20);
    cpoint_rec.contact_point_purpose  := INIT_SWITCH(x_contact_point_purpose);
    cpoint_rec.primary_by_purpose     := INIT_SWITCH(x_primary_by_purpose);
    IF x_phone_type = 'TLX' THEN
      telex_rec.telex_number       := INIT_SWITCH(x_phone_number);
    END IF;

    IF    x_phone_type = 'TLX' AND x_area_code IS NOT NULL THEN
        telex_rec.telex_number    := x_area_code ||'-'||x_phone_number;
    ELSE
        telex_rec.telex_number    := INIT_SWITCH(telex_rec.telex_number);
    END IF;

    IF x_phone_type not in ( 'TLX') THEN
      phone_rec.phone_line_type   := INIT_SWITCH(x_phone_type);
--BUG Fix 1870911,Contact_point_type is non-Updateable
--    cpoint_rec.contact_point_type := 'PHONE';
      phone_rec.phone_number      := INIT_SWITCH(x_phone_number);
      phone_rec.phone_country_code:= INIT_SWITCH(x_country_code);
      phone_rec.phone_area_code   := INIT_SWITCH(x_area_code);
      phone_rec.phone_extension   := INIT_SWITCH(x_extension);
    END IF;
    IF x_phone_type = 'WEB' THEN
       web_rec.url                  := INIT_SWITCH(x_email_address);
    END IF;
    IF x_phone_type = 'EMAIL' THEN
       email_rec.email_format                   := INIT_SWITCH(x_email_format);
       email_rec.email_address                  := INIT_SWITCH(x_email_address);
    END IF;
    l_object_version  := x_object_version;
    IF l_object_version = -1 THEN
      object_version_select
       (p_table_name            => 'HZ_CONTACT_POINTS',
        p_col_id                => x_phone_Id,
        x_rowid                 => l_rowid,
        x_object_version_number => l_object_version,
        x_last_update_date      => l_update_date,
        x_id_value              => l_dummy,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data );
    END IF;

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;


     HZ_CONTACT_POINT_V2PUB.update_contact_point (
        p_contact_point_rec                 => cpoint_rec,
        p_edi_rec                           => edi_rec,
        p_email_rec                         => email_rec,
        p_phone_rec                         => phone_rec,
        p_telex_rec                         => telex_rec,
        p_web_rec                           => web_rec,
        p_object_version_number             => l_object_version,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
     );

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       select last_update_date,
              object_version_number
         into X_Last_Update_Date,
              x_object_version
         from hz_contact_points
        where contact_point_id = X_Phone_Id;
    END IF;

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

END Update_Row;

--
-- Overload method for V2 API uptake
--
 PROCEDURE Update_Row(
                       X_Phone_Id                       NUMBER,
                       X_Last_Update_Date          IN OUT     NOCOPY DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Country_code                   VARCHAR2,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       x_cust_contact_point_id          NUMBER,
                       x_primary_by_purpose             VARCHAR2,
                       x_contact_point_purpose          VARCHAR2,
                       x_email_format                   VARCHAR2,
                       x_email_address                  VARCHAR2,
                       x_url                            VARCHAR2,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2
  )
 IS
  l_object_version  NUMBER := -1;
 BEGIN
      Update_Row(      X_Phone_Id      ,
                       X_Last_Update_Date,
                       X_Last_Updated_By,
                       X_Phone_Number  ,
                       X_Status        ,
                       X_Phone_Type    ,
                       X_Last_Update_Login,
                       X_Customer_Id   ,
                       X_Address_Id    ,
                       X_Contact_Id    ,
                       X_Country_code  ,
                       X_Area_Code     ,
                       X_Extension     ,
                       X_Primary_Flag  ,
                       X_Attribute_Category,
                       X_Attribute1    ,
                       X_Attribute2    ,
                       X_Attribute3    ,
                       X_Attribute4    ,
                       X_Attribute5    ,
                       X_Attribute6    ,
                       X_Attribute7    ,
                       X_Attribute8    ,
                       X_Attribute9    ,
                       X_Attribute10   ,
                       X_Attribute11   ,
                       X_Attribute12   ,
                       X_Attribute13   ,
                       X_Attribute14   ,
                       X_Attribute15   ,
                       X_Attribute16   ,
                       X_Attribute17   ,
                       X_Attribute18   ,
                       X_Attribute19   ,
                       X_Attribute20   ,
                       x_cust_contact_point_id,
                       x_primary_by_purpose,
                       x_contact_point_purpose,
                       x_email_format,
                       x_email_address,
                       x_url,
                       x_msg_count     ,
                       x_msg_data      ,
                       x_return_status ,
                       l_object_version );

 END;

-- Overload procedure for collection workbench
-- Fix bug 1694959
PROCEDURE Insert_Row(
                       X_Phone_Id                IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       x_party_id                       NUMBER,
                       x_party_site_id                  NUMBER,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2
) IS

  i_return_status         VARCHAR2(1);
  i_msg_count             NUMBER;
  i_msg_data              VARCHAR2(2000);
  i_Default_Phone_Country_Code	VARCHAR2(30);

BEGIN

  i_Default_Phone_Country_Code := Get_Default_Phone_Country_Code;

  Insert_Row(
    X_Phone_Id
  , X_Last_Update_Date
  , X_Last_Updated_By
  , X_Creation_Date
  , X_Created_By
  , X_Phone_Number
  , X_Status
  , X_Phone_Type
  , X_Last_Update_Login
  , X_Customer_Id
  , X_Address_Id
  , X_Contact_Id
  , i_Default_Phone_Country_Code
  , X_Area_Code
  , X_Extension
  , X_Primary_Flag
  , X_Orig_System_Reference
  , X_Attribute_Category
  , X_Attribute1
  , X_Attribute2
  , X_Attribute3
  , X_Attribute4
  , X_Attribute5
  , X_Attribute6
  , X_Attribute7
  , X_Attribute8
  , X_Attribute9
  , X_Attribute10
  , X_Attribute11
  , X_Attribute12
  , X_Attribute13
  , X_Attribute14
  , X_Attribute15
  , X_Attribute16
  , X_Attribute17
  , X_Attribute18
  , X_Attribute19
  , X_Attribute20
  , x_party_id
  , x_party_site_id
  , 'N'
  , NULL
  , NULL
  , NULL
  , NULL
  , i_msg_count
  , i_msg_data
  , i_return_status
  );

  X_Return_Status := i_return_status;
  X_Msg_Count := i_msg_count;
  X_Msg_Data := i_msg_data;

END Insert_Row;

-- Overload procedure for collection workbench
-- Fix bug 1694959
PROCEDURE Update_Row(
  X_Phone_Id                       NUMBER,
  X_Last_Update_Date    IN OUT     NOCOPY DATE,
  X_Last_Updated_By                NUMBER,
  X_Phone_Number                   VARCHAR2,
  X_Status                         VARCHAR2,
  X_Phone_Type                     VARCHAR2,
  X_Last_Update_Login              NUMBER,
  X_Customer_Id                    NUMBER,
  X_Address_Id                     NUMBER,
  X_Contact_Id                     NUMBER,
  X_Area_Code                      VARCHAR2,
  X_Extension                      VARCHAR2,
  X_Primary_Flag                   VARCHAR2,
  X_Attribute_Category             VARCHAR2,
  X_Attribute1                     VARCHAR2,
  X_Attribute2                     VARCHAR2,
  X_Attribute3                     VARCHAR2,
  X_Attribute4                     VARCHAR2,
  X_Attribute5                     VARCHAR2,
  X_Attribute6                     VARCHAR2,
  X_Attribute7                     VARCHAR2,
  X_Attribute8                     VARCHAR2,
  X_Attribute9                     VARCHAR2,
  X_Attribute10                    VARCHAR2,
  X_Attribute11                    VARCHAR2,
  X_Attribute12                    VARCHAR2,
  X_Attribute13                    VARCHAR2,
  X_Attribute14                    VARCHAR2,
  X_Attribute15                    VARCHAR2,
  X_Attribute16                    VARCHAR2,
  X_Attribute17                    VARCHAR2,
  X_Attribute18                    VARCHAR2,
  X_Attribute19                    VARCHAR2,
  X_Attribute20                    VARCHAR2,
  x_cust_contact_point_id          NUMBER,
  x_msg_count                  OUT NOCOPY NUMBER,
  x_msg_data                   OUT NOCOPY VARCHAR2,
  x_return_status              OUT NOCOPY VARCHAR2

) IS

  i_return_status         VARCHAR2(1);
  i_msg_count             NUMBER;
  i_msg_data              VARCHAR2(2000);
  i_Default_Phone_Country_Code	VARCHAR2(30);

BEGIN

  i_Default_Phone_Country_Code := Get_Default_Phone_Country_Code;

  Update_Row(
    X_Phone_Id
  , X_Last_Update_Date
  , X_Last_Updated_By
  , X_Phone_Number
  , X_Status
  , X_Phone_Type
  , X_Last_Update_Login
  , X_Customer_Id
  , X_Address_Id
  , X_Contact_Id
  , i_Default_Phone_Country_Code
  , X_Area_Code
  , X_Extension
  , X_Primary_Flag
  , X_Attribute_Category
  , X_Attribute1
  , X_Attribute2
  , X_Attribute3
  , X_Attribute4
  , X_Attribute5
  , X_Attribute6
  , X_Attribute7
  , X_Attribute8
  , X_Attribute9
  , X_Attribute10
  , X_Attribute11
  , X_Attribute12
  , X_Attribute13
  , X_Attribute14
  , X_Attribute15
  , X_Attribute16
  , X_Attribute17
  , X_Attribute18
  , X_Attribute19
  , X_Attribute20
  , x_cust_contact_point_id
  , 'N'
  , NULL
  , NULL
  , NULL
  , NULL
  , i_msg_count
  , i_msg_data
  , i_return_status
  );

  X_Return_Status := i_return_status;
  X_Msg_Count := i_msg_count;
  X_Msg_Data := i_msg_data;

END Update_Row;


PROCEDURE Delete_Row(X_phoneid VARCHAR2) IS
BEGIN

    DELETE FROM hz_contact_points
    WHERE contact_point_id = X_phoneid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

END Delete_Row;
--
-- FUNCTION
--     Get_Default_Phone_Country_Code
--
-- DESCRIPTION
--     This function provide a default phone country code
--
-- SCOPE - PROVATE
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--		      None
--              OUT:
--                    None
--
-- RETURNS    :     Default_Phone_Country_Code
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Dylan Wan
--
--
FUNCTION Get_Default_Phone_Country_Code
RETURN VARCHAR2
IS

  l_phone_country_code          VARCHAR2(10);
  l_home_country_code           VARCHAR2(60);
  l_default_country_code        VARCHAR2(60);

BEGIN

  l_home_country_code := arp_standard.sysparm.default_country;
  fnd_profile.get('DEFAULT_COUNTRY',l_default_country_code);

  IF  ( l_default_country_code IS NULL )
  THEN
    l_default_country_code := l_home_country_code;
  END IF;

  SELECT  a.phone_country_code
  INTO    l_phone_country_code
  FROM    hz_phone_country_codes a
  WHERE   a.territory_code = l_default_country_code;

  RETURN l_phone_country_code;

END Get_Default_Phone_Country_Code;

END arh_phon_pkg;

/
