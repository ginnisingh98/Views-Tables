--------------------------------------------------------
--  DDL for Package Body POS_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PROFILE_PKG" as
/*$Header: POSPRUTB.pls 120.9.12000000.2 2007/09/07 19:52:17 pkapoor ship $ */

g_log_module_name VARCHAR2(30) := 'pos.plsql.POSPRUTB';

/* This procedure gets the vendor information from the notification id.
 *
 */

PROCEDURE get_vendor_data (
  p_ntf_id IN NUMBER
, x_vendor_id out nocopy NUMBER
, x_party_id out nocopy NUMBER
, x_vendor_name out nocopy VARCHAR2
, x_vendor_number out nocopy VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_vendor_id number;

cursor l_vendor_cur is
select vendor_id, vendor_name, party_id, segment1 from ap_suppliers
where vendor_id = l_vendor_id;
l_vendor_rec l_vendor_cur%ROWTYPE;

BEGIN

l_vendor_id := POS_URL_PKG.get_ntf_vendor_id (p_ntf_id);

for l_vendor_rec in l_vendor_cur loop

        x_vendor_id := l_vendor_rec.vendor_id;
        x_vendor_name :=l_vendor_rec.vendor_name;
        x_vendor_number := l_vendor_rec.segment1;
        x_party_id := l_vendor_rec.party_id;

end loop;

if x_vendor_id is null then
        x_status := 'E';
        x_vendor_id := -1;
        return;
end if;

x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      x_vendor_id := -1;
      x_party_id := -1;
      X_STATUS  :='E';
END get_vendor_data;

PROCEDURE buyer_boot_strap
  ( p_user_id	    IN  NUMBER
  , x_status        OUT nocopy VARCHAR2
  , x_exception_msg OUT nocopy VARCHAR2
    )
  IS

  l_employee_id      FND_USER.EMPLOYEE_ID%TYPE;
  l_user_party_id    HZ_PARTIES.PARTY_ID%TYPE;
  l_enterprise_id    HZ_PARTIES.PARTY_ID%TYPE;
  l_relationship_id  HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
  l_step             NUMBER;
  l_username         FND_USER.USER_NAME%TYPE;
  l_email_address    FND_USER.EMAIL_ADDRESS%TYPE;

BEGIN
    x_status := 'E';
    l_step := 0;

    select employee_id, user_name,email_address into
      l_employee_id, l_username, l_email_address
      from fnd_user
      where user_id = p_user_id;

    l_step := 1;

    if l_employee_id is not null then

       l_step := 2;

       l_enterprise_id := POS_PARTY_MANAGEMENT_PKG.check_for_enterprise_user(l_username);

       l_step := 3;

       if l_enterprise_id <> -1 then
	  l_step := 4;
	  x_status := 'S';
        else
	  l_step := 5;
	  POS_ENTERPRISE_UTIL_PKG.pos_create_enterprise_user
	    (l_username
	     ,'First'
	     ,'Last'
	     ,l_email_address
	     ,l_user_party_id
	     ,l_relationship_id
	     ,x_exception_msg
	     ,x_status);
	  x_status := 'S';
	  l_step := 6;
       end if;
     else
       l_step := 7;
       x_status := 'E';
    end if;

EXCEPTION
   WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20029, x_exception_msg, true);

END buyer_boot_strap;

FUNCTION get_update_date_from_contact (
  p_contact_id IN NUMBER
) RETURN DATE
IS
  l_date DATE;
BEGIN
  SELECT last_update_date
  INTO l_date
  FROM hz_contact_points
  WHERE contact_point_id = p_contact_id;
  return l_date;
END get_update_date_from_contact;

FUNCTION phone_exist(
  p_party_id	IN NUMBER
, p_owner_table_name	IN VARCHAR2
, p_contact_point_type	IN VARCHAR2
, p_phone_line_type	IN VARCHAR2
) RETURN BOOLEAN
IS
  l_count	NUMBER;
BEGIN
       SELECT count(contact_point_id)
       INTO l_count
       FROM hz_contact_points hcp
       WHERE hcp.owner_table_name = owner_table_name
       AND   hcp.owner_table_id = p_party_id
       AND   hcp.contact_point_type = p_contact_point_type
       AND   hcp.phone_line_type = p_phone_line_type
       AND   hcp.status = 'A' ;
  IF l_count = 1 then
    return TRUE;
  ELSE
    return FALSE;
  END IF;
END phone_exist;

FUNCTION web_exist(
  p_party_id	IN NUMBER
, p_owner_table_name	IN VARCHAR2
, p_contact_point_type	IN VARCHAR2
, p_web_type	IN VARCHAR2
) RETURN BOOLEAN
IS
  l_count	NUMBER;
BEGIN
  IF (p_contact_point_type='EMAIL') then
       SELECT count(contact_point_id)
       INTO l_count
       FROM hz_contact_points hcp
       WHERE hcp.owner_table_name = p_owner_table_name
       AND   hcp.owner_table_id = p_party_id
       AND   hcp.contact_point_type = p_contact_point_type
       AND   hcp.primary_flag = 'Y'
       AND   hcp.status = 'A';
  ELSE
       SELECT count(contact_point_id)
       INTO l_count
       FROM hz_contact_points hcp
       WHERE hcp.owner_table_name = p_owner_table_name
       AND   hcp.owner_table_id = p_party_id
       AND   hcp.contact_point_type = p_contact_point_type
       AND   hcp.web_type = p_web_type
       AND   hcp.primary_flag = 'Y'
       AND   hcp.status = 'A';
  END IF;
  IF l_count=1 then
    return TRUE;
  ELSE
    return FALSE;
  END IF;
END web_exist;

PROCEDURE update_address_note (
  p_party_site_id	   IN NUMBER
, p_note       IN VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
l_step NUMBER;
BEGIN

l_step := 0;

-- Update the address note with the provided note
    POS_ADDRESS_NOTES_PKG.update_note(
    p_party_site_id
    ,p_note
    ,x_status
    ,x_exception_msg
    );

l_step := 1;

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20017, x_exception_msg, true);
END update_address_note;

PROCEDURE assign_address_type (
  p_party_site_id	   IN NUMBER
, p_address_type       IN VARCHAR2
, x_party_site_use_id out nocopy NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_msg_count 		NUMBER;
l_step NUMBER;
l_party_site_use_rec 		HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;

BEGIN

l_party_site_use_rec.party_site_id := p_party_site_id;
l_party_site_use_rec.application_id := 177;
l_party_site_use_rec.created_by_module := 'POS_PROFILE_PKG';
l_party_site_use_rec.status := 'A';
l_party_site_use_rec.site_use_type := p_address_type;

    hz_party_site_v2pub.create_party_site_use
    (   p_init_msg_list => FND_API.G_FALSE,
        p_party_site_use_rec   => l_party_site_use_rec,
        x_party_site_use_id => x_party_site_use_id,
        x_return_status => x_status,
        x_msg_count => l_msg_count,
        x_msg_data => x_exception_msg

    );

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20017, x_exception_msg, true);
END assign_address_type;


PROCEDURE update_address_type (
  p_party_site_use_id	   IN NUMBER
, p_status                 IN VARCHAR2
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_msg_count 		NUMBER;
l_step NUMBER;
l_party_site_use_rec 		HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
l_obj_no NUMBER;
BEGIN

--dbms_output.put_line (' In update address type. Start ');
l_party_site_use_rec.party_site_use_id := p_party_site_use_id;
l_party_site_use_rec.application_id := 177;
l_party_site_use_rec.created_by_module := 'POS_PROFILE_PKG';
l_party_site_use_rec.status := p_status;
l_obj_no := p_object_version_number;

if p_status = 'I' then
l_party_site_use_rec.primary_per_type := 'N';
end if;

    hz_party_site_v2pub.update_party_site_use
    (   p_init_msg_list => FND_API.G_FALSE,
        p_party_site_use_rec   => l_party_site_use_rec,
        p_object_version_number => l_obj_no,
        x_return_status => x_status,
        x_msg_count => l_msg_count,
        x_msg_data => x_exception_msg

    );

--dbms_output.put_line (' In update address type. End');
EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20019, x_exception_msg, true);
END update_address_type;

PROCEDURE update_all_address_type (
  p_party_site_id	   IN NUMBER
, p_rfq                IN VARCHAR2
, p_pur                IN VARCHAR2
, p_pay                IN VARCHAR2
, p_primaryPay                IN VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step NUMBER;
l_status hz_party_site_uses.status%TYPE;
l_rfq_obj_no hz_party_site_uses.object_version_number%TYPE;
l_pay_obj_no hz_party_site_uses.object_version_number%TYPE;
l_pur_obj_no hz_party_site_uses.object_version_number%TYPE;

l_rfq_status hz_party_site_uses.status%TYPE;
l_pur_status hz_party_site_uses.status%TYPE;
l_pay_status hz_party_site_uses.status%TYPE;

l_rfq_use_id hz_party_site_uses.party_site_use_id%TYPE;
l_pur_use_id hz_party_site_uses.party_site_use_id%TYPE;
l_pay_use_id hz_party_site_uses.party_site_use_id%TYPE;

l_party_site_name hz_party_sites.party_site_name%type;
BEGIN

--dbms_output.put_line (' In update all address types. Start');
l_step := 1;
x_status := 'S';
x_exception_msg := null;

--dbms_output.put_line (' In update all address types. Step: '||l_step);
select pay.party_site_use_id, pur.party_site_use_id, rfq.party_site_use_id,
       pay.object_version_number, pur.object_version_number, rfq.object_version_number,
       pay.status, pur.status, rfq.status, hps.party_site_name
into l_pay_use_id, l_pur_use_id, l_rfq_use_id, l_pay_obj_no, l_pur_obj_no, l_rfq_obj_no,
     l_pay_status, l_pur_status, l_rfq_status , l_party_site_name
from hz_party_sites hps ,hz_party_site_uses pay, hz_party_site_uses pur, hz_party_site_uses rfq
where hps.party_site_id = p_party_site_id
--and hps.created_by_module like 'POS%'
and pay.party_site_id(+) = hps.party_site_id
and pur.party_site_id(+) = hps.party_site_id
and rfq.party_site_id(+) = hps.party_site_id
and pay.status(+) = 'A'
and pur.status(+) = 'A'
and rfq.status(+) = 'A'
and nvl(pay.end_date(+), sysdate) >= sysdate
and nvl(pur.end_date(+), sysdate) >= sysdate
and nvl(rfq.end_date(+), sysdate) >= sysdate
and nvl(pay.begin_date(+), sysdate) <= sysdate
and nvl(pur.begin_date(+), sysdate) <= sysdate
and nvl(rfq.begin_date(+), sysdate) <= sysdate
and pay.site_use_type(+) = 'PAY'
and pur.site_use_type(+) = 'PURCHASING'
and rfq.site_use_type(+) = 'RFQ';

l_step := 2;
--dbms_output.put_line (' In update all address types. Step: '||l_step);

    if p_rfq = 'Y' then
            l_status := 'A';
    else
            l_status := 'I';
    end if;

l_step := 3;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
if l_rfq_use_id is not null and l_status = 'I' then

l_step := 4;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
            POS_PROFILE_PKG.update_address_type (
            p_party_site_use_id => l_rfq_use_id
            , p_status => l_status
            , p_object_version_number => l_rfq_obj_no
            , x_status => x_status
            , x_exception_msg => x_exception_msg
        );
else
l_step := 5;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
    if l_status = 'A' then
         assign_address_type (
            p_party_site_id => p_party_site_id
            , p_address_type => 'RFQ'
            , x_party_site_use_id => l_rfq_use_id
            , x_status => x_status
            , x_exception_msg => x_exception_msg
        );
    end if;

end if;

l_step := 6;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
    if p_pur = 'Y' then
            l_status := 'A';
    else
            l_status := 'I';
    end if;

l_step := 7;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
if l_pur_use_id is not null and l_status = 'I' then

l_step := 8;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
            POS_PROFILE_PKG.update_address_type (
            p_party_site_use_id => l_pur_use_id
            , p_status => l_status
            , p_object_version_number => l_pur_obj_no
            , x_status => x_status
            , x_exception_msg => x_exception_msg
        );
else
l_step := 9;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
    if l_status = 'A' then
l_step := 10;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
         assign_address_type (
            p_party_site_id => p_party_site_id
            , p_address_type => 'PURCHASING'
            , x_party_site_use_id => l_rfq_use_id
            , x_status => x_status
            , x_exception_msg => x_exception_msg
        );
    end if;

end if;

l_step := 11;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
    if p_pay = 'Y' then
            l_status := 'A';
    else
            l_status := 'I';
    end if;

l_step := 12;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
if l_pay_use_id is not null and l_status = 'I' then

l_step := 13;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
            POS_PROFILE_PKG.update_address_type (
            p_party_site_use_id => l_pay_use_id
            , p_status => l_status
            , p_object_version_number => l_pay_obj_no
            , x_status => x_status
            , x_exception_msg => x_exception_msg
        );
else
l_step := 14;
--dbms_output.put_line (' In update all address types. Step: '||l_step);
    if l_status = 'A' then
         assign_address_type (
            p_party_site_id => p_party_site_id
            , p_address_type => 'PAY'
            , x_party_site_use_id => l_rfq_use_id
            , x_status => x_status
            , x_exception_msg => x_exception_msg
        );
    end if;

end if;

l_step := 15;
--dbms_output.put_line (' In update all address types. End ');
EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20016, x_exception_msg, true);
END update_all_address_type;

PROCEDURE update_party_email(
  p_party_id           IN NUMBER
, p_party_type         IN VARCHAR2
, p_email              IN VARCHAR2
, x_status	OUT NOCOPY VARCHAR2
, x_exception_msg          OUT NOCOPY VARCHAR2
)
IS
  l_contact_point_id    NUMBER;
  l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
  l_email_rec           hz_contact_point_v2pub.email_rec_type;
  l_exception_msg           varchar2(100);
  return_status           VARCHAR2(100);
  msg_count               NUMBER;
  msg_data                VARCHAR2(100);
  profile_id		NUMBER;
  l_email 		VARCHAR2(2000);
  l_update_date         DATE;
  l_object_version_number number;
  l_old_email   HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
  l_email_status varchar2(10);
BEGIN
--dbms_output.put_line (' In update party email .Start');
  x_exception_msg := 'BEGIN: update_party_email';
  x_status := 'S';

--fnd_client_info.set_org_context('-3113');

IF (web_exist(p_party_id,p_party_type,'EMAIL',NULL)) then
  SELECT hcp.contact_point_id, nvl(hcp.object_version_number,0), hcp.email_address
  INTO l_contact_point_id, l_object_version_number,l_old_email
  FROM hz_contact_points hcp
  WHERE hcp.owner_table_name = p_party_type
  AND   hcp.owner_table_id = p_party_id
  AND   hcp.contact_point_type = 'EMAIL'
  AND   hcp.primary_flag = 'Y'
  AND   HCP.STATUS = 'A';

--to prevent a NULL value to be passed to update_contact_points.
--TCA fails if NULL is passed to the API
  IF p_email is NULL or trim(p_email) = '' THEN
     l_email	:=l_old_email ;
     l_email_status := 'I';

  ELSE
     l_email	:=p_email;
     l_email_status := 'A';
  END IF;

  l_contact_points_rec.contact_point_id := l_contact_point_id;
  l_contact_points_rec.status := l_email_status;
  l_email_rec.email_format := 'MAILTEXT';
  l_email_rec.email_address := l_email;
  l_update_date             := get_update_date_from_contact(l_contact_point_id);

  HZ_CONTACT_POINT_V2PUB.update_contact_point(
       --p_api_version => 1.0,
       --p_commit  =>  fnd_api.g_false,
       p_contact_point_rec => l_contact_points_rec,
       p_email_rec => l_email_rec,
       p_object_version_number => l_object_version_number,
       --p_last_update_date => l_update_date, --get_update_date_from_contact(l_contact_point_id),
       x_return_status => return_status,
       x_msg_count => msg_count,
       x_msg_data => msg_data);
  if (return_status <> 'S') THEN
    x_exception_msg	:=msg_data;
    raise_application_error(-20001, x_exception_msg, true);
  END IF;
ELSIF (p_email is NOT NULL) THEN
        l_email_rec.email_format                        := 'MAILTEXT';
        l_email_rec.email_address                       := p_email;
        l_contact_points_rec.contact_point_type       := 'EMAIL';
        l_contact_points_rec.status                           := 'A';
        l_contact_points_rec.owner_table_name         := p_party_type;
        l_contact_points_rec.owner_table_id           := p_party_id;
        l_contact_points_rec.created_by_module        := 'POS:PLS:ADM';
        hz_contact_point_v2pub.create_contact_point
        (
            --1.0,fnd_api.g_true,
               fnd_api.g_false,l_contact_points_rec,null,
               l_email_rec,null,null,null,profile_id,return_status,
               msg_count,msg_data);
        if (return_status <> 'S') THEN
            x_exception_msg := msg_data;
             raise_application_error(-20002, x_exception_msg, true);
        end if;
ELSE
  NULL; --This is the case when the field was null and remains null
END IF;

--dbms_output.put_line (' In update party email .End');
x_exception_msg :=NULL;
--x_status ='S';
EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, x_exception_msg, true);
END update_party_email;

PROCEDURE update_party_phone(
  p_party_id           IN NUMBER
, p_party_type         IN VARCHAR2
, p_country_code       IN VARCHAR2
, p_area_code          IN VARCHAR2
, p_number             IN VARCHAR2
, p_extension          IN VARCHAR2
, x_status	OUT NOCOPY VARCHAR2
, x_exception_msg          OUT NOCOPY VARCHAR2
)
IS
  l_contact_point_id    NUMBER;
  l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
  l_phone_rec           hz_contact_point_v2pub.phone_rec_type;
  l_exception_msg           varchar2(100);
  return_status           VARCHAR2(100);
  msg_count               NUMBER;
  msg_data                VARCHAR2(100);
  profile_id		NUMBER;
  l_number		  VARCHAR2(40);
  l_update_date	          DATE;
  l_object_version_number number;
  l_old_number    HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;
BEGIN
--dbms_output.put_line (' In update party phone.Start');
  x_status := 'S';
  x_exception_msg := 'BEGIN: update_party_phone';
  x_exception_msg := 'SELECT: contact_point_id';
--fnd_client_info.set_org_context('-3113');
IF (phone_exist(p_party_id,p_party_type,'PHONE', 'GEN')) THEN
  SELECT hcp.contact_point_id, nvl(hcp.object_version_number,0), hcp.phone_number
  INTO l_contact_point_id, l_object_version_number, l_old_number
  FROM hz_contact_points hcp
  WHERE hcp.owner_table_name = p_party_type
  AND   hcp.owner_table_id = p_party_id
  AND   hcp.contact_point_type = 'PHONE'
  AND   hcp.phone_line_type = 'GEN'
  AND   hcp.primary_flag = 'Y'
  AND   hcp.status = 'A';

  IF ( p_number is NULL or trim(p_number) = '' ) THEN
     l_number	:= l_old_number ;
     l_contact_points_rec.status := 'I';
     --l_contact_points_rec.status := 'A';
  ELSE
     l_number	:=p_number;
     l_contact_points_rec.status := 'A';
  END IF;

  l_contact_points_rec.contact_point_id := l_contact_point_id;
  l_phone_rec.phone_country_code := p_country_code;
  l_phone_rec.phone_area_code := p_area_code;
  l_phone_rec.phone_number := l_number;
  l_phone_rec.phone_extension := p_extension;
  l_phone_rec.phone_line_type := 'GEN';
  l_update_date               := get_update_date_from_contact(l_contact_point_id);

  x_exception_msg := 'CALL: HZ_CONTACT_POINT_V2PUB.update_contact_point';

  HZ_CONTACT_POINT_V2PUB.update_contact_point(
       --p_api_version => 1.0,
       --p_commit  =>  fnd_api.g_false,
       p_contact_point_rec => l_contact_points_rec,
       p_phone_rec => l_phone_rec,
       p_object_version_number => l_object_version_number,
       --p_last_update_date => l_update_date, --get_update_date_from_contact(l_contact_point_id),
        x_return_status => return_status,
       x_msg_count => msg_count, x_msg_data => msg_data);
  if (return_status <> 'S') THEN
    x_status := 'E';
    x_exception_msg	:=msg_data;
    raise_application_error(-20004, x_exception_msg, true);
  END IF;

  x_status := 'S';

ELSIF p_number IS NOT NULL THEN
  l_phone_rec.phone_country_code := p_country_code;
  l_phone_rec.phone_area_code := p_area_code;
  l_phone_rec.phone_number := p_number;
  l_phone_rec.phone_extension := p_extension;
  l_phone_rec.phone_line_type := 'GEN';
  l_contact_points_rec.contact_point_type     := 'PHONE';
  l_contact_points_rec.status                         := 'A';
  l_contact_points_rec.owner_table_name               := p_party_type;
  l_contact_points_rec.owner_table_id         := p_party_id;
  l_contact_points_rec.created_by_module        := 'POS:PLS:ADM';
  l_contact_points_rec.primary_flag := 'Y';
  hz_contact_point_v2pub.create_contact_point(
    --1.0,fnd_api.g_true,
    fnd_api.g_false,l_contact_points_rec,null,null,l_phone_rec,null,
    null,profile_id,return_status,msg_count,msg_data);
  if (return_status <> 'S') THEN
     x_status := 'E';
     x_exception_msg := msg_data;
     raise_application_error(-20005, x_exception_msg, true);
  end if;
  x_status := 'S';
ELSE
  NULL; --This is the case when the field was null and remains null
  x_status := 'S';
END IF;

x_status := 'S';
x_exception_msg :=NULL;
--dbms_output.put_line (' In update party phone.end');
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20005,'Update phone number failed: '||x_exception_msg, true);
END update_party_phone;

PROCEDURE update_party_fax(
  p_party_id           IN NUMBER
, p_party_type           IN VARCHAR2
, p_country_code       IN VARCHAR2
, p_area_code          IN VARCHAR2
, p_number             IN VARCHAR2
, p_extension          IN VARCHAR2
, x_status	OUT NOCOPY VARCHAR2
, x_exception_msg          OUT NOCOPY VARCHAR2
)
IS
  l_contact_point_id    NUMBER;
  l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
  l_phone_rec           hz_contact_point_v2pub.phone_rec_type;
  l_exception_msg           varchar2(100);
  return_status           VARCHAR2(100);
  msg_count               NUMBER;
  msg_data                VARCHAR2(100);
  profile_id		NUMBER;
  l_number		VARCHAR2(40);
  l_update_date	          DATE;
  l_object_version_number number;
  l_old_number   HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;
BEGIN
--dbms_output.put_line (' In update party fax.start');
  x_exception_msg := 'BEGIN: update_party_fax';
  x_status := 'S';

--fnd_client_info.set_org_context('-3113');
 IF (phone_exist(p_party_id,p_party_type,'PHONE', 'FAX')) THEN
  SELECT hcp.contact_point_id, nvl( hcp.object_version_number,0), hcp.phone_number
  INTO l_contact_point_id, l_object_version_number, l_old_number
  FROM hz_contact_points hcp
  WHERE hcp.owner_table_name = p_party_type
  AND   hcp.owner_table_id = p_party_id
  AND   hcp.contact_point_type = 'PHONE'
  AND   hcp.phone_line_type = 'FAX'
  AND   hcp.status = 'A' ;

  IF ( p_number is NULL or trim(p_number) = '' ) THEN
     l_number	:=l_old_number;
     l_contact_points_rec.status := 'I';
     --l_contact_points_rec.status := 'A';
  ELSE
     l_number	:=p_number;
     l_contact_points_rec.status := 'A';
  END IF;

  l_contact_points_rec.contact_point_id := l_contact_point_id;
  l_phone_rec.phone_country_code := p_country_code;
  l_phone_rec.phone_area_code := p_area_code;
  l_phone_rec.phone_number := l_number;
  l_phone_rec.phone_extension := p_extension;
  l_phone_rec.phone_line_type := 'FAX';
  l_update_date               := get_update_date_from_contact(l_contact_point_id);

  HZ_CONTACT_POINT_V2PUB.update_contact_point(
       --p_api_version => 1.0,
       --p_commit  =>  fnd_api.g_false,
       p_contact_point_rec => l_contact_points_rec,
       p_phone_rec => l_phone_rec,
       p_object_version_number =>l_object_version_number,
       x_return_status => return_status,
       x_msg_count => msg_count, x_msg_data => msg_data);
  if (return_status <> 'S') THEN
    x_exception_msg	:=msg_data;
   raise_application_error(-20005, x_exception_msg, true);
  END IF;
ELSIF p_number IS NOT NULL THEN
  l_phone_rec.phone_country_code := p_country_code;
  l_phone_rec.phone_area_code := p_area_code;
  l_phone_rec.phone_number := p_number;
  l_phone_rec.phone_extension := p_extension;
  l_phone_rec.phone_line_type := 'FAX';
  l_contact_points_rec.contact_point_type     := 'PHONE';
  l_contact_points_rec.status                         := 'A';
  l_contact_points_rec.owner_table_name               := p_party_type;
  l_contact_points_rec.owner_table_id         := p_party_id;
  l_contact_points_rec.created_by_module        := 'POS:PLS:ADM';
  l_contact_points_rec.primary_flag := 'N';

  hz_contact_point_v2pub.create_contact_point(
    --1.0,fnd_api.g_true,
    fnd_api.g_false,l_contact_points_rec,null,null,l_phone_rec,null,
    null,profile_id,return_status,msg_count,msg_data);
  if (return_status <> 'S') THEN
     x_exception_msg := msg_data;
    raise_application_error(-20005, x_exception_msg, true);
  end if;
ELSE
  NULL; --This is the case when the field was null and remains null
END IF;

x_exception_msg :=NULL;
--dbms_output.put_line (' In update party fax.end');
EXCEPTION
    WHEN OTHERS THEN
      ----dbms_output.put_line('Other failure -- '||x_exception_msg);
      raise;

END update_party_fax;

PROCEDURE buyer_update_address_details
(
    p_party_site_id         IN NUMBER,
    p_rfqFlag          IN VARCHAR2,
    p_purFlag          IN VARCHAR2,
    p_payFlag          IN VARCHAR2,
    p_primaryPayFlag   IN VARCHAR2,
    p_note             IN VARCHAR2,
    p_phone_area_code  IN VARCHAR2 DEFAULT NULL,
    p_phone            IN VARCHAR2 DEFAULT NULL,
    p_phone_contact_id IN NUMBER default null,
    p_phone_obj_ver_num IN NUMBER default null,
    p_fax_area_code  IN VARCHAR2 DEFAULT NULL,
    p_fax            IN VARCHAR2 DEFAULT NULL,
    p_fax_contact_id IN NUMBER default null,
    p_fax_obj_ver_num IN NUMBER default null,
    p_email            IN VARCHAR2 DEFAULT NULL,
    p_email_contact_id IN NUMBER default null,
    p_email_obj_ver_num IN NUMBER default null,
    x_status           out nocopy VARCHAR2,
    x_exception_msg    out nocopy VARCHAR2
)
IS
l_step NUMBER;
lv_proc_name VARCHAR2(30) := 'buyer_update_address_site';
BEGIN

    l_step := 0;

    --dbms_output.put_line (lv_proc_name || ' : '||l_step);
    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.string(fnd_log.level_statement, g_log_module_name
            || '.' || lv_proc_name, 'Start');
    END IF;

    l_step := 1;
    --dbms_output.put_line (lv_proc_name || ' : '||l_step);
    -- Assign all address types.
    POS_PROFILE_PKG.update_all_address_type(
      p_party_site_id => p_party_site_id
    , p_rfq           => p_rfqFlag
    , p_pur           => p_purFlag
    , p_pay           => p_payFlag
    , p_primaryPay           => p_primaryPayFlag
    , x_status        => x_status
    , x_exception_msg => x_exception_msg
    );

    --dbms_output.put_line ('Status:'|| x_status ||' : msg '|| x_exception_msg);
    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.string(fnd_log.level_statement, g_log_module_name
            || '.' || lv_proc_name, 'Assigned all address types: Status:'
            || x_status || ': msg: '|| x_exception_msg);
    END IF;

    l_step := 2;
    --dbms_output.put_line (lv_proc_name || ' : '||l_step);
    -- Add the note
    POS_PROFILE_PKG.update_address_note(
        p_party_site_id => p_party_site_id
        , p_note => p_note
        , x_status  => x_status
        , x_exception_msg => x_exception_msg
    );
    --dbms_output.put_line ('Status:'|| x_status ||' : msg '|| x_exception_msg);

    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.string(fnd_log.level_statement, g_log_module_name
            || '.' || lv_proc_name, 'Assigned address note: Status:'
            || x_status || ': msg: '|| x_exception_msg);
    END IF;

    l_step:= 3;
    --dbms_output.put_line (lv_proc_name || ' : '||l_step);

    -- set phone for the address
    update_party_phone(
        p_party_id => p_party_site_id,
        p_party_type => 'HZ_PARTY_SITES',
        p_country_code =>  null,
        p_area_code => p_phone_area_code ,
        p_number => p_phone,
        p_extension => null,
        x_status => x_status,
        x_exception_msg => x_exception_msg
    );

    --dbms_output.put_line ('Status:'|| x_status ||' : msg '|| x_exception_msg);
    if(x_status <> 'S' ) THEN
        raise_application_error(-20006,'Update Address: Failed to add phone for party site:'||p_party_site_id, true);
    END IF;

    -- set fax for the address
    update_party_fax(
        p_party_id => p_party_site_id,
        p_party_type => 'HZ_PARTY_SITES',
        p_country_code =>  null,
        p_area_code => p_fax_area_code ,
        p_number => p_fax,
        p_extension => null,
        x_status => x_status,
        x_exception_msg => x_exception_msg
    );
    --dbms_output.put_line (lv_proc_name || ' : '||l_step);
    --dbms_output.put_line ('Status:'|| x_status ||' : msg '|| x_exception_msg);

    if(x_status <> 'S' ) THEN
        raise_application_error(-20006,'Update Address: Failed to add fax for party site:'||p_party_site_id, true);
    END IF;

    update_party_email(
        p_party_id => p_party_site_id,
        p_party_type => 'HZ_PARTY_SITES',
        p_email => p_email,
        x_status => x_status,
        x_exception_msg => x_exception_msg
    );
    --dbms_output.put_line (lv_proc_name || ' : '||l_step);
    --dbms_output.put_line ('Status:'|| x_status ||' : msg '|| x_exception_msg);

    if(x_status <> 'S' ) THEN
        raise_application_error(-20006,'Update Address: Failed to add phone for party site:'||p_party_site_id, true);
    END IF;

END buyer_update_address_details;

PROCEDURE remove_address (
  p_party_site_id          IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
l_step NUMBER;
l_party_site_rec                HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
l_msg_count             NUMBER;
l_obj_ver           HZ_PARTY_SITES.object_version_number%TYPE;
l_created_by_module HZ_PARTY_SITES.created_by_module%TYPE;

cursor l_site_cur is
select vendor_site_id, party_site_id, vendor_id from ap_supplier_sites_all where party_site_id = p_party_site_id;
l_site_rec l_site_cur%ROWTYPE;
l_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
l_return_status varchar2(1);
l_msg_data varchar2(4000);

cursor l_contact_cur is
select distinct ASCS.per_party_id
    from ap_supplier_contacts ASCS
    where (ASCS.inactive_date is null OR ASCS.inactive_date > sysdate)
    AND ASCS.org_party_site_id = p_party_site_id;
l_vendor_id number;
l_contact_rec l_contact_cur%ROWTYPE;

l_result_rec              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_payee_rec               IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_Rec_Type;
l_pay_instr_rec           IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
l_pay_assign_rec          IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
l_payee_assignment_id number;

cursor l_bank_cur is
select uses.instrument_id, uses.order_of_preference, uses.start_date,
payee.supplier_site_id, payee.org_id, payee.org_type,
hps.party_id, uses.instrument_payment_use_id
from iby_pmt_instr_uses_all uses, iby_external_payees_all payee, hz_party_sites hps
where uses.instrument_type = 'BANKACCOUNT'
and payee.ext_payee_id = uses.ext_pmt_party_id
and payee.payee_party_id = hps.party_id
and payee.payment_function = 'PAYABLES_DISB'
and payee.party_site_id = hps.party_site_id
and hps.party_site_id = p_party_site_id
and (uses.end_date is null OR uses.end_date > sysdate)
order by uses.order_of_preference;

l_bank_rec l_bank_cur%ROWTYPE;

BEGIN
  l_step := 0;

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' Begin remove_address ');
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' p_party_site_id ' || p_party_site_id);
  END IF;

  -- End date the party_site in hz_party_sites with party_site_id = p_party_site_id
  select object_version_number, created_by_module
  into l_obj_ver, l_created_by_module
  from hz_party_sites
  where party_site_id = p_party_site_id;

  l_party_site_rec.party_site_id := p_party_site_id;
  l_party_site_rec.status := 'I';
  l_party_site_rec.created_by_module := l_created_by_module;

  hz_party_site_v2pub.update_party_site(FND_API.G_FALSE,
      l_party_site_rec,
      l_obj_ver,
      x_status,
      l_msg_count,
      x_exception_msg);

  l_step := 1;

  -- Inactivate all the vendor sites.
  for l_site_rec in l_site_cur loop
    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' l_vendor_site_id ' || l_site_rec.vendor_site_id);
    END IF;

    l_vendor_site_rec.vendor_site_id := l_site_rec.vendor_site_id;
    l_vendor_site_rec.party_site_id := l_site_rec.party_site_id;
    l_vendor_site_rec.vendor_id := l_site_rec.vendor_id;
    l_vendor_site_rec.inactive_date := sysdate;

    POS_VENDOR_PUB_PKG.Update_Vendor_Site
    (
        l_vendor_site_rec,
        l_return_status,
        l_msg_count,
        l_msg_data
        );

    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' AP Update Vendor Site Status ' || l_return_status);
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' AP Update Vendor Site Count ' || l_msg_count);
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' AP Update Vendor Site exception msg ' || l_msg_data);
    END IF;
  end loop;

  l_step := 2;

  -- Inactivate all the vendor contacts address linkages.
  for l_contact_rec in l_contact_cur loop
    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' l_contact_party_id ' || l_contact_rec.per_party_id);
    END IF;

    pos_supplier_address_pkg.unassign_address_to_contact
    (p_contact_party_id   => l_contact_rec.per_party_id,
     p_org_party_site_id   => p_party_site_id,
     p_vendor_id           => l_vendor_id,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data);

    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' AP Update Vendor Contact Status ' || l_return_status);
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' AP Update Vendor Contact Count ' || l_msg_count);
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' AP Update Vendor Contact exception msg ' || l_msg_data);
    END IF;

   end loop;

  l_step := 3;
  -- Inactivate all the bank accounts linked to this address.
  for l_bank_rec in l_bank_cur loop
    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' l_instrument_id ' || l_bank_rec.instrument_id);
              FND_LOG.string(fnd_log.level_statement, g_log_module_name,
                        ' l_assignment_id ' || l_bank_rec.instrument_payment_use_id);
    END IF;
            -- Payee Record
            l_payee_rec.Payment_Function := 'PAYABLES_DISB';
            l_payee_rec.Party_id := l_bank_rec.party_id;
            l_payee_rec.Party_Site_id := p_party_site_id;
            l_payee_rec.org_Id := l_bank_rec.org_id;
            l_payee_rec.Supplier_Site_id := l_bank_rec.supplier_site_id;
            l_payee_rec.Org_Type := l_bank_rec.org_type;

            -- Instrument Record.
            l_pay_instr_rec.Instrument_Type := 'BANKACCOUNT';
            l_pay_instr_rec.Instrument_Id := l_bank_rec.instrument_id;

            -- Assignment Record.
            l_pay_assign_rec.Instrument := l_pay_instr_rec;
            l_pay_assign_rec.assignment_id := l_bank_rec.instrument_payment_use_id;
            l_pay_assign_rec.Priority := l_bank_rec.order_of_preference;
            l_pay_assign_rec.Start_Date := l_bank_rec.start_date;
            l_pay_assign_rec.End_Date := sysdate;

            IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
             p_api_version      => 1.0,
             p_init_msg_list    => FND_API.G_FALSE,
             p_commit           => FND_API.G_FALSE,
             x_return_status    => x_status,
             x_msg_count        => l_msg_count,
             x_msg_data         => x_exception_msg,
             p_payee            => l_payee_rec,
             p_assignment_attribs => l_pay_assign_rec,
             x_assign_id        => l_payee_assignment_id,
             x_response         => l_result_rec
            );

        IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_log_module_name,
            ' After Set_Payee_Instr_Assignment ');
            FND_LOG.string(fnd_log.level_statement, g_log_module_name,
            ' x_return_status ' || x_status);
            FND_LOG.string(fnd_log.level_statement, g_log_module_name,
            ' x_msg_count ' || l_msg_count);
            FND_LOG.string(fnd_log.level_statement, g_log_module_name,
            ' x_msg_data ' || x_exception_msg);
            FND_LOG.string(fnd_log.level_statement, g_log_module_name,
            ' x_assign_id ' || l_payee_assignment_id);
        END IF;

  end loop;

  x_status      :='S';
  x_exception_msg :=NULL;

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20015, x_exception_msg || sqlerrm, true);
END remove_address;

END POS_PROFILE_PKG;

/
