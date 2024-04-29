--------------------------------------------------------
--  DDL for Package Body ARH_CROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CROL_PKG" as
/* $Header: ARHCROLB.pls 120.2 2005/06/16 21:10:07 jhuang ship $*/

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
     CURSOR cu_role_resp_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            NULL
       FROM HZ_ROLE_RESPONSIBILITY
      WHERE RESPONSIBILITY_ID = p_col_id;

    l_last_update_date   DATE;

  BEGIN
    IF p_table_name = 'HZ_ROLE_RESPONSIBILITY' THEN
         OPEN cu_role_resp_version;
         FETCH cu_role_resp_version INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_role_resp_version;
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


--
--
--
-- PROCEDURE
--     check_unique
--
-- DESCRIPTION
--	Generates error if contact role is not unique
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_contact_role_id
--			- p_contact_id
--			- p_usage_code
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
  PROCEDURE check_unique( p_contact_role_id 	in number,
			  p_contact_id		in number,
			  p_usage_code		in varchar2) is
  --
  unique_count number;
  --
  begin
	select 	count(1)
	into	unique_count
	from	hz_role_responsibility cr
	where	cr.cust_account_role_id = p_contact_id
	and	cr.responsibility_type	= p_usage_code
	and	(( p_contact_role_id is null) or
                  (cr.responsibility_id <> p_contact_role_id));
	--
	if ( unique_count >= 1 ) then
		fnd_message.set_name('AR','AR_CUST_DUP_ROLE_USAGE');
		app_exception.raise_exception;
	end if;
        --
  end check_unique;
  --
  --
--
-- FUNCTION
--
--
-- DESCRIPTION
--	Checks to see if a contact role exists
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_contact_id
--			p_usage_code
--
--              OUT:
--
--
-- RETURNS    : Boolean - TRUE if contact role exists
--			  FALSE if contact role does not exists
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
  FUNCTION contact_role_exists(p_contact_id in number ,p_usage_code in varchar2 ) return Boolean is
  --
  dummy number;
  begin
	--
	select  1
	into	dummy
	from   	hz_role_responsibility
	where  	cust_account_role_id = p_contact_id
	and 	responsibility_type = p_usage_code;
	--
	return TRUE;
  exception
	when NO_DATA_FOUND then
		return FALSE;
  --
  --
  end contact_role_exists;
--
-- PROCEDURE
--     check_primary
--
-- DESCRIPTION
--		A contact may only have one primary role
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_contact_role_id
--			p_contact_id
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
  PROCEDURE check_primary (p_contact_role_id	in number,
			   p_contact_id		in number ) is
  --
  primary_count number;
  --
  begin
	select 	count(1)
	into	primary_count
	from 	hz_role_responsibility cr
	where	cr.cust_account_role_id	= p_contact_id
	and	cr.primary_flag = 'Y'
	and	(( p_contact_role_id is null)
                  or (cr.responsibility_id <> p_contact_role_id));
	--
	if ( primary_count >= 1 ) then
		fnd_message.set_name('AR','AR_CUST_ROLE_PRIMARY');
		app_exception.raise_exception;
	end if;
	--
  end check_primary;
  --
  PROCEDURE Insert_Row(
                       X_Contact_Role_Id         IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       x_org_contact_id                 NUMBER,
                       x_return_status                 out NOCOPY varchar2,
                       x_msg_count                     out NOCOPY number,
                       x_msg_data                      out NOCOPY varchar2

  ) IS

--role_rec       hz_party_pub.org_contact_role_rec_type;
--role_resp_rec  hz_customer_accounts_pub.role_resp_rec_type;

  role_rec          hz_party_contact_v2pub.org_contact_role_rec_type;
  role_resp_rec     hz_cust_account_role_v2pub.role_responsibility_rec_type;
  tmp_var           VARCHAR2(2000);
  i                 NUMBER;
  tmp_var1          VARCHAR2(2000);
  l_count           NUMBER;

 BEGIN
       --
       check_unique(
             p_contact_role_id => x_contact_role_id,
             p_contact_id      => x_contact_id,
             p_usage_code      => x_usage_code
       );
       --
       if (x_primary_flag = 'Y') then
          check_primary(
                 p_contact_role_id => x_contact_role_id,
                 p_contact_id      => x_contact_id
          );
       end if;
       --
      l_count := 1;
      while l_count > 0 loop
         select hz_org_contact_roles_s.nextval into x_contact_role_id from dual;

         select count(*) into l_count from hz_org_contact_roles
         where org_contact_role_id = x_contact_role_id ;

      END LOOP;
       --

   role_rec.org_contact_role_id   := X_Contact_Role_Id;
   role_rec.role_type             := X_Usage_Code;
-- primary flag is ignored (always set to 'N') for org_contact_roles as it is
-- not possible to maintain all such info from role_responsibility.
-- role_responsibility can have multiple combination of primary and usage.
-- this relates to bug - 1348220
   role_rec.primary_flag          := 'N';
   role_rec.org_contact_id        := x_org_contact_id;
   role_rec.orig_system_reference := X_Contact_Role_Id;
   role_rec.created_by_module     := 'TCA_FORM_WRAPPER';

--   role_rec.attribute_category     := x_Attribute_Category;
--   role_rec.attribute1             := x_Attribute1;
--   role_rec.attribute2             := x_Attribute2;
--   role_rec.attribute3             := x_Attribute3;
--   role_rec.attribute4             := x_Attribute4;
--   role_rec.attribute5             := x_Attribute5;
--   role_rec.attribute6             := x_Attribute6;
--   role_rec.attribute7             := x_Attribute7;
--   role_rec.attribute8             := x_attribute8;
--   role_rec.attribute9             := x_Attribute9;
--   role_rec.attribute10            := x_Attribute10;
--   role_rec.attribute11            := x_Attribute11;
--   role_rec.attribute12            := x_Attribute12;
--   role_rec.attribute13            := x_Attribute13;
--   role_rec.attribute14            := x_Attribute14;
--   role_rec.attribute15            := x_Attribute15;
     l_count := 1;

     while l_count > 0 loop
        select hz_role_responsibility_s.nextval into x_contact_role_id from dual;

        select count(*) into l_count from hz_role_responsibility
        where  responsibility_id = x_contact_role_id;

     END LOOP;

   role_resp_rec.responsibility_id     := X_Contact_Role_Id;
   role_resp_rec.cust_account_role_id  := X_Contact_Id;
   role_resp_rec.responsibility_type   := X_Usage_Code;
   role_resp_rec.primary_flag          := X_Primary_Flag;
   role_resp_rec.orig_system_reference := X_Contact_Role_Id;
   role_resp_rec.attribute_category    := x_Attribute_Category;
   role_resp_rec.attribute1            := x_Attribute1;
   role_resp_rec.attribute2            := x_Attribute2;
   role_resp_rec.attribute3            := x_Attribute3;
   role_resp_rec.attribute4            := x_Attribute4;
   role_resp_rec.attribute5            := x_Attribute5;
   role_resp_rec.attribute6            := x_Attribute6;
   role_resp_rec.attribute7            := x_Attribute7;
   role_resp_rec.attribute8            := x_attribute8;
   role_resp_rec.attribute9            := x_Attribute9;
   role_resp_rec.attribute10           := x_Attribute10;
   role_resp_rec.attribute11           := x_Attribute11;
   role_resp_rec.attribute12           := x_Attribute12;
   role_resp_rec.attribute13           := x_Attribute13;
   role_resp_rec.attribute14           := x_Attribute14;
   role_resp_rec.attribute15           := x_Attribute15;
   role_resp_rec.created_by_module     := 'TCA_FORM_WRAPPER';

    -- call V2 API.
    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility (
        p_role_responsibility_rec           => role_resp_rec,
        x_responsibility_id                 => X_Contact_Role_Id,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );

/*
                hz_customer_accounts_pub.create_role_resp(
                1,
                null,
                null,
                role_resp_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                X_Contact_Role_Id);
*/

     IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
     END IF;

  END Insert_Row;
  --
  --

 PROCEDURE Update_Row(
                       X_Contact_Role_Id                NUMBER,
                       X_Last_Update_Date         in out      NOCOPY DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       x_org_contact_id                 NUMBER,
                       x_return_status              out NOCOPY varchar2,
                       x_msg_count                  out NOCOPY number,
                       x_msg_data                   out NOCOPY varchar2,
                       x_object_version          IN OUT NOCOPY NUMBER
 )
 IS
--  role_rec       hz_party_pub.org_contact_role_rec_type;
--  role_resp_rec  hz_customer_accounts_pub.role_resp_rec_type;
  role_rec                      hz_party_contact_v2pub.org_contact_role_rec_type;
  role_resp_rec                 hz_cust_account_role_v2pub.role_responsibility_rec_type;
  tmp_var                       VARCHAR2(2000);
  i                             NUMBER;
  tmp_var1                      VARCHAR2(2000);
  l_rol_res_rowid               ROWID;
  l_rol_res_obj_version         NUMBER;
  l_rol_res_last_upd_date       DATE;
  l_dummy                       NUMBER;

BEGIN
    --
    check_unique( p_contact_role_id => x_contact_role_id,
		  p_contact_id      => x_contact_id,
		  p_usage_code      => x_usage_code);
    --
    if (x_primary_flag = 'Y') then
	check_primary(	p_contact_role_id => x_contact_role_id,
			p_contact_id      => x_contact_id);
    end if;
    --
    role_rec.org_contact_role_id   := X_Contact_Role_Id;
    role_rec.role_type             := INIT_SWITCH(X_Usage_Code);
    role_rec.primary_flag          := INIT_SWITCH(X_Primary_Flag);
    role_rec.org_contact_id        := INIT_SWITCH(x_org_contact_id);

--    role_rec.attribute_category     := x_Attribute_Category;
--    role_rec.attribute1             := x_Attribute1;
--    role_rec.attribute2             := x_Attribute2;
--    role_rec.attribute3             := x_Attribute3;
--    role_rec.attribute4             := x_Attribute4;
--    role_rec.attribute5             := x_Attribute5;
--    role_rec.attribute6             := x_Attribute6;
--    role_rec.attribute7             := x_Attribute7;
--    role_rec.attribute8             := x_attribute8;
--    role_rec.attribute9             := x_Attribute9;
--    role_rec.attribute10            := x_Attribute10;
--    role_rec.attribute11            := x_Attribute11;
--    role_rec.attribute12            := x_Attribute12;
--    role_rec.attribute13            := x_Attribute13;
--    role_rec.attribute14            := x_Attribute14;
--    role_rec.attribute15            := x_Attribute15;


    role_resp_rec.responsibility_id     := X_Contact_Role_Id;
    role_resp_rec.cust_account_role_id  := X_Contact_Id;
    role_resp_rec.responsibility_type   := INIT_SWITCH(X_Usage_Code);
    role_resp_rec.primary_flag          := INIT_SWITCH(X_Primary_Flag);
    role_resp_rec.attribute_category    := INIT_SWITCH(x_Attribute_Category);
    role_resp_rec.attribute1            := INIT_SWITCH(x_Attribute1);
    role_resp_rec.attribute2            := INIT_SWITCH(x_Attribute2);
    role_resp_rec.attribute3            := INIT_SWITCH(x_Attribute3);
    role_resp_rec.attribute4            := INIT_SWITCH(x_Attribute4);
    role_resp_rec.attribute5            := INIT_SWITCH(x_Attribute5);
    role_resp_rec.attribute6            := INIT_SWITCH(x_Attribute6);
    role_resp_rec.attribute7            := INIT_SWITCH(x_Attribute7);
    role_resp_rec.attribute8            := INIT_SWITCH(x_attribute8);
    role_resp_rec.attribute9            := INIT_SWITCH(x_Attribute9);
    role_resp_rec.attribute10           := INIT_SWITCH(x_Attribute10);
    role_resp_rec.attribute11           := INIT_SWITCH(x_Attribute11);
    role_resp_rec.attribute12           := INIT_SWITCH(x_Attribute12);
    role_resp_rec.attribute13           := INIT_SWITCH(x_Attribute13);
    role_resp_rec.attribute14           := INIT_SWITCH(x_Attribute14);
    role_resp_rec.attribute15           := INIT_SWITCH(x_Attribute15);

    l_rol_res_obj_version        := x_object_version;
    IF l_rol_res_obj_version  = -1 THEN
     object_version_select
       (p_table_name             => 'HZ_ROLE_RESPONSIBILITY',
        p_col_id                 => X_Contact_Role_Id,
        x_rowid                  => l_rol_res_rowid,
        x_object_version_number  => l_rol_res_obj_version,
        x_last_update_date       => l_rol_res_last_upd_date,
        x_id_value               => l_dummy,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data );

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

    END IF;

    -- call V2 API.
    HZ_CUST_ACCOUNT_ROLE_V2PUB.update_role_responsibility (
        p_role_responsibility_rec           => role_resp_rec,
        p_object_version_number             => l_rol_res_obj_version,
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

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
     END IF;


/*
                hz_customer_accounts_pub.update_role_resp(
                1,
                null,
                null,
                role_resp_rec,
                X_Last_Update_Date,
                x_return_status,
                x_msg_count,
                x_msg_data);
*/


   select last_update_date,
          object_version_number
     into X_Last_Update_Date,
          x_object_version
     from hz_role_responsibility
    where responsibility_id = X_Contact_Role_Id;

  END Update_Row;

  --
  --Overload method for V2API uptake
  --
  PROCEDURE Update_Row(
                       X_Contact_Role_Id                NUMBER,
                       X_Last_Update_Date         in out      NOCOPY DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       x_org_contact_id                 NUMBER,
                       x_return_status              out NOCOPY varchar2,
                       x_msg_count                  out NOCOPY number,
                       x_msg_data                   out NOCOPY varchar2
 )
 IS
  l_object_version  NUMBER := -1;
 BEGIN
    Update_Row(
                       X_Contact_Role_Id,
                       X_Last_Update_Date,
                       X_Last_Updated_By,
                       X_Usage_Code    ,
                       X_Contact_Id    ,
                       X_Last_Update_Login,
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
                       x_org_contact_id,
                       x_return_status ,
                       x_msg_count     ,
                       x_msg_data      ,
                       l_object_version );
  END;





  --
  --
  PROCEDURE delete_row(x_contact_id in number ,x_usage_code in varchar2) is
  BEGIN
	delete from hz_role_responsibility
	where  cust_account_role_id	= x_contact_id
	and    responsibility_type = x_usage_code;

	-- The exception NO_DATE_FOUND is intentionally not raised
	-- This procedure is called from the arp_contacts_pkg.update_row
	-- the row for deletion may not exist.  Not raising the exception
	-- means we do not have to check for existence before delete.
	-- Do NOT call this procedure form a forms on-delete trigger.
	--
	-- if (SQL%NOTFOUND) then
	--	raise NO_DATA_FOUND;
	--
	--end if;
  END delete_row;
  --
  --
  --
  PROCEDURE Delete_Row(X_contact_role_id number) IS
  BEGIN
    DELETE FROM hz_role_responsibility
    WHERE responsibility_id  = X_contact_role_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END arh_crol_pkg;

/
