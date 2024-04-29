--------------------------------------------------------
--  DDL for Package Body FND_PII_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PII_UTILITY_PVT" AS
/* $Header: fndpiutb.pls 120.1 2005/07/02 03:35:25 appldev noship $ */

--  Global constants

--  Pre-defined validation levels
--
G_PKG_NAME   VARCHAR2(100) := 'FND_PII_UTILITY_PVT';

-- get the option for the party for a given business purpose code and attribute
FUNCTION get_purpose_attr_option
(  p_purpose_code	             IN  VARCHAR2 ,
   p_privacy_attribute_code      IN  VARCHAR2 ,
   p_party_id           	     IN  NUMBER
) RETURN VARCHAR2

IS

l_api_name       VARCHAR2(100);
x_return_status  VARCHAR2(1000);
x_msg_count      NUMBER;
x_msg_data       VARCHAR2(1000);

l_ret_value       varchar2(30000);

cursor c_check_attr(l_privacy_attribute_code in varchar2,
                    l_purpose_code           in varchar2)
    is
select purpose_attribute_id
 from  fnd_purpose_attributes
where  purpose_code =  l_purpose_code
  and  privacy_attribute_code = l_privacy_attribute_code;

r_check_attr c_check_attr%rowtype;

cursor c_pref(l_purpose_code in varchar2,
              l_party_id     in varchar2)
is
select  contact_preference_id,
        preference_code
  FROM HZ_CONTACT_PREFERENCES pref
 WHERE pref.CONTACT_LEVEL_TABLE_ID    = l_party_id
   AND pref.CONTACT_LEVEL_TABLE       = 'HZ_PARTIES'
   AND pref.preference_topic_type_code = l_purpose_code  -- this will be l_purpose_code
   AND pref.preference_topic_type     = 'FND_BUSINESS_PURPOSES_B' -- this will be FND_BUSINESS_PURPOSES
   AND pref.contact_type              = 'PRIV_PREF'
   AND status                         = 'A';

r_pref c_pref%rowtype;

cursor c_default(l_purpose_code in varchar2)
    is
select decode(purpose_default_code, 'N', 'I', purpose_default_code) purpose_default_code
  from fnd_business_purposes_b
 where purpose_code = l_purpose_code;

r_default c_default%rowtype;

BEGIN
 x_return_status := fnd_api.g_ret_sts_success;
 l_ret_value     := 'I';
 l_api_name      := 'GET_PURPOSE_OPTION';

if(p_privacy_attribute_code is not null and p_party_id is not null and p_purpose_code is not null)
then
  -- check if the privacy_attribute_code passed in is used for the business_purpose
  open c_check_attr(p_privacy_attribute_code, p_purpose_code);
  fetch c_check_attr into r_check_attr;
  if(c_check_attr%found)
  then
     l_ret_value     := 'O';
  else
     l_ret_value     := 'I';
  end if; -- end of c_check_attr
  close c_check_attr;

  -- attribute found mapped to business purpose then determine the option for the party for this business purpose
  if(l_ret_value = 'I')
  then
      null;
  else
     open c_pref(p_purpose_code,
	             p_party_id);
	 fetch c_pref into r_pref;
	 if(c_pref%found)
	 then
	   if(r_pref.preference_code = 'DO_NOT')
	   then
	       l_ret_value := 'O';
       else
	       l_ret_value := 'I';
       end if;
     else
     -- find the default option for this business purpose
        open c_default(p_purpose_code);
        fetch c_default into r_default;
        l_ret_value := r_default.purpose_default_code;
        close c_default;


	 end if; -- end of c_pref
	 close c_pref;
 end if; -- end of l_ret_value check
end if; -- end of null check for party id, privacy attribute code and purpose code

 return l_ret_value;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('FND', 'FND_PII_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );
END get_purpose_attr_option;


-- get the option for the party for a given attribute . if person is opted out of any one purpose
-- using the attribute then the return value is 'O'  which is opted out.
FUNCTION get_attribute_option
(  p_privacy_attribute_code      IN  VARCHAR2  ,
   p_party_id           	     IN  NUMBER
) RETURN VARCHAR2
IS
l_api_name  VARCHAR2(100) ;
x_return_status  VARCHAR2(1000);
x_msg_count      NUMBER;
x_msg_data       VARCHAR2(1000);

cursor c_purp(l_privacy_attribute_code in varchar2)
    is
select attr.purpose_attribute_id,
       attr.purpose_code,
       purp.purpose_default_code
 from  fnd_purpose_attributes attr,
       fnd_business_purposes_b purp
 where attr.privacy_attribute_code = l_privacy_attribute_code
   and  attr.purpose_code = purp.purpose_code;

r_purp c_purp%rowtype;


cursor c_pref(l_purpose_code in varchar2,
                   l_party_id     in number)
    is
select  pref.contact_preference_id,
        pref.preference_code
  FROM HZ_CONTACT_PREFERENCES pref
 WHERE pref.CONTACT_LEVEL_TABLE_ID    = l_party_id
   AND pref.CONTACT_LEVEL_TABLE       = 'HZ_PARTIES'
   AND pref.preference_topic_type_code = l_purpose_code  -- this will be l_purpose_code
   AND pref.preference_topic_type     = 'FND_BUSINESS_PURPOSES_B' -- this will be FND_BUSINESS_PURPOSES
   AND pref.contact_type              = 'PRIV_PREF'
   AND status                         = 'A' ;



r_pref c_pref%rowtype;


l_ret_value varchar2(10) ;



BEGIN
 x_return_status := fnd_api.g_ret_sts_success;
 l_ret_value     := 'I';
 l_api_name      := 'GET_ATTRIBUTES';

if(p_privacy_attribute_code is not null and p_party_id is not null)
then
   -- get the business purposes that use this attribute
   for r_purp in c_purp(p_privacy_attribute_code)
   loop
      -- if the defualt code is 'I' then check if there are any 'O' records in cont pref.
	  -- if found then set ret value to 'O' . exit with the value
      -- if default value is 'O' then check if there are any 'I' records cont pref
      -- if found then do nothing. else set ret value to 'O' and exit. If exit condition does
	  -- not occur then look at next purpose
	  open c_pref(r_purp.purpose_code, p_party_id);
	  fetch c_pref into r_pref;
      close c_pref;
	  IF(r_purp.purpose_default_code = 'I')
	  THEN
	            if(r_pref.preference_code = 'DO_NOT')
	            then
	               l_ret_value := 'O';
	               exit;
	            end if;
	  ELSIF(r_purp.purpose_default_code = 'O')
	  THEN
	            if(r_pref.preference_code = 'DO')
	            then
	               null;
	            else
	              l_ret_value := 'O';
	              exit;
	            end if;
	   END IF; -- end of r_purp.purpose_defualt_code check

   end loop; -- end of r_purp loop
end if; -- end of p_privacy_attribute_code and p_party_id null check

return l_ret_value;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('FND', 'FND_PII_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );
END get_attribute_option;

-- get the option for the party for a given business purpose code
FUNCTION get_purpose_option
(  p_purpose_code	     IN  VARCHAR2 ,
   p_party_id           	     IN  NUMBER
) RETURN VARCHAR2

IS

l_api_name       VARCHAR2(100);
x_return_status  VARCHAR2(1000);
x_msg_count      NUMBER;
x_msg_data       VARCHAR2(1000);

l_ret_value       varchar2(30000);

cursor c_pref(l_purpose_code in varchar2,
              l_party_id     in varchar2)
is
select  contact_preference_id,
        preference_code
  FROM HZ_CONTACT_PREFERENCES pref
 WHERE pref.CONTACT_LEVEL_TABLE_ID    = l_party_id
   AND pref.CONTACT_LEVEL_TABLE       = 'HZ_PARTIES'
   AND pref.preference_topic_type_code = l_purpose_code  -- this will be l_purpose_code
   AND pref.preference_topic_type     = 'FND_BUSINESS_PURPOSES_B' -- this will be FND_BUSINESS_PURPOSES
   AND pref.contact_type              = 'PRIV_PREF'
   AND status                         = 'A';

r_pref c_pref%rowtype;

cursor c_default(l_purpose_code in varchar2)
    is
select purpose_default_code
  from fnd_business_purposes_b
 where  purpose_code = l_purpose_code;

r_default c_default%rowtype;

BEGIN
 x_return_status := fnd_api.g_ret_sts_success;
 l_ret_value     := 'I';
 l_api_name      := 'GET_PURPOSE__ATTR_OPTION';

if(p_purpose_code is not null and p_party_id is not null)
then
  -- check if party has a option set for the purpose. else return defualt option
     open c_pref(p_purpose_code,
	             p_party_id);
	 fetch c_pref into r_pref;
	 if(c_pref%found)
	 then
	   if(r_pref.preference_code = 'DO_NOT')
	   then
	       l_ret_value := 'O';
       else
	       l_ret_value := 'I';
       end if;
     else
     -- find the default option for this business purpose
        open c_default(p_purpose_code);
        fetch c_default into r_default;
        l_ret_value := r_default.purpose_default_code;
        close c_default;
	 end if; -- end of c_pref
	 close c_pref;
end if; -- end of null check for party id and purpose code

 return l_ret_value;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('FND', 'FND_PII_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );
END get_purpose_option;

END FND_PII_UTILITY_PVT;

/
