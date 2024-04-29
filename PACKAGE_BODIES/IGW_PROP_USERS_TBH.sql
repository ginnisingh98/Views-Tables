--------------------------------------------------------
--  DDL for Package Body IGW_PROP_USERS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_USERS_TBH" as
 /* $Header: igwtprub.pls 115.4 2002/11/15 00:46:34 ashkumar ship $*/

PROCEDURE INSERT_ROW (
	x_rowid 		out NOCOPY 		VARCHAR2,
        p_proposal_id		in              NUMBER,
 	p_user_id               in 		NUMBER,
	p_start_date_active     in		DATE,
 	p_end_date_active       in		DATE,
	p_mode 			in 		VARCHAR2 default 'R',
	x_return_status         out NOCOPY  		VARCHAR2
	) is

cursor c is select ROWID from IGW_PROP_USERS
      where proposal_id = p_proposal_id
      and   user_id = p_user_id;

      l_last_update_date 	DATE;
      l_last_updated_by 	NUMBER;
      l_last_update_login 	NUMBER;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_last_update_date := SYSDATE;

  if(p_mode = 'I') then
      l_last_updated_by := 1;
      l_last_update_login := 0;
  elsif (p_mode = 'R') then
       l_last_updated_by := FND_GLOBAL.USER_ID;

       if l_last_updated_by is NULL then
            l_last_updated_by := -1;
       end if;

       l_last_update_login := FND_GLOBAL.LOGIN_ID;

       if l_last_update_login is NULL then
            l_last_update_login := -1;
       end if;
  else
       FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
       app_exception.raise_exception;
  end if;

insert into igw_prop_users (
        proposal_id,
 	user_id,
 	start_date_active,
 	end_date_active,
 	last_update_date,
 	last_updated_by,
 	creation_date,
 	created_by,
 	last_update_login,
 	record_version_number
  ) values (
        p_proposal_id,
 	p_user_id,
	p_start_date_active,
 	p_end_date_active,
 	l_last_update_date,
 	l_last_updated_by,
 	l_last_update_date,
 	l_last_updated_by,
 	l_last_update_login,
 	1
  );

  open c;
  fetch c into x_rowid;
  if (c%notfound) then
       close c;
       raise no_data_found;
  end if;
  close c;

  EXCEPTION
      when others then
        fnd_msg_pub.add_exc_msg(p_pkg_name 		=> 	'IGW_PROP_USERS_TBH',
      			        p_procedure_name 	=> 	'INSERT_ROW',
      			        p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        raise;

END INSERT_ROW;
----------------------------------------------------------------------------------------------------
-------- Since the primary key is updateable on the front end rowid is REQUIRED for doing update ------
PROCEDURE UPDATE_ROW (
  	x_rowid 		in  		VARCHAR2,
  	p_record_version_number in              NUMBER,
        p_proposal_id		in              NUMBER,
 	p_user_id               in 		NUMBER,
	p_start_date_active     in		DATE,
 	p_end_date_active       in		DATE,
	p_mode 			in 		VARCHAR2 default 'R',
	x_return_status         out NOCOPY  		VARCHAR2
	) is

    l_last_update_date 		DATE;
    l_last_updated_by 		NUMBER;
    l_last_update_login 	NUMBER;

BEGIN
x_return_status := fnd_api.g_ret_sts_success;

     l_last_update_date := SYSDATE;
     if (p_mode = 'I') then
          l_last_updated_by := 1;
          l_last_update_login := 0;
     elsif (p_mode = 'R') then
          l_last_updated_by := FND_GLOBAL.USER_ID;

          if l_last_updated_by is NULL then
                l_last_updated_by := -1;
          end if;

          l_last_update_login := FND_GLOBAL.LOGIN_ID;

          if l_last_update_login is NULL then
                l_last_update_login := -1;
          end if;
      else
          FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
          app_exception.raise_exception;
      end if;

      update IGW_PROP_USERS set
            proposal_id = p_proposal_id,
 	    user_id = p_user_id,
 	    start_date_active = p_start_date_active,
 	    end_date_active = p_end_date_active,
 	    last_update_date = l_last_update_date,
 	    last_updated_by = l_last_updated_by,
 	    last_update_login = l_last_update_login,
 	    record_version_number = record_version_number + 1
      where rowid = x_rowid
      and record_version_number = p_record_version_number;

      if (sql%notfound) then
          fnd_message.set_name('IGW', 'IGW_SS_RECORD_CHANGED');
          fnd_msg_pub.Add;
          x_return_status := 'E';
      end if;


    EXCEPTION
      when others then
           fnd_msg_pub.add_exc_msg(p_pkg_name 			=> 	'IGW_PROP_USERS_TBH',
         			   p_procedure_name 		=> 	'UPDATE_ROW',
         			   p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           raise;

END UPDATE_ROW;
----------------------------------------------------------------------------------------------------

PROCEDURE DELETE_ROW (
  x_rowid 			in 	VARCHAR2,
  p_record_version_number 	in 	NUMBER,
  x_return_status       	out NOCOPY  	VARCHAR2
) is

BEGIN
 x_return_status := fnd_api.g_ret_sts_success;

       delete from IGW_PROP_USERS
       where rowid = x_rowid
       and record_version_number = p_record_version_number;

       if (sql%notfound) then
          fnd_message.set_name('IGW', 'IGW_SS_RECORD_CHANGED');
          fnd_msg_pub.Add;
          x_return_status := 'E';
       end if;


   EXCEPTION
      when others then
           fnd_msg_pub.add_exc_msg(p_pkg_name 			=> 	'IGW_PROP_USERS_TBH',
         			   p_procedure_name 		=> 	'DELETE_ROW',
         			   p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           raise;

END DELETE_ROW;
------------------------------------------------------------------------------------------------------

/* procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RULE_ID in NUMBER,
  X_RULE_SEQUENCE_NUMBER in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_MAP_ID in NUMBER,
  X_VALID_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from IGW_BUSINESS_RULES_ALL
     where RULE_ID = X_RULE_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_RULE_ID,
     X_RULE_SEQUENCE_NUMBER,
     X_ORGANIZATION_ID,
     X_RULE_NAME,
     X_RULE_TYPE,
     X_MAP_ID,
     X_VALID_FLAG,
     X_START_DATE_ACTIVE,
     X_END_DATE_ACTIVE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_RULE_ID,
   X_RULE_SEQUENCE_NUMBER,
   X_ORGANIZATION_ID,
   X_RULE_NAME,
   X_RULE_TYPE,
   X_MAP_ID,
   X_VALID_FLAG,
   X_START_DATE_ACTIVE,
   X_END_DATE_ACTIVE,
   X_MODE);
end ADD_ROW; */


/* ---------------------- WILL NOT BE USED IN SELF SERVICE -----------------------------------------
procedure LOCK_ROW (
  X_ROWID  in VARCHAR2,
  X_RULE_ID in NUMBER,
  X_RULE_SEQUENCE_NUMBER in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_MAP_ID in NUMBER,
  X_VALID_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE
) is
  cursor c1 is select *
    from IGW_BUSINESS_RULES_ALL
    where ROWID = X_ROWID
    for update of RULE_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if (
           (tlinfo.RULE_ID = X_RULE_ID)
      AND ((tlinfo.RULE_SEQUENCE_NUMBER = X_RULE_SEQUENCE_NUMBER)
           OR ((tlinfo.RULE_SEQUENCE_NUMBER is null)
               AND (X_RULE_SEQUENCE_NUMBER is null)))
      AND (tlinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
      AND (tlinfo.RULE_NAME = X_RULE_NAME)
      AND (tlinfo.RULE_TYPE = X_RULE_TYPE)
      AND ((tlinfo.MAP_ID = X_MAP_ID)
           OR ((tlinfo.MAP_ID is null)
               AND (X_MAP_ID is null)))
      AND ((tlinfo.VALID_FLAG = X_VALID_FLAG)
           OR ((tlinfo.VALID_FLAG is null)
               AND (X_VALID_FLAG is null)))
      AND (tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((tlinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
*/

END IGW_PROP_USERS_TBH;

/
