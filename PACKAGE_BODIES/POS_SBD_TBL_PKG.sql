--------------------------------------------------------
--  DDL for Package Body POS_SBD_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SBD_TBL_PKG" as
/*$Header: POSSBDTB.pls 120.0 2005/08/21 08:48:24 gdwivedi noship $ */

PROCEDURE del_row_pos_acnt_summ_req (
  p_assignment_id	   IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step NUMBER;

BEGIN

l_step := 0;

delete from pos_acnt_addr_summ_req where assignment_id = p_assignment_id;

l_step := 1;

x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20043, x_exception_msg, true);
END del_row_pos_acnt_summ_req;

PROCEDURE del_row_pos_acnt_addr_req (
  p_assignment_request_id	   IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step NUMBER;

BEGIN

l_step := 0;

delete from pos_acnt_addr_req where assignment_request_id = p_assignment_request_id;

l_step := 1;

x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20045, x_exception_msg, true);
END del_row_pos_acnt_addr_req;

PROCEDURE del_row_pos_acnt_gen_req (
  p_account_request_id	   IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step NUMBER;

BEGIN

l_step := 0;

delete from pos_acnt_gen_req where account_request_id = p_account_request_id;

l_step := 1;

x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20049, x_exception_msg, true);
END del_row_pos_acnt_gen_req;

PROCEDURE update_row_pos_acnt_summ_req (
  p_assignment_id	   IN NUMBER
, p_assignment_request_id  IN NUMBER
, p_ext_bank_account_id    IN NUMBER
, p_account_request_id     IN NUMBER
, p_start_date             IN DATE
, p_end_date               IN DATE
, p_priority               IN NUMBER
, p_assignment_status      IN VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step NUMBER;

BEGIN

   l_step:= 0;

    update pos_acnt_addr_summ_req set
     last_update_date = sysdate
   , last_updated_by = fnd_global.user_id
   , last_update_login  = fnd_global.login_id
   , ext_bank_account_id = nvl(p_ext_bank_account_id,ext_bank_account_id)
   , account_request_id = nvl(p_account_request_id, account_request_id)
   , assignment_status = nvl(p_assignment_status, assignment_status)
   , start_date = p_start_date
   , end_date = p_end_date
   , priority = p_priority
   where assignment_request_id = p_assignment_request_id
   and assignment_id = p_assignment_id;

   l_step:= 1;

x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20046, x_exception_msg, true);
END update_row_pos_acnt_summ_req;


/* This procedure create a row in POS_ACNT_ADDR_REQ
 *
 */
PROCEDURE insert_row_pos_acnt_addr_req (
  p_mapping_id	   in NUMBER
, p_request_type   in varchar2
, p_party_site_id  in number
, p_address_request_id in number
, x_assignment_request_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step number;

BEGIN

  l_step := 0;
   select POS_ACNT_ADDR_REQ_S.nextval into x_assignment_request_id from dual;

  l_step := 1;
  insert into POS_ACNT_ADDR_REQ (
     assignment_request_id
   , creation_date
   , created_by
   , last_update_date
   , last_updated_by
   , last_update_login
   , object_version_number
   , MAPPING_ID
   , request_status
   , request_type
   , party_site_id
   , address_request_id
  )
  values
  (
    x_assignment_request_id
  , sysdate -- creation_date
  , fnd_global.user_id -- created_by
  , sysdate -- last_update_date
  , fnd_global.user_id -- last_updated_by
  , fnd_global.login_id -- last_update_login
  , 1
  , p_mapping_id
  , 'PENDING'
  , p_request_type
  , p_party_site_id
  , p_address_request_id
  );

  l_step := 2;

  x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20048, x_exception_msg, true);
END insert_row_pos_acnt_addr_req;


/* This procedure create a row in POS_ACNT_GEN_REQ
 *
 */
PROCEDURE insert_row_pos_acnt_gen_req (
  p_mapping_id	   IN NUMBER
, p_temp_ext_bank_account_id IN NUMBER
, p_ext_bank_account_id IN NUMBER
, x_account_request_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step number;

BEGIN

  l_step := 0;
  select POS_ACNT_GEN_REQ_S.nextval into x_account_request_id from dual;

  l_step := 1;
  insert into POS_ACNT_GEN_REQ (
     account_request_id
   , creation_date
   , created_by
   , last_update_date
   , last_updated_by
   , last_update_login
   , object_version_number
   , MAPPING_ID
   , TEMP_EXT_BANK_ACCT_ID
   , EXT_BANK_ACCOUNT_ID
  )
  values
  (
   x_account_request_id
  , sysdate -- creation_date
  , fnd_global.user_id -- created_by
  , sysdate -- last_update_date
  , fnd_global.user_id -- last_updated_by
  , fnd_global.login_id -- last_update_login
  , 1
  , p_mapping_id
  , p_temp_ext_bank_account_id
  , p_ext_bank_account_id
  );

  l_step := 2;

  x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20047, x_exception_msg, true);
END insert_row_pos_acnt_gen_req;

PROCEDURE insert_row_pos_acnt_summ_req (
  p_assignment_request_id in number
, p_ext_bank_account_id IN NUMBER
, p_account_request_id in number
, p_start_date in date
, p_end_date in date
, p_priority in number
, p_assignment_status in varchar2
, x_assignment_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step number;

BEGIN

  l_step := 0;
  select POS_ACNT_ADDR_SUMM_REQ_S.nextval into x_assignment_id from dual;

  l_step := 1;
  insert into POS_ACNT_ADDR_SUMM_REQ (
     assignment_id
   , creation_date
   , created_by
   , last_update_date
   , last_updated_by
   , last_update_login
   , assignment_request_id
   , ext_bank_account_id
   , start_date
   , end_date
   , priority
   , assignment_status
   , account_request_id
   , object_version_number
  )
  values
  (
    x_assignment_id
  , sysdate -- creation_date
  , fnd_global.user_id -- created_by
  , sysdate -- last_update_date
  , fnd_global.user_id -- last_updated_by
  , fnd_global.login_id -- last_update_login
  , p_assignment_request_id
  , p_ext_bank_account_id
  , p_start_date
  , p_end_date
  , p_priority
  , p_assignment_status
  , p_account_request_id
  , 1
  );
  l_step := 2;

  x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20049, x_exception_msg, true);
END insert_row_pos_acnt_summ_req;


/* This procedure updates a row in POS_ACNT_ADDR_REQ
 *
 */
PROCEDURE update_row_pos_acnt_addr_req (
  p_assignment_request_id  IN NUMBER
, p_request_status in varchar2
, p_party_site_id  in number
, p_address_request_id in number
, p_object_version_number in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
l_step number;
l_object_version_number number;

cursor l_update_cur is
select object_version_number from POS_ACNT_ADDR_REQ
where assignment_request_id = p_assignment_request_id for update;

BEGIN

l_step := 0;

open l_update_cur;
fetch l_update_cur into l_object_version_number;
close l_update_cur;

l_step := 1;

if l_object_version_number = p_object_version_number then

  l_step := 2;
  update POS_ACNT_ADDR_REQ set
   last_update_date = sysdate
   , last_updated_by = fnd_global.user_id
   , last_update_login = fnd_global.login_id
   , request_status = nvl(p_request_status, request_status)
   , party_site_id = p_party_site_id
   , address_request_id = p_address_request_id
  where assignment_request_id = p_assignment_request_id;

else

 l_step := 3;
 raise_application_error(-20049, 'Concurrent Access', true);

end if;

l_step := 4;

x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20049, x_exception_msg, true);
END update_row_pos_acnt_addr_req;

END POS_SBD_TBL_PKG;

/
