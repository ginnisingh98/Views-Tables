--------------------------------------------------------
--  DDL for Package Body JTF_CUSTOMER_ACCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CUSTOMER_ACCOUNTS_PVT" as
/* $Header: JTFVACTB.pls 120.7 2006/06/09 11:01:31 vimohan ship $ */

  procedure create_account(
    p_api_version  NUMBER,
    p_init_msg_list  VARCHAR2,
    p_commit  VARCHAR2,
    p_party_id NUMBER,
    p_account_number VARCHAR2,
    p_create_amt VARCHAR2,
    p_party_type VARCHAR2,
    x_return_status out NOCOPY VARCHAR2,
    x_msg_count out NOCOPY NUMBER,
    x_msg_data out  NOCOPY VARCHAR2,
    x_cust_account_id out NOCOPY  NUMBER,
    x_cust_account_number out NOCOPY  VARCHAR2,
    x_party_id out NOCOPY  NUMBER,
    x_party_number out  NOCOPY VARCHAR2,
    x_profile_id out  NOCOPY NUMBER,
    p_account_name IN  VARCHAR2:=FND_API.G_MISS_CHAR)
  is

    /*ddp_account_rec      hz_customer_accounts_pub.account_rec_type;
    ddp_person_rec       hz_party_pub.person_rec_type;
    ddp_organization_rec hz_party_pub.organization_rec_type;
    ddp_cust_profile_rec hz_customer_accounts_pub.cust_profile_rec_type;
    */
    ddp_account_rec      hz_cust_account_v2pub.cust_account_rec_type;
    ddp_person_rec       hz_party_v2pub.person_rec_type;
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddp_cust_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;
    l_gen_cust_num       VARCHAR2(1);
    profile_class_value        VARCHAR2(15);
 begin
    -- pass the account_number if auto generation is off
    --dbms_application_info.set_client_info(204);
    /*begin
      SELECT generate_customer_number INTO l_gen_cust_num
        FROM ar_system_parameters;
    exception when no_data_found then
      l_gen_cust_num := 'Y';
    end;*/

 l_gen_cust_num :=  HZ_MO_GLOBAL_CACHE.get_generate_customer_number();

 -- modified to handle the case where l_gen_cust_num is 'D' or 'N' and we have to pass the account_number.
 -- We fetch the next value from the sequence each time and hence multiple accounts can be created for same user.
    IF l_gen_cust_num <> 'Y' THEN
      select HZ_ACCOUNT_NUM_S.nextval into ddp_account_rec.account_number from dual;
    END IF;
      ddp_account_rec.account_name := p_account_name;
      ddp_account_rec.created_by_module := 'JTA_USER_MANAGEMENT';

fnd_profile.get(
      name   => 'JTA_UM_CUST_PROFILE_CLASS',
      val    =>   profile_class_value   );

if profile_class_value IS NOT NULL then
 ddp_cust_profile_rec.profile_class_id := to_number(profile_class_value);
end if;

    if p_party_type = 'P' then
      ddp_person_rec.party_rec.party_id := p_party_id;
      HZ_CUST_ACCOUNT_V2PUB.create_cust_account(
        p_init_msg_list,  ddp_account_rec,   ddp_person_rec,
        ddp_cust_profile_rec, p_create_amt,  x_cust_account_id,
        x_cust_account_number, x_party_id, x_party_number,
        x_profile_id, x_return_status, x_msg_count,
        x_msg_data);
        if(x_return_status <> fnd_api.g_ret_sts_success)
        then
        raise_application_error(-20101,'Failed to create person accountin jtf_cust_account:'||x_msg_data);
        end if;
    else
      ddp_organization_rec.party_rec.party_id := p_party_id;
        HZ_CUST_ACCOUNT_V2PUB.create_cust_account(
        p_init_msg_list, ddp_account_rec, ddp_organization_rec,
        ddp_cust_profile_rec, p_create_amt,    x_cust_account_id,
        x_cust_account_number,x_party_id,x_party_number,
        x_profile_id, x_return_status, x_msg_count,
        x_msg_data);
    if(x_return_status <> fnd_api.g_ret_sts_success)
    then
    raise_application_error(-20101,'Failed to create org accountin jtf_cust_account:'||x_msg_data);
    end if;
    end if;
  end;


END jtf_customer_accounts_pvt;

/
