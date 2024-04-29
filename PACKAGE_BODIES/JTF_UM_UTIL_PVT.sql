--------------------------------------------------------
--  DDL for Package Body JTF_UM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_UTIL_PVT" as
/* $Header: JTFVUUTB.pls 120.8 2006/02/14 00:16:14 snellepa ship $ */

  MODULE_NAME  CONSTANT VARCHAR2(50) := 'JTF.UM.PLSQL.JTF_UM_UTIL_PVT';
  l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME);

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_UM_UTIL_PVT';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'JTFVUUTB.pls';

  G_USER_ID  NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

/**
 * Procedure   :  validate_Email
 * Type        :  Private
 * Pre_reqs    :
 * Description : this returns true if p_actual_email is the email that is to be used.
 * Parameters  :
 * input parameters
 *   p_requested_email - the email address at which the user wants to receive email
 *   p_actual_email    - the email address at which workflow can send the email
 * output parameters
 *  true if  p_requested_email = p_actual_email or p_requested_email is NULL
 *
 * Errors      :
 * Other Comments :
 */
function validate_email(p_requested_email in varchar2,
                        p_actual_email    in varchar2) return boolean is
begin
  if p_requested_email is not NULL and p_actual_email is not NULL
    and upper(p_requested_email) = upper(p_actual_email) then
       return true;
  elsif p_requested_email is NULL and p_actual_email is not NULL then
       return true;
  else
       return false;
  end if;
end validate_email;




/**
 * Procedure   :  get_user_name
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns the user given the email address
 * Parameters  : None
 * input parameters
 *    param  requester_email          - email address the requester would like to use.
 *  (*) required fields
 * output parameters
 *     param  x_user
 *     param  x_email
 *     param  x_wf_user_name
 *     param  x_return_status
  * Errors      : Expected Errors
 *               requester_user_name and email is null
 *               requester_user_name is not a valid user
 *               requester_email does not correspond to a valid user
 * Other Comments :
 * DEFAULTING LOGIC
 *
 * 1. User_name from fnd_user where email_address = p_requester_email_Address
 * 2. User_name from fnd_user where employee_id = person_id (retrieved from
 *    per_all_people_f using the email_address)
 * 3. User_name from fnd_user where customer_id = hz_contact_points.owner_type_id
 *    and owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL'
 *    and contact_point = p_requester_email_Address
 *
 * In all the above cases the user, employee, party etc. have to be valid.
 *
 * The same logic is used to validate the requester_email.
 */
procedure get_user_name(p_requester_email         in varchar2,
                    x_user_name                   out NOCOPY varchar2,
                    x_email                       out NOCOPY varchar2,
                    x_wf_user_name                out NOCOPY varchar2,
                    x_return_Status               out NOCOPY varchar2) is
 cursor c_user is

   -- from fnd tables
   select user_name
   from fnd_user
   where upper(email_address) = p_requester_email
   and (nvl(end_date, sysdate + 1) > sysdate or
   to_char(END_DATE) = to_char(FND_API.G_MISS_DATE))


   union

   -- from HR tables
   select fnd.user_name
   from fnd_user fnd, per_all_people_f per
   where per.person_id = fnd.employee_id
   and per.effective_end_date > sysdate
   and (nvl(fnd.end_date, sysdate+1) > sysdate or
        to_char(fnd.END_DATE) = to_char(FND_API.G_MISS_DATE))
   and upper(per.email_address) = p_requester_email

   union

   -- from TCA tables
    select fnd.user_name
    from hz_contact_points hcp, fnd_user fnd
    where hcp.owner_table_id = fnd.customer_id
    and hcp.owner_table_name = 'HZ_PARTIES'
    and hcp.contact_point_type = 'EMAIL'
    and upper(hcp.email_address) = p_requester_email;


cursor c_wf_user(l_user_name in varchar2, l_email in varchar2) is
   select name
   from wf_users
   where name = l_user_name
   and upper(email_address) = l_email;

-- local variables

  l_party_id   pls_integer;
  l_party_type varchar2(200);
  l_wf_user_name varchar2(200);
  user_count   pls_integer := 0;  -- keeps track of number of users with same email
begin

  -- initialize return parameters
  x_email         := p_requester_email;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_requester_email is not NULL then
    for i in C_user loop
      x_user_name := i.user_name;
      user_count := user_count + 1;
    end loop;
  end if;

  l_wf_user_name  := x_user_name;

     if x_user_name is NULL then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTA_UM_NO_USER');
          FND_MESSAGE.Set_TOKEN('0', p_requester_email, FALSE);
          FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
     end if;

     if user_count > 1 then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTA_UM_MULTIPLE_USER');
          --FND_MESSAGE.Set_TOKEN('0', p_requester_email, FALSE);
          FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
     end if;

    -- check if this user is a valid user in wf_user
    if x_user_name is not NULL and l_wf_user_name is not NULL then
      open c_wf_user(l_wf_user_name, p_requester_email);
      fetch c_wf_user into x_wf_user_name;
      close c_wf_user;
    end if;

end get_user_name;



/**
 * Procedure   :  get_email
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns the email of the user given the user
 *               name. If a email address is passed as an input parameter it
 *               checks to see if the email address is a valid one.
 * Parameters  : None
 * input parameters
 *     param  requester_user_name (*)  - user name of the requester
 *     param  requester_email          - email address the requester would like to use.
 *  (*) required fields
 * output parameters
 *     param  x_email
 *     param  x_wf_user_name
 *     param  x_return_status
  * Errors      : Expected Errors
 *               requester_user_name and email is null
 *               requester_user_name is not a valid user
 *               requester_email does not correspond to a valid user
 * Other Comments :
 * DEFAULTING LOGIC
 * If only the user name is passed then the email is defaulted using the following logic
 *  1. Email address from fnd_users where user_name = p_requester_user_name
 *  2. Email from per_all_people_F where person_id = employee_id
 *     (retrieved from fnd_users using the user_name)
 *  3. Email from hz_contact_points where owner_type_id = party_id and
 *     owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL'.
 *  Party_id here is obtained from the customer id stored in fnd_user where
 *  user_name = p_requester_user_name.
 *  In all the above cases the user, employee, party etc. have to be valid.
 *
 * The same logic is used to validate the requester_email.
 */
procedure get_email(p_requester_user_name         in varchar2,
                    p_requester_email             in varchar2 := null,
                    x_user                        out NOCOPY varchar2,
                    x_email                       out NOCOPY varchar2,
                    x_wf_user_name                out NOCOPY varchar2,
                    x_return_Status               out NOCOPY varchar2) is

cursor c_user(l_user_name in varchar2) is
  select email_address, customer_id, employee_id
  from fnd_user
  where user_name = l_user_name
  and (nvl(end_date, sysdate + 1) > sysdate or
           to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));

cursor c_employee(p_employee_id in number) is
  select email_address
  from per_all_people_f
  where person_id = p_employee_id
  and effective_end_date > sysdate;
/*
cursor c_customer(p_customer_id in number) is
  select hzp.party_type
  from hz_parties hzp
  where hzp.party_id  = p_customer_id;


cursor c_subject(p_customer_id in number) is
  select subject_id
  from hz_party_relationships
  where party_id = p_customer_id
  and party_relationship_type = 'EMPLOYEE_OF'
  and nvl(end_date, sysdate+1) > sysdate;
*/
cursor c_contact_point(p_party_id in number) is
  select EMAIL_ADDRESS
  from hz_contact_points
  where owner_table_id = p_party_id
  and owner_table_name = 'HZ_PARTIES'
  and contact_point_type = 'EMAIL';

cursor c_wf_user(l_user_name in varchar2, l_email in varchar2) is
  select name
  from wf_users
  where name = l_user_name
  and email_address = l_email;

-- local variables
  l_employee_id pls_integer;
  l_customer_id pls_integer;
  l_party_id    pls_integer;
  l_party_type  varchar2(200);
  l_wf_user_name     varchar2(200);

begin

  -- initialize return parameters
  x_user          := p_requester_user_name;
  -- wf_user_name is different only if we find the email address in hz
  l_wf_user_name  := p_requester_user_name;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_requester_user_name is not NULL then
    -- check to see if email available in fnd_user
    open c_user(p_requester_user_name);
    fetch c_user into x_email, l_customer_id, l_employee_id;
    if (c_user%NOTFOUND) then
      close c_user;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('JTF', 'JTA_UM_INVALID_USER');
         FND_MESSAGE.Set_TOKEN('0', p_requester_user_name, FALSE);
         FND_MSG_PUB.ADD;
       END IF;
       x_user := NULL;
       RAISE FND_API.G_EXC_ERROR;
    end if;
    close c_user;

    -- validate the input email.
    if not validate_email(p_requester_email, x_email) then
      x_email := null;
    end if;

    -- if email is still null check if it can be found in per_all_people_F
    if x_email is null and l_employee_id is not NULL then
      open c_employee(l_employee_id);
      fetch c_employee into x_email;
      close c_employee;

      -- validate the input email.
      if not validate_email(p_requester_email, x_email) then
        x_email := null;
      end if;
    end if;

    -- if email is still null check if the email is available in TCA
    if  x_email is null and l_customer_id is not NULL then
  /*     open c_customer(l_customer_id);
       fetch c_customer into l_party_type;
       close c_customer;

       if l_party_type = 'PERSON' or l_party_type = 'ORGANIZATION' then
          l_party_id := l_customer_id;
       elsif l_party_type =  'PARTY_RELATIONSHIP' then
          open c_subject(l_customer_id);
          fetch c_subject into l_party_id;
          close c_subject;
       end if;
 */

         open  c_contact_point(l_customer_id);
         fetch c_contact_point into x_email;
         close c_contact_point;

       -- validate the input email.
       if not validate_email(p_requester_email, x_email) then
         x_email := null;
       end if;

       -- set the wf_user_name
       l_wf_user_name := 'HZ_PARTY:'||l_party_id;
    end if;

    -- if x_email is null raise an error
       if x_email is NULL then
         if p_requester_email is NULL then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTA_UM_NO_EMAIL');
              --FND_MESSAGE.Set_TOKEN('USER', x_user, FALSE);
              FND_MESSAGE.Set_TOKEN('0', x_user, FALSE);
              FND_MSG_PUB.ADD;
           END IF;
         else
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTA_UM_INVALID_USER_EMAIL');
              FND_MESSAGE.Set_TOKEN('0', x_user, FALSE);
              FND_MESSAGE.Set_TOKEN('1', p_requester_email, FALSE);
              --FND_MESSAGE.Set_TOKEN('USER', x_user, FALSE);
              --FND_MESSAGE.Set_TOKEN('EMAIL', p_requester_email, FALSE);
              FND_MSG_PUB.ADD;
           END IF;
         end if;
         RAISE FND_API.G_EXC_ERROR;
       end if;

    -- check to see if wf_user has this user name
    -- the reason for this check - a valid user, email combination may still
    -- not exist in wf_user and if not checked the email will be sent to the
    -- wrong email address.

    if x_email is not NULL and l_wf_user_name is not NULL then
      open c_wf_user(l_wf_user_name, x_email);
      fetch c_wf_user into x_wf_user_name;
      close c_wf_user;
    end if;
  end if;
end get_email;

/**
 * Procedure   :  get_user_name
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns the user given the email address
 * Parameters  : None
 * input parameters
 *    param  requester_email          - email address the requester would like to use.
 *  (*) required fields
 * output parameters
 *     param  x_user
 *     param  x_email
 *     param  x_wf_user_name
 *     param  x_return_status
  * Errors      : Expected Errors
 *               requester_user_name and email is null
 *               requester_user_name is not a valid user
 *               requester_email does not correspond to a valid user
 * Other Comments :
 * DEFAULTING LOGIC
 *
 * 1. User_name from fnd_user where email_address = p_requester_email_Address
 * 2. User_name from fnd_user where employee_id = person_id (retrieved from
 *    per_all_people_f using the email_address)
 * 3. User_name from fnd_user where customer_id = hz_contact_points.owner_type_id
 *    and owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL'
 *    and contact_point = p_requester_email_Address
 *
 * In all the above cases the user, employee, party etc. have to be valid.
 *
 * The same logic is used to validate the requester_email.
 */
/* -- new get_user_name validates if there are multiple users with the same email address


procedure get_user_name(p_requester_email         in varchar2,
                    x_user_name                   out NOCOPY varchar2,
                    x_email                       out NOCOPY varchar2,
                    x_wf_user_name                out NOCOPY varchar2,
                    x_return_Status               out NOCOPY varchar2) is
  cursor c_user is
   select user_name
   from fnd_user
   where upper(email_address) = p_requester_email
   and (nvl(end_date, sysdate + 1) > sysdate or
        to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));

  cursor c_employee is
   select fnd.user_name
   from fnd_user fnd, per_all_people_f per
   where per.person_id = fnd.employee_id
   and per.effective_end_date > sysdate
   and (nvl(fnd.end_date, sysdate+1) > sysdate or
            to_char(fnd.END_DATE) = to_char(FND_API.G_MISS_DATE))
   and upper(per.email_address) = p_requester_email;

  cursor c_party is
    select fnd.user_name
    from hz_contact_points hcp, fnd_user fnd
    where hcp.owner_table_id = fnd.customer_id
    and hcp.owner_table_name = 'HZ_PARTIES'
    and hcp.contact_point_type = 'EMAIL'
    and upper(hcp.email_address) = p_requester_email;

 cursor c_user1(l_party_id in number) is
   select user_name
   from fnd_user
   where customer_id = l_party_id
   and (nvl(end_date, sysdate+1) > sysdate or
          to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));

   cursor c_wf_user(l_user_name in varchar2, l_email in varchar2) is
   select name
   from wf_users
   where name = l_user_name
   and upper(email_address) = l_email;

-- local variables

  l_party_id   pls_integer;
  l_party_type varchar2(200);
  l_wf_user_name varchar2(200);
begin

  -- initialize return parameters
  x_email         := p_requester_email;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_requester_email is not NULL then

    -- get the user name from fnd_user
    open c_user;
    fetch c_user into x_user_name;
    close c_user;

    if x_user_name is null then
      -- try to get the user by checking if there is an employee with the
      -- given email address
      open c_employee;
      fetch c_employee into x_user_name;
      close c_employee;
    end if;

    l_wf_user_name  := x_user_name;

    if x_user_name is null then
      -- try to get the name from the email in hz_parties
      open c_party;
      fetch c_party into x_user_name;
      close c_party;

      l_wf_user_name := 'HZ_PARTY:'||l_party_id;

    end if;

     if x_user_name is NULL then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTA_UM_NO_USER');
          FND_MESSAGE.Set_TOKEN('0', p_requester_email, FALSE);
          FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
     end if;

    -- check if this user is a valid user in wf_user
    if x_user_name is not NULL and l_wf_user_name is not NULL then
      open c_wf_user(l_wf_user_name, p_requester_email);
      fetch c_wf_user into x_wf_user_name;
      close c_wf_user;
    end if;
  end if;
end get_user_name;
*/


/**
 * Procedure   :  get_wf_user
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns the user name, email and wf_user_name of a given user.
 *               If a email address is passed as an input parameter it
 *               checks to see if the email address is a valid one.
 *               If x_user or x_email is NULL then a valid email /user could
 *               not be found
 *               If x_wf_user is NULL, and x_user and x_email are not NULL then
 *               the user /email combination is valid but does not have a valid
 *               user in wf_user.
 * Parameters  : None
 * input parameters
 *     param  x_requester_user_name (*)  - user name of the requester
 *     param  x_requester_email          - email address the requester would like to use.
 *  (*) required fields
 * output parameters
 *     param  x_requester_user_name
 *     param  x_requester_email
 *     param  x_wf_user_name
 *     param  x_return_status
 * Errors      : Expected Errors
 *               requester_user_name and email is null
 *               requester_user_name is not a valid user
 *               requester_email does not correspond to a valid user
 * Other Comments :
 * DEFAULTING LOGIC
 * If only the user name is passed then the email is defaulted using the following logic
 *  1. Email address from fnd_users where user_name = x_requester_user_name
 *  2. Email from per_all_people_F where person_id = employee_id
 *     (retrieved from fnd_users using the user_name)
 *  3. Email from hz_contact_points where owner_type_id = party_id
 *     and owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL'.
 *  Party_id here is obtained from the customer id stored in fnd_user where
 *  user_name = x_requester_user_name.
 *  In all the above cases the user, employee, party etc. have to be valid.
 *
 * If only the email address is specified, the user name is determined using a similar logic
 * 1. User_name from fnd_user where email_address = x_requester_email_Address
 * 2. User_name from fnd_user where employee_id = person_id (retrieved from
 *    per_all_people_f using the email_address)
 * 3. User_name from fnd_user where customer_id = hz_contact_points.owner_type_id
 *    and owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL'
 *    and contact_point = x_requester_email_Address
 *
 */
procedure get_wf_user(p_api_version_number  in number,
                 p_init_msg_list            in varchar2 := FND_API.G_FALSE,
                 p_commit                   in varchar2 := FND_API.G_FALSE,
                 p_validation_level         in number   := FND_API.G_VALID_LEVEL_FULL,
                 x_requester_user_name      in out NOCOPY varchar2,
                 x_requester_email          in out NOCOPY varchar2,
                 x_wf_user                  out NOCOPY varchar2,
                 x_return_status            out NOCOPY varchar2,
                 x_msg_count                out NOCOPY number,
                 x_msg_data                 out NOCOPY varchar2
                 ) is

  l_api_version_number  NUMBER := 1.0;
  l_api_name            VARCHAR2(50) := 'GET_WF_USER';
  l_email               varchar2(240);
  l_requester_user_name varchar2(240) := upper(x_requester_user_name);
  l_requester_email     varchar2(240) := upper(x_requester_email);
  l_wf_user_name        varchar2(240);
  l_password            varchar2(240);

/*
  cursor c_update_email(l_user_name in varchar2) is
    select email_address
    from fnd_user
    where user_name = l_user_name;
*/

begin

    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Entering API send_Password ...');
    --

    -- Standard Start of API savepoint
    SAVEPOINT get_wf_user;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    -- Validate required fields for not null values

        if (x_requester_user_name is null and x_requester_email is null) then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_REQUIRED_FIELD');
            --FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME, FALSE);
            FND_MESSAGE.Set_Token('API_NAME', 'resetting the password', FALSE);
            FND_MESSAGE.Set_Token('FIELD', 'USER_NAME, EMAIL', FALSE);
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        end if;


      -- default the email address if user name is not NULL
      -- the email should be picked up from FND_USER, PER_PEOPLE_F or TCA

      if (l_requester_user_name is not null) then
        get_email(p_requester_user_name   => l_requester_user_name,
                    p_requester_email     => l_requester_email,
                    x_user                => x_requester_user_name,
                    x_email               => x_requester_email,
                    x_wf_user_name        => x_wf_user,
                    x_return_Status       => x_return_status);
      end if;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE FND_API.G_EXC_ERROR;
      end if;

      -- default the user if email is not NULL

      if (l_requester_user_name is NULL and l_requester_email is not null) then
        get_user_name(p_requester_email  => l_requester_email,
                    x_user_name          => x_requester_user_name,
                    x_email              => x_requester_email,
                    x_wf_user_name       => x_wf_user,
                    x_return_Status      => x_return_status);
      end if;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE FND_API.G_EXC_ERROR;
      end if;

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data  => x_msg_data);

        -- Write to debug log
        -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Exiting API send_Password ...');
        --

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN OTHERS THEN
          JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
end get_wf_user;

  /**
   * Procedure   :  GetAdHocUser
   * Type        :  Private
   * Pre_reqs    :  WF_DIRECTORY.CreateAdHocUser and
   *                WF_DIRECTORY.SetAdHocUserAttr
   * Description :  This API tries to create an adhoc user with the provided
   *                username.  If the username is already being used in the
   *                database, just update input attributes.
   * Parameters  :
   * input parameters
   * @param
   *   p_username
   *     description:  The adhoc username.
   *     required   :  Y
   *   p_display_name
   *     description:  The adhoc display name.
   *     required   :  N
   *     default    :  null
   *   p_language
   *     description:  The value of the database NLS_LANGUAGE initialization
   *                   parameter that specifies the default language-dependent
   *                   behavior of the user's notification session. If null,
   *                   the procedure resolves this to the language setting of
   *                   your current session.
   *     required   :  N
   *     default    :  null
   *   p_territory
   *     description:  The value of the database NLS_TERRITORY initialization
   *                   parameter that specifies the default territory-dependant
   *                   date and numeric formatting used in the user's
   *                   notification session. If null, the procedure resolves
   *                   this to the territory setting of your current session.
   *     required   :  N
   *     default    :  null
   *   p_description
   *     description:  Description for the user.
   *     required   :  N
   *     default    :  null
   *   p_notification_preference
   *     description:  Indicate how this user prefers to receive notifications:
   *                   'MAILTEXT', 'MAILHTML', 'MAILATTH', 'QUERY' or 'SUMMARY'.
   *                   If null, the procedure sets the notification preference
   *                   to 'MAILHTML'.
   *     required   :  N
   *     default    :  'MAILTEXT'
   *   p_email_address
   *     description:  Electronic mail address for this user.
   *     required   :  Y
   *   p_fax
   *     description:  Fax number for the user
   *     required   :  N
   *     default    :  null
   *   p_status
   *     description:  The availability of the user to participate in a
   *                   workflow process. The possible statuses are 'ACTIVE',
   *                   'EXTLEAVE', 'INACTIVE', and 'TMPLEAVE'. If null, the
   *                   procedure sets the status to 'ACTIVE'.
   *     required   :  N
   *     default    :  'ACTIVE'
   *   p_expiration_date
   *     description:  The date at which the user is no longer valid in the
   *                   directory service. If null, the procedure defaults the
   *                   expiration date to sysdate.
   *     required   :  N
   *     default    :  sysdate
   * output parameters
   * @return
   * Errors :
   * Other Comments :
   */
  PROCEDURE GetAdHocUser (p_api_version_number      in number,
                          p_init_msg_list           in varchar2 default FND_API.G_FALSE,
                          p_commit                  in varchar2 default FND_API.G_FALSE,
                          p_validation_level        in number   default FND_API.G_VALID_LEVEL_FULL,
                          p_username                in varchar2,
                          p_display_name            in varchar2 default null,
                          p_language                in varchar2 default null,
                          p_territory               in varchar2 default null,
                          p_description             in varchar2 default null,
                          p_notification_preference in varchar2 default 'MAILTEXT',
                          p_email_address           in varchar2,
                          p_fax                     in varchar2 default null,
                          p_status                  in varchar2 default 'ACTIVE',
                          p_expiration_date         in date default sysdate,
                          x_return_status           out NOCOPY varchar2,
                          x_msg_data                out NOCOPY varchar2,
                          x_msg_count               out NOCOPY varchar2) is

  l_api_version_number NUMBER         := 1.0;
  l_api_name           VARCHAR2 (50)  := 'GetAdHocUser';
  l_username           VARCHAR2 (100) := p_username;
  l_display_name       VARCHAR2 (100);
  duplicated_user      EXCEPTION;
  PRAGMA EXCEPTION_INIT (duplicated_user, -20002);

  BEGIN
    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Entering API send_Password ...');

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call the user hook if it is a public api. Private APIs do not require a user hook call.

    -- Standard Start of API savepoint
    SAVEPOINT GetAdHocUser;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Beginning of API body
    --
    -- Validate required fields
    IF (p_username is null) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTA_UM_EMAIL_MISS_USERNAME');
        FND_MESSAGE.Set_Token('0', 'GetAdHocUser', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_email_address is null) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTA_UM_EMAIL_MISS_EMAIL');
        FND_MESSAGE.Set_Token('0', 'GetAdHocUser', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_display_name is null) THEN
      l_display_name := p_username;
    ELSE
      l_display_name := p_display_name;
    END IF;

    BEGIN
      WF_DIRECTORY.CreateAdHocUser (l_username,
                                    l_display_name,
                                    p_language,
                                    p_territory,
                                    p_description,
                                    p_notification_preference,
                                    p_email_address,
                                    p_fax,
                                    p_status,
                                    p_expiration_date);
    EXCEPTION
      WHEN duplicated_user THEN
        WF_DIRECTORY.SetAdHocUserAttr (p_username,
                                       p_display_name,
                                       p_notification_preference,
                                       p_language,
                                       p_territory,
                                       p_email_address,
                                       p_fax);
    END;

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                               p_data  => x_msg_data);

    -- call the user hook if it is a public api. Private APIs do not require a user hook call.

    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Exiting API send_Password ...');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

  END GetAdHocUser;

  /**
   * Procedure   :  LAUNCH_WORKFLOW
   * Type        :  Private
   * Pre_reqs    :  WF_ENGINE.CREATEPROCESS, WF_ENGINE.SETITEMATTRTEXT, and
   *                WF_ENGINE.STARTPROCESS.
   * Description :  Create and Start workflow process
   * Parameters  :
   * input parameters
   * @param
   *   p_username
   *     description:  FND user's username.  The recipient of the notification.
   *     required   :  N
   *     validation :  Must be a valid FND User.
   *     default    :  null
   *   p_subject
   *     description:  The subject of the notification.
   *     required   :  Y
   *   p_text_body
   *     description:  Text version of the notification body.
   *     required   :  Y
   *   p_HTML_body
   *     description:  HTML version of the notification body.
   *     required   :  N
   *     default    :  null
   * output parameters
   * @return
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  PROCEDURE LAUNCH_WORKFLOW (p_username  in varchar2,
                             p_subject   in varchar2,
                             p_text_body in varchar2,
                             p_HTML_body in varchar2 default null) is

  cursor get_next_itemkey is
    select JTF_UM_EMAIL_NOTIFICATION_S.NEXTVAL
    from dual;

  l_itemtype VARCHAR2 (8) := 'JTAUMEMN';
  l_itemkey  NUMBER;

  BEGIN

    OPEN get_next_itemkey;
    FETCH get_next_itemkey INTO l_itemkey;
    CLOSE get_next_itemkey;

    -- Call the Workflow API to send the notification.
    WF_ENGINE.CREATEPROCESS (itemtype   => l_itemtype,
                             itemkey    => l_itemkey,
                             process    => 'SEND_EMAIL_NOTIFICATION',
                             owner_role => FND_GLOBAL.USER_NAME);

    -- Set Workflow Item Attributes.
    WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'RECIPIENT_USERNAME', p_username);
    WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'SUBJECT', p_subject);
    WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'TEXT_BODY', p_text_body);

    IF (p_HTML_body is null) THEN
      -- The Notification Preference is HTML but p_HTML_body is null, we need
      -- to add <pre> and </pre> into the text body.  This way, it will
      -- preserve the format of the text mail in the browser when reading.
      WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'HTML_BODY', '<pre>' || p_text_body || '</pre>');
    ELSE
      WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'HTML_BODY', p_HTML_body);
    END IF;

    WF_ENGINE.STARTPROCESS (l_itemtype, l_itemkey);
  END LAUNCH_WORKFLOW;

  /**
   * Procedure   :  EMAIL_NOTIFICATION
   * Type        :  Private
   * Pre_reqs    :  WF_NOTIFICATION.Send, WF_ENGINE.SetItemAttrText
   * Description :  Send email notification to user with a username or/and
   *                email provided as input parameters.
   * Parameters  :
   * input parameters
   * @param
   *   p_username
   *     description:  FND user's username.  The recipient of the notification.
   *     required   :  N
   *     validation :  Must be a valid FND User.
   *     default    :  null
   *   p_email_address
   *     description:  Send to this email.
   *     required   :  N
   *     default    :  null
   *   p_subject
   *     description:  The subject of the notification.
   *     required   :  Y
   *   p_text_body
   *     description:  Text version of the notification body.
   *     required   :  Y
   *   p_HTML_body
   *     description:  HTML version of the notification body.
   *l    required   :  N
   *     default    :  null
   * output parameters
   * @return
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  PROCEDURE EMAIL_NOTIFICATION (p_api_version_number in number,
                                p_init_msg_list      in varchar2 default FND_API.G_FALSE,
                                p_commit             in varchar2 default FND_API.G_FALSE,
                                p_validation_level   in number   default FND_API.G_VALID_LEVEL_FULL,
                                p_username           in varchar2 default null,
                                p_email_address      in varchar2 default null,
                                p_subject            in varchar2,
                                p_text_body          in varchar2,
                                p_HTML_body          in varchar2 default null,
                                x_return_status      out NOCOPY varchar2,
                                x_msg_data           out NOCOPY varchar2,
                                x_msg_count          out NOCOPY varchar2) is

  l_api_version_number NUMBER        := 1.0;
  l_api_name           VARCHAR2 (50) := 'EMAIL_NOTIFICATION';
  l_username           VARCHAR2 (100) := p_username;
  l_adhoc_username     VARCHAR2 (100) := 'JTFUM-';
  l_wf_username        VARCHAR2 (360);
  l_email_address      VARCHAR2 (2000) := p_email_address;
  l_error_msg          VARCHAR2 (20);

  BEGIN
    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Entering API send_Password ...');

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call the user hook if it is a public api. Private APIs do not require a user hook call.

    -- Standard Start of API savepoint
    SAVEPOINT EMAIL_NOTIFICATION;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Beginning of API body
    --
    -- Validate required fields for not null values

    -- Both username and email_address cannot be null.
    IF (p_username is null) AND (p_email_address is null) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTA_UM_EMAIL_MISS_USER_EMAIL');
        FND_MESSAGE.Set_Token('0', 'EmailNotification', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_subject is null) OR (p_text_body is null) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTA_UM_REQUIRED_FIELD');
        FND_MESSAGE.Set_Token('API_NAME', 'UM Send Notification', FALSE);
        IF (p_subject is null) THEN
          l_error_msg := 'p_subject';
        END IF;
        IF (p_text_body is null) THEN
          IF (p_subject is null) THEN
            l_error_msg := l_error_msg || ', ';
          END IF;
          l_error_msg := l_error_msg || 'p_text_body';
        END IF;
        FND_MESSAGE.Set_Token('FIELD', l_error_msg, FALSE);
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Call GET_WF_USER to get the username, email, and username in the
    -- wf_user table.
    GET_WF_USER (p_api_version_number  => 1.0,
                 x_requester_user_name => l_username,
                 x_requester_email     => l_email_address,
                 x_wf_user             => l_wf_username,
                 x_return_status       => x_return_status,
                 x_msg_count           => x_msg_count,
                 x_msg_data            => x_msg_data);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_wf_username is null) THEN
      -- We need to send out workflow twice.  One to the l_username and
      -- the other to the adhoc user.  So that the user would receive both
      -- email and notification.

      -- First, we need to create an adhoc user.
      -- Just take the first 94 characters then in case the username is too
      -- long to add the 'JTFUM-' prefix.
      l_adhoc_username := l_adhoc_username || SUBSTR (l_username, 1, 94);

      GetAdHocUser (p_api_version_number => 1.0,
                    p_username           => l_adhoc_username,
                    p_email_address      => l_email_address,
                    x_return_status      => x_return_status,
                    x_msg_data           => x_msg_data,
                    x_msg_count          => x_msg_count);

      LAUNCH_WORKFLOW (l_adhoc_username, p_subject, p_text_body, p_HTML_body);

    END IF;

    LAUNCH_WORKFLOW (l_username, p_subject, p_text_body, p_HTML_body);

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                               p_data  => x_msg_data);

    -- call the user hook if it is a public api. Private APIs do not require a user hook call.

    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Exiting API send_Password ...');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

  end EMAIL_NOTIFICATION;



    /*
    ** GET_SPECIFIC - Get a profile value for a specific user/resp/appl.
    **                Does not go up the hierarchy to retrieve the profile
    **                values if input values are null.
    */
    procedure GET_SPECIFIC(name_z              in varchar2,
                           user_id_z           in number    default null,
                           responsibility_id_z in number    default null,
                           resp_appl_id_z      in number    default null,
                           application_id_z    in number    default null,
                           site_id_z           in boolean    default false,
                           val_z               out NOCOPY varchar2,
                           defined_z           out NOCOPY boolean) is
      pid number;
      aid number;
      l_name_z varchar2(240) := UPPER(name_z);

      --
      -- this cursor fetches profile information that will
      -- allow subsequent fetches to be more efficient
      --
      cursor profile_info is
        select profile_option_id,
               application_id
        from   fnd_profile_options
        where  profile_option_name = l_name_z
        and    start_date_active  <= sysdate
        and    nvl(end_date_active, sysdate) >= sysdate;

      --
      -- this cursor fetches profile option values for site, application,
      -- and user levels (10001/10002/10004)
      --
      cursor value_uas(pid number, aid number, lid number, lval number) is
        select profile_option_value
        from   fnd_profile_option_values
        where  profile_option_id = pid
        and    application_id    = aid
        and    level_id          = lid
        and    level_value       = lval;

      --
      -- this cursor fetches profile option values at the responsibility
      -- level (10003)
      --
      cursor value_resp(pid number, aid number, lval number, laid number) is
        select profile_option_value
        from   fnd_profile_option_values
        where  profile_option_id = pid
        and    application_id = aid
        and    level_id = 10003
        and    level_value = lval
        and    level_value_application_id = laid
        ;

    begin
      val_z     := NULL;
      defined_z := FALSE;

      open  profile_info;
        fetch profile_info into pid, aid;
        if (profile_info%NOTFOUND) then
          return;
        end if;
      close profile_info;

      -- USER level --
      if user_id_z is not NULL then
        for c1 in value_uas(pid, aid, 10004, user_id_z) loop
          defined_z := TRUE;
          val_z := c1.profile_option_value;
          return;
        end loop;
      end if;

      -- RESPONSIBILITY level --
      if responsibility_id_z is not NULL then
        for c1 in value_resp(pid, aid,
                           responsibility_id_z,
                           resp_appl_id_z) loop
          defined_z := TRUE;
          val_z := c1.profile_option_value;
          return;
        end loop;
      end if;

      -- APPLICATION level --
      if application_id_z is not NULL then
        for c1 in value_uas(pid, aid, 10002,
                           application_id_z) loop
          defined_z := TRUE;
          val_z := c1.profile_option_value;
          return;
        end loop;
      end if;

      -- SITE level --
      if site_id_z  then
        for c1 in value_uas(pid, aid, 10001, 0) loop
          defined_z := TRUE;
          val_z := c1.profile_option_value;
          return;
        end loop;
      end if;
    end GET_SPECIFIC;



/*
    ** VALUE_SPECIFIC - Get profile value for a specific user/resp/appl combo
    **
    */
    function VALUE_SPECIFIC(NAME              in varchar2,
                            USER_ID           in number default null,
                            RESPONSIBILITY_ID in number default null,
                            RESP_APPL_ID      in number default null,
                            APPLICATION_ID    in number default null,
                            SITE_LEVEL        in boolean default false)
    return varchar2 is
        RETVALUE varchar2(255);
	DEFINED boolean;
    begin
        GET_SPECIFIC(NAME, USER_ID, RESPONSIBILITY_ID, RESP_APPL_ID, APPLICATION_ID,
                     SITE_LEVEL, RETVALUE, DEFINED);
	if (DEFINED) then
            return (RETVALUE);
   	else
	    return(NULL);
	end if;
    end VALUE_SPECIFIC;


/**
 * This procedure gets the default appl and resp id using the following logic
 *
 * If appl id and resp id are null - get the user value of the profiles
 * JTF_PROFILE_DEFAULT_RESPONSIBILITY, JTF_PROFILE_DEFAULT_APPLICATION. These
 * values can be set to 'Pending appr' if user requires approval.
 * In this case we use the resp of the usertype the user has registered to.
 * these values could still be null if the user was registered from fnd.
 *
 */

 procedure getDefaultAppRespId (P_USERNAME  IN VARCHAR2,
                                P_RESP_ID   IN NUMBER := null,
                                P_APPL_ID   IN NUMBER := null,
                                X_RESP_ID   out NOCOPY NUMBER,
                                X_APPL_ID   out NOCOPY NUMBER) is
 l_user_id  number;

 -- determine the application from the responsibility
 cursor C_appl_id(p_resp_id in number) is
   select application_id from fnd_responsibility
   where responsibility_id = p_resp_id;

 -- determine the userid given the username
 cursor C_user_id(p_username in varchar2) is
   select user_id from fnd_user
   where user_name = p_username;

 -- determine whether or not the resp id corresponds to "jtf_pending_approval"
 cursor C_is_pending_resp(p_resp_id in number, p_appl_id in number) is
   select responsibility_id from fnd_responsibility
   where application_id = 690
   and responsibility_key = 'JTF_PENDING_APPROVAL';

-- select default responsibility for the usertype
  cursor c_default_resp(p_user_id in number) is
    select fnd.responsibility_id, fnd.application_id
    from jtf_um_usertype_reg reg,
         jtf_um_usertype_resp resp,
         fnd_responsibility fnd
    where reg.user_id = p_user_id
    and   reg.usertype_id = resp.usertype_id
    and   resp.responsibility_key = fnd.responsibility_key
    and   resp.application_id     = fnd.application_id;

-- using hardcoded value
 l_pending_appr_resp_id number := null;

 begin
   -- initialize return parameters
   x_resp_id := p_resp_id;
   x_appl_id := p_appl_id;

   if P_RESP_ID is NULL and P_APPL_ID is NULL then

      if p_username is not NULL then
         open  C_user_id(p_username);
         fetch C_user_id into l_user_id;
         close C_user_id;
      end if;

      if l_user_id is not NULL then
        x_resp_id := value_specific(name=>'JTF_PROFILE_DEFAULT_RESPONSIBILITY',
                                    user_id => l_user_id);

        x_appl_id := value_specific(name => 'JTF_PROFILE_DEFAULT_APPLICATION',
                                    user_id => l_user_id);

        -- if user is created from fnd or if the responsibility is pending
        -- approval then we check for default responsibility of the usertype

        if (x_resp_id is not null and x_appl_id is not null) then
          open C_is_pending_resp (x_resp_id, x_appl_id);
          fetch C_is_pending_resp into l_pending_appr_resp_id;
          close C_is_pending_resp;
        end if;

        if x_resp_id is NULL or x_resp_id = l_pending_appr_resp_id then
           open  C_default_Resp(l_user_id);
           fetch C_default_resp into x_resp_id, x_appl_id;
           close C_default_Resp;
        end if;
      end if;

   elsif p_resp_id is not null and p_appl_id is NULL then

      open  C_appl_id(p_resp_id);
      fetch C_appl_id into x_appl_id;
      close C_appl_id;

   end if;

 end getDefaultAppRespId;

/*
 * Name        :  VALIDATE_USER_ID
 * Pre_reqs    :  None
 * Description :  Will validate the user_id
 * Parameters  :
 * input parameters
 * @param
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This is a package private helper function.
 */

function VALIDATE_USER_ID(p_user_id number) return boolean is

cursor find_user_id is select user_id from fnd_user where
user_id = p_user_id and (nvl(end_date, sysdate+1) > sysdate or
             to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));

l_procedure_name CONSTANT varchar2(30) := 'VALIDATE_USER_ID';
l_dummy_value number;

begin
JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_user_id:' || p_user_id
                                    );
  end if;

open find_user_id;
fetch find_user_id into l_dummy_value;

 if find_user_id%NOTFOUND then
   close find_user_id;
    return false;
 else
   close find_user_id;
    return true;

end if;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


end VALIDATE_USER_ID;


/*
 * Name        :  VALIDATE_SUBSCRIPTION_ID
 * Pre_reqs    :  None
 * Description :  Will validate the subscription_id
 * Parameters  :
 * input parameters
 * @param
 *   p_subscription_id:
 *     description:  The subscription_id of the subscription
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This is a package private helper function.
 */

function VALIDATE_SUBSCRIPTION_ID(p_subscription_id number) return boolean is

l_procedure_name CONSTANT varchar2(30) := 'VALIDATE_SUBSCRIPTION_ID';
cursor find_subscription_id is select subscription_id from jtf_um_subscriptions_b where
subscription_id = p_subscription_id and nvl(effective_end_date, sysdate+1) > sysdate;

l_dummy_value number;

begin

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_id:' || p_subscription_id
                                    );
  end if;


open find_subscription_id;
fetch find_subscription_id into l_dummy_value;

 if find_subscription_id%NOTFOUND then
   close find_subscription_id;
    return false;
 else
   close find_subscription_id;
    return true;

end if;
JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


end VALIDATE_SUBSCRIPTION_ID;

/*
 * Name        : check_role
 * Pre_reqs    :  None
 * Description :  Will determine if a user has a specific role or not
 * Parameters  :
 * input parameters
 * @param     p_user_id
 *    description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id
 * @param     p_auth_principal_id
 *    description:  The jtf_auth_principal_id of a role
 *     required   :  Y
 *     validation :  Must be a valid jtf_auth_principal_id
 *
 * Note:
 *
 *   This API will raise an exception if a user name or a jtf_auth_principal_id
 *   is invalid
 */

function check_role(
                     p_user_id                  in number,
                     p_auth_principal_id        in number
                    ) return boolean IS

l_procedure_name CONSTANT varchar2(30) := 'check_role';
CURSOR VALIDATE_ROLE IS SELECT JTF_AUTH_PRINCIPAL_ID FROM JTF_AUTH_PRINCIPALS_B
WHERE JTF_AUTH_PRINCIPAL_ID = p_auth_principal_id AND IS_USER_FLAG = 0;

CURSOR CHECK_ROLE_ASSIGNMENT IS SELECT  JTF_AUTH_PRINCIPAL_MAPPING_ID FROM JTF_AUTH_PRINCIPAL_MAPS
WHERE JTF_AUTH_PARENT_PRINCIPAL_ID = p_auth_principal_id
AND JTF_AUTH_PRINCIPAL_ID IN
(SELECT JTF_AUTH_PRINCIPAL_ID FROM JTF_AUTH_PRINCIPALS_B ROLE, FND_USER FU
WHERE FU.USER_NAME = ROLE.PRINCIPAL_NAME AND FU.USER_ID = p_user_id);

l_role_id number;
l_dummy number;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_user_id:' || p_user_id || '+' || 'p_auth_principal_id:' || p_auth_principal_id
                                    );
  end if;


 IF NOT VALIDATE_USER_ID(p_user_id) THEN
 JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('user_id')
                            );

 RAISE_APPLICATION_ERROR(-20000, JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('user_id'));
 END IF;

 OPEN VALIDATE_ROLE;
 FETCH VALIDATE_ROLE INTO l_role_id;

 IF VALIDATE_ROLE%NOTFOUND THEN
 CLOSE VALIDATE_ROLE;
 JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('role_id')
                            );

 RAISE_APPLICATION_ERROR(-20000, JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('role_id'));
 END IF;

 OPEN CHECK_ROLE_ASSIGNMENT;
 FETCH CHECK_ROLE_ASSIGNMENT INTO l_dummy;

   IF CHECK_ROLE_ASSIGNMENT%FOUND THEN

     CLOSE CHECK_ROLE_ASSIGNMENT;
     RETURN TRUE;

   ELSE

    CLOSE CHECK_ROLE_ASSIGNMENT;
    RETURN FALSE;

   END IF;

END check_role;

/*
 * Name        : check_role
 * Pre_reqs    :  None
 * Description :  Will determine if a user has a specific role or not
 * Parameters  :
 * input parameters
 * @param     p_user_id
 *    description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id
 * @param     p_principal_name
 *    description:  The principal_name of a role
 *     required   :  Y
 *     validation :  Must be a valid principal_name
 *
 * Note:
 *
 *   This API will raise an exception if a user name or a principal_name
 *   is invalid
 */

function check_role(
                     p_user_id                  in number,
                     p_principal_name           in varchar2
                    ) return boolean IS

l_procedure_name CONSTANT varchar2(30) := 'check_role';
CURSOR VALIDATE_ROLE_NAME IS SELECT JTF_AUTH_PRINCIPAL_ID FROM JTF_AUTH_PRINCIPALS_B
WHERE PRINCIPAL_NAME = p_principal_name AND IS_USER_FLAG = 0;

l_role_id number;

BEGIN
JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_user_id:' || p_user_id || '+' || 'p_principal_name:' || p_principal_name
                                    );
end if;


 OPEN VALIDATE_ROLE_NAME;
 FETCH VALIDATE_ROLE_NAME INTO l_role_id;

 IF VALIDATE_ROLE_NAME%NOTFOUND THEN
 CLOSE VALIDATE_ROLE_NAME;
 JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('role_name')
                            );

RAISE_APPLICATION_ERROR(-20000, JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('role_name'));
 END IF;

     return check_role(
                     p_user_id            => p_user_id,
                     p_auth_principal_id  =>   l_role_id
                );

  JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END check_role;


/**
 * Procedure   :  grant_roles
 * Type        :  Private
 * Pre_reqs    :  None
 * Description :  Will grant roles to users
 * Parameters  :
 * input parameters
 *   p_user_name:
 *     description:  The user_name of the user
 *     required   :  Y
 *     validation :  Must be a valid user_name
 *   p_role_id
 *     description: The value of the JTF_AUTH_PRINCIPAL_ID
 *     required   :  Y
 *     validation :  Must exist as a JTF_AUTH_PRONCIPAL_ID
 *                   in the table JTF_AUTH_PRINCIPALS_B
 *   p_source_name
 *     description: The value of the name of the source
 *     required   :  Y
 *     validation :  Must be "USERTYPE" or "ENROLLMENT"
 *   p_source_id
 *     description: The value of the id associated with the source
 *     required   :  Y
 *     validation :  Must be a usertype_id or a subscription_id
 * output parameters
 * None
 */
procedure grant_roles (
                       p_user_name          in varchar2,
                       p_role_id            in number,
                       p_source_name         in varchar2,
                       p_source_id         in varchar2
                     ) IS

l_procedure_name CONSTANT varchar2(30) := 'grant_roles';
CURSOR FIND_ROLE_NAME IS SELECT PRINCIPAL_NAME FROM JTF_AUTH_PRINCIPALS_B
WHERE JTF_AUTH_PRINCIPAL_ID = p_role_id;
l_role_name JTF_AUTH_PRINCIPALS_B.PRINCIPAL_NAME%TYPE;

BEGIN
JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_user_name:' || p_user_name || '+'  || 'p_role_id:' || p_role_id || '+' || 'p_source_name:' || p_source_name || '+'  || 'p_source_id:' || p_source_id
                                    );
end if;


OPEN FIND_ROLE_NAME;
FETCH FIND_ROLE_NAME INTO l_role_name;
CLOSE FIND_ROLE_NAME;

  IF l_role_name IS NOT NULL THEN

     JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => p_user_name,
                       ROLE_NAME       => l_role_name,
                       OWNERTABLE_NAME => p_source_name,
                       OWNERTABLE_KEY  => p_source_id
                     );

  END IF;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END grant_roles;


/*
 * Name        :  GET_USER_ID
 * Pre_reqs    :  None
 * Description :  Will get user id from username
 * Parameters  :
 * input parameters
 * @param
 *   p_user_name:
 *     description:  The user_name of a user
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *        This function will return null, if it can not find username
 *
 */

function GET_USER_ID(p_user_name varchar2) return NUMBER IS

l_procedure_name CONSTANT varchar2(30) := 'GET_USER_ID';

CURSOR GET_ID IS SELECT USER_ID FROM FND_USER WHERE USER_NAME = p_user_name;
l_user_id NUMBER;

BEGIN

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_user_name:' || p_user_name
                               );
  end if;

   OPEN GET_ID;
   FETCH GET_ID INTO l_user_id;
   CLOSE GET_ID;

   JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
   return l_user_id;

END GET_USER_ID;


/*
 * Name        :  GET_USERTYPE_ID
 * Pre_reqs    :  None
 * Description :  Will get user type id for a user
 * Parameters  :
 * input parameters
 * @param
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *        This function will return null, if it can not find username
 *
 */

function GET_USERTYPE_ID(p_user_id NUMBER) return NUMBER IS

l_procedure_name CONSTANT varchar2(30) := 'GET_USERTYPE_ID';

CURSOR GET_ID IS SELECT USERTYPE_ID FROM JTF_UM_USERTYPE_REG
WHERE USER_ID = p_user_id
AND   NVL(EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND   EFFECTIVE_START_DATE < SYSDATE;

l_usertype_id NUMBER;

BEGIN

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_user_id:' || p_user_id
                               );
  end if;

   OPEN GET_ID;
   FETCH GET_ID INTO l_usertype_id;
   CLOSE GET_ID;

   JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
   return l_usertype_id;

END GET_USERTYPE_ID;

function CHECK_PARTY_TYPE(p_party_id NUMBER) return VARCHAR2
is
 l_party_type HZ_PARTIES.party_type%type;

 CURSOR c_party_type
 is
 SELECT hzp.party_type
 FROM hz_parties hzp
 WHERE hzp.party_id = p_party_id;
BEGIN

 OPEN c_party_type;
 FETCH c_party_type INTO l_party_type;
 CLOSE c_party_type;

 return l_party_type;
END CHECK_PARTY_TYPE;

/*
Wrapper for FND_USER_PKG.validate_user_name, which is a procedure and raises an
exception. We require this wrapper as we dont know whether the exception is due
to invalid username or something other exception .We check the sqlcode and accordingly
process.We cannot have a boolean function as we cannot access it from the JDBC layer.

Code Changes for 5033237/5033238, the errMsg from FND_MESSAGE Stack is being re-used.
*/

function validate_user_name(username varchar2, errMsg out NOCOPY varchar2) return number

is


begin
	 fnd_user_pkg.validate_user_name(username);
	 return 1;
exception
when others then
	 IF sqlcode = -20001 then
		errMsg := FND_MESSAGE.get;
		return 0;
	 else
		raise_application_error(-20001,sqlerrm);
	end if;

end validate_user_name;

function validate_user_name_in_use(username varchar2) return number
is
 x_return_status pls_integer;
begin
	 x_return_status := fnd_user_pkg.TestUserName (x_user_name => username);

	 IF  x_return_status = fnd_user_pkg.USER_OK_CREATE then
		return 1;
	 Else
		return 0;
	 End if;

end validate_user_name_in_use;


/* function to get the constant FND_API.G_MISS_DATE and use it in sql*/
FUNCTION GET_G_MISS_DATE return DATE
is
BEGIN
	return FND_API.G_MISS_DATE;

END GET_G_MISS_DATE;




/*
bug 4903775 - for name formatting based on region territory
*/


function format_user_name(fname varchar2, lname varchar2) return varchar
is

l_return_status varchar2(100);
l_msg_count number;
l_msg_data varchar2(100);
l_person_name varchar(100);
l_formatted_name varchar2(100);
l_formatted_lines_cnt number;
l_formatted_name_tbl HZ_FORMAT_PUB.string_tbl_type;
l_nls_territory varchar2(30);
l_territory_code varchar2(30);

begin
	 fnd_profile.get(
      name   => 'ICX_TERRITORY',
      val    => l_nls_territory
    );



    select territory_code into l_territory_code
    from fnd_territories
    where nls_territory = l_nls_territory
    and OBSOLETE_FLAG = 'N'
    and rownum = 1;


    hz_format_pub.format_name (
          -- input parameters
          -- context info

          p_ref_territory_code          => l_territory_code,
          -- name info
          p_person_first_name           => fname,
          p_person_last_name            => lname,

	  -- output parameters
          x_return_status               => l_return_status,
          x_msg_count                   => l_msg_count,
          x_msg_data                    => l_msg_data,
          x_formatted_name              => l_person_name,
          x_formatted_lines_cnt         => l_formatted_lines_cnt,
          x_formatted_name_tbl          => l_formatted_name_tbl
        );

      return l_person_name;

exception
when others then

 if l_is_debug_parameter_on then
 JTF_DEBUG_PUB.LOG_DEBUG(2, MODULE_NAME, sqlerrm);
 end if;
 l_person_name := fname || ' ' || lname;
 return l_person_name;


end format_user_name;

end JTF_UM_UTIL_PVT;

/
