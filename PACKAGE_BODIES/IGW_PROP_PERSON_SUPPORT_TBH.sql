--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSON_SUPPORT_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSON_SUPPORT_TBH" as
 /* $Header: igwtppsb.pls 115.8 2002/11/15 00:43:08 ashkumar ship $*/

PROCEDURE INSERT_ROW (
 X_ROWID 			  OUT NOCOPY 		VARCHAR2,
 X_PROP_PERSON_SUPPORT_ID	  OUT NOCOPY           NUMBER,
 P_PROPOSAL_ID                    IN		NUMBER,
 P_PERSON_ID                      IN		NUMBER,
 P_PARTY_ID                       IN		NUMBER,
 P_SUPPORT_TYPE                   IN		VARCHAR2,
 P_PROPOSAL_AWARD_ID              IN		NUMBER,
 P_PROPOSAL_AWARD_NUMBER          IN	 	VARCHAR2,
 P_PROPOSAL_AWARD_TITLE           IN 	 	VARCHAR2,
 P_PI_PERSON_ID                   IN		NUMBER,
 P_PI_PARTY_ID                    IN		NUMBER,
 P_SPONSOR_ID                     IN		NUMBER,
 P_PROJECT_LOCATION               IN		VARCHAR2,
 P_LOCATION_PARTY_ID              IN		NUMBER,
 P_START_DATE                     IN		DATE,
 P_END_DATE                       IN		DATE,
 P_PERCENT_EFFORT                 IN		NUMBER,
 P_MAJOR_GOALS                    IN		VARCHAR2,
 P_OVERLAP                        IN		VARCHAR2,
 P_ANNUAL_DIRECT_COST             IN		NUMBER,
 P_TOTAL_COST                     IN		NUMBER,
 P_CALENDAR_START_DATE            IN		DATE,
 P_CALENDAR_END_DATE              IN		DATE,
 P_ACADEMIC_START_DATE            IN		DATE,
 P_ACADEMIC_END_DATE              IN		DATE,
 P_SUMMER_START_DATE              IN		DATE,
 P_SUMMER_END_DATE                IN		DATE,
 P_ATTRIBUTE_CATEGORY             IN		VARCHAR2,
 P_ATTRIBUTE1                     IN		VARCHAR2,
 P_ATTRIBUTE2                     IN		VARCHAR2,
 P_ATTRIBUTE3                     IN		VARCHAR2,
 P_ATTRIBUTE4                     IN		VARCHAR2,
 P_ATTRIBUTE5                     IN		VARCHAR2,
 P_ATTRIBUTE6                     IN		VARCHAR2,
 P_ATTRIBUTE7                     IN		VARCHAR2,
 P_ATTRIBUTE8                     IN		VARCHAR2,
 P_ATTRIBUTE9                     IN		VARCHAR2,
 P_ATTRIBUTE10                    IN		VARCHAR2,
 P_ATTRIBUTE11                    IN		VARCHAR2,
 P_ATTRIBUTE12                    IN		VARCHAR2,
 P_ATTRIBUTE13                    IN		VARCHAR2,
 P_ATTRIBUTE14                    IN		VARCHAR2,
 P_ATTRIBUTE15                    IN		VARCHAR2,
 P_MODE 			  IN 		VARCHAR2,
 P_SEQUENCE_NUMBER		  IN 		NUMBER,
 X_RETURN_STATUS         	  OUT NOCOPY  		VARCHAR2) is

L_PROP_PERSON_SUPPORT_ID  NUMBER;

cursor c is select ROWID from IGW_PROP_PERSON_SUPPORT
      where prop_person_support_id = l_prop_person_support_id;

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

insert into igw_prop_person_support (
  PROP_PERSON_SUPPORT_ID
 ,PROPOSAL_ID
 ,PERSON_ID
 ,PARTY_ID
 ,SUPPORT_TYPE
 ,PROPOSAL_AWARD_ID
 ,PROPOSAL_AWARD_NUMBER
 ,PROPOSAL_AWARD_TITLE
 ,PI_PERSON_ID
 ,PI_PARTY_ID
 ,SPONSOR_ID
 ,PROJECT_LOCATION
 ,LOCATION_PARTY_ID
 ,START_DATE
 ,END_DATE
 ,PERCENT_EFFORT
 ,MAJOR_GOALS
 ,OVERLAP
 ,ANNUAL_DIRECT_COST
 ,TOTAL_COST
 ,CALENDAR_START_DATE
 ,CALENDAR_END_DATE
 ,ACADEMIC_START_DATE
 ,ACADEMIC_END_DATE
 ,SUMMER_START_DATE
 ,SUMMER_END_DATE
 ,ATTRIBUTE_CATEGORY
 ,ATTRIBUTE1
 ,ATTRIBUTE2
 ,ATTRIBUTE3
 ,ATTRIBUTE4
 ,ATTRIBUTE5
 ,ATTRIBUTE6
 ,ATTRIBUTE7
 ,ATTRIBUTE8
 ,ATTRIBUTE9
 ,ATTRIBUTE10
 ,ATTRIBUTE11
 ,ATTRIBUTE12
 ,ATTRIBUTE13
 ,ATTRIBUTE14
 ,ATTRIBUTE15
 ,last_update_date
 ,last_updated_by
 ,creation_date
 ,created_by
 ,last_update_login
 ,record_version_number
 ,sequence_number
  ) values (
  IGW_PROP_PERSON_SUPPORT_S.NEXTVAL
 ,P_PROPOSAL_ID
 ,P_PERSON_ID
 ,P_PARTY_ID
 ,P_SUPPORT_TYPE
 ,P_PROPOSAL_AWARD_ID
 ,P_PROPOSAL_AWARD_NUMBER
 ,P_PROPOSAL_AWARD_TITLE
 ,P_PI_PERSON_ID
 ,P_PI_PARTY_ID
 ,P_SPONSOR_ID
 ,P_PROJECT_LOCATION
 ,P_LOCATION_PARTY_ID
 ,P_START_DATE
 ,P_END_DATE
 ,P_PERCENT_EFFORT
 ,P_MAJOR_GOALS
 ,P_OVERLAP
 ,P_ANNUAL_DIRECT_COST
 ,P_TOTAL_COST
 ,P_CALENDAR_START_DATE
 ,P_CALENDAR_END_DATE
 ,P_ACADEMIC_START_DATE
 ,P_ACADEMIC_END_DATE
 ,P_SUMMER_START_DATE
 ,P_SUMMER_END_DATE
 ,P_ATTRIBUTE_CATEGORY
 ,P_ATTRIBUTE1
 ,P_ATTRIBUTE2
 ,P_ATTRIBUTE3
 ,P_ATTRIBUTE4
 ,P_ATTRIBUTE5
 ,P_ATTRIBUTE6
 ,P_ATTRIBUTE7
 ,P_ATTRIBUTE8
 ,P_ATTRIBUTE9
 ,P_ATTRIBUTE10
 ,P_ATTRIBUTE11
 ,P_ATTRIBUTE12
 ,P_ATTRIBUTE13
 ,P_ATTRIBUTE14
 ,P_ATTRIBUTE15
 ,l_last_update_date
 ,l_last_updated_by
 ,l_last_update_date
 ,l_last_updated_by
 ,l_last_update_login
 ,1
 ,P_SEQUENCE_NUMBER
  )
  RETURNING PROP_PERSON_SUPPORT_ID INTO L_PROP_PERSON_SUPPORT_ID;

  open c;
  fetch c into x_rowid;
  if (c%notfound) then
       close c;
       raise no_data_found;
  end if;
  close c;
  X_PROP_PERSON_SUPPORT_ID := L_PROP_PERSON_SUPPORT_ID;

  EXCEPTION
      when others then
      fnd_msg_pub.add_exc_msg(p_pkg_name 		=> 	'IGW_PROP_PERSON_SUPPORT_TBH',
      			      p_procedure_name 		=> 	'INSERT_ROW',
      			      p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      raise;

END INSERT_ROW;
----------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_ROW (
 X_ROWID 			  IN  		VARCHAR2,
 P_PROP_PERSON_SUPPORT_ID	  IN            NUMBER,
 P_PROPOSAL_ID                    IN		NUMBER,
 P_PERSON_ID                      IN		NUMBER,
 P_PARTY_ID                       IN		NUMBER,
 P_SUPPORT_TYPE                   IN		VARCHAR2,
 P_PROPOSAL_AWARD_ID              IN		NUMBER,
 P_PROPOSAL_AWARD_NUMBER          IN	 	VARCHAR2,
 P_PROPOSAL_AWARD_TITLE           IN 	 	VARCHAR2,
 P_PI_PERSON_ID                   IN		NUMBER,
 P_PI_PARTY_ID                    IN		NUMBER,
 P_SPONSOR_ID                     IN		NUMBER,
 P_PROJECT_LOCATION               IN		VARCHAR2,
 P_LOCATION_PARTY_ID              IN		NUMBER,
 P_START_DATE                     IN		DATE,
 P_END_DATE                       IN		DATE,
 P_PERCENT_EFFORT                 IN		NUMBER,
 P_MAJOR_GOALS                    IN		VARCHAR2,
 P_OVERLAP                        IN		VARCHAR2,
 P_ANNUAL_DIRECT_COST             IN		NUMBER,
 P_TOTAL_COST                     IN		NUMBER,
 P_CALENDAR_START_DATE            IN		DATE,
 P_CALENDAR_END_DATE              IN		DATE,
 P_ACADEMIC_START_DATE            IN		DATE,
 P_ACADEMIC_END_DATE              IN		DATE,
 P_SUMMER_START_DATE              IN		DATE,
 P_SUMMER_END_DATE                IN		DATE,
 P_ATTRIBUTE_CATEGORY             IN		VARCHAR2,
 P_ATTRIBUTE1                     IN		VARCHAR2,
 P_ATTRIBUTE2                     IN		VARCHAR2,
 P_ATTRIBUTE3                     IN		VARCHAR2,
 P_ATTRIBUTE4                     IN		VARCHAR2,
 P_ATTRIBUTE5                     IN		VARCHAR2,
 P_ATTRIBUTE6                     IN		VARCHAR2,
 P_ATTRIBUTE7                     IN		VARCHAR2,
 P_ATTRIBUTE8                     IN		VARCHAR2,
 P_ATTRIBUTE9                     IN		VARCHAR2,
 P_ATTRIBUTE10                    IN		VARCHAR2,
 P_ATTRIBUTE11                    IN		VARCHAR2,
 P_ATTRIBUTE12                    IN		VARCHAR2,
 P_ATTRIBUTE13                    IN		VARCHAR2,
 P_ATTRIBUTE14                    IN		VARCHAR2,
 P_ATTRIBUTE15                    IN		VARCHAR2,
 P_MODE 			  IN 		VARCHAR2,
 P_RECORD_VERSION_NUMBER 	  IN            NUMBER,
 P_SEQUENCE_NUMBER		  IN		NUMBER,
 X_RETURN_STATUS         	  OUT NOCOPY  		VARCHAR2
	) is

    l_last_update_date 		DATE;
    l_last_updated_by 		NUMBER;
    l_last_update_login 	NUMBER;

BEGIN
x_return_status := fnd_api.g_ret_sts_success;


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

      update IGW_PROP_PERSON_SUPPORT set
    	     	 PROP_PERSON_SUPPORT_ID		=	P_PROP_PERSON_SUPPORT_ID
 		,PROPOSAL_ID 			=	P_PROPOSAL_ID
 		,PERSON_ID  			=	P_PERSON_ID
 		,PARTY_ID  			=	P_PARTY_ID
 		,SUPPORT_TYPE			=	P_SUPPORT_TYPE
 		,PROPOSAL_AWARD_ID		=	P_PROPOSAL_AWARD_ID
 		,PROPOSAL_AWARD_NUMBER  	=	P_PROPOSAL_AWARD_NUMBER
 		,PROPOSAL_AWARD_TITLE    	=	P_PROPOSAL_AWARD_TITLE
 		,PI_PERSON_ID                   =	P_PI_PERSON_ID
 		,PI_PARTY_ID                    =	P_PI_PARTY_ID
 		,SPONSOR_ID                	=	P_SPONSOR_ID
 		,PROJECT_LOCATION    		=	P_PROJECT_LOCATION
 		,LOCATION_PARTY_ID    		=	P_LOCATION_PARTY_ID
 		,START_DATE     		=	P_START_DATE
 		,END_DATE          		=	P_END_DATE
 		,PERCENT_EFFORT      		=	P_PERCENT_EFFORT
 		,MAJOR_GOALS        		=	P_MAJOR_GOALS
 		,OVERLAP      			=	P_OVERLAP
 		,ANNUAL_DIRECT_COST    		=	P_ANNUAL_DIRECT_COST
 		,TOTAL_COST          		=	P_TOTAL_COST
 		,CALENDAR_START_DATE     	=	P_CALENDAR_START_DATE
 		,CALENDAR_END_DATE     		=	P_CALENDAR_END_DATE
 		,ACADEMIC_START_DATE          	=	P_ACADEMIC_START_DATE
 		,ACADEMIC_END_DATE     		=	P_ACADEMIC_END_DATE
 		,SUMMER_START_DATE       	=	P_SUMMER_START_DATE
 		,SUMMER_END_DATE       		=	P_SUMMER_END_DATE
 		,ATTRIBUTE_CATEGORY     	=	P_ATTRIBUTE_CATEGORY
 		,ATTRIBUTE1        		=	P_ATTRIBUTE1
 		,ATTRIBUTE2       		=	P_ATTRIBUTE2
 		,ATTRIBUTE3      		=	P_ATTRIBUTE3
	 	,ATTRIBUTE4       		=	P_ATTRIBUTE4
 		,ATTRIBUTE5       		=	P_ATTRIBUTE5
 		,ATTRIBUTE6      		=	P_ATTRIBUTE6
 		,ATTRIBUTE7       		=	P_ATTRIBUTE7
 		,ATTRIBUTE8       		=	P_ATTRIBUTE8
 		,ATTRIBUTE9      		=	P_ATTRIBUTE9
 		,ATTRIBUTE10       		=	P_ATTRIBUTE10
 		,ATTRIBUTE11      		=	P_ATTRIBUTE11
 		,ATTRIBUTE12      		=	P_ATTRIBUTE12
 		,ATTRIBUTE13     		=	P_ATTRIBUTE13
 		,ATTRIBUTE14     		=	P_ATTRIBUTE14
 		,ATTRIBUTE15    		=	P_ATTRIBUTE15
 	        ,last_update_date 		= 	l_last_update_date
 	        ,last_updated_by 		= 	l_last_updated_by
 	        ,last_update_login 		= 	l_last_update_login
 	        ,record_version_number 		= 	record_version_number + 1
 	        ,sequence_number	        =       P_SEQUENCE_NUMBER
      where rowid = x_rowid
      and record_version_number = p_record_version_number;

      if (sql%notfound) then
          fnd_message.set_name('IGW', 'IGW_SS_RECORD_CHANGED');
          fnd_msg_pub.Add;
          x_return_status := 'E';
      end if;

    EXCEPTION
      when others then
         fnd_msg_pub.add_exc_msg(p_pkg_name 		=> 	'IGW_PROP_PERSON_SUPPORT_TBH',
         			 p_procedure_name	=> 	'UPDATE_ROW',
         			 p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         raise;

END UPDATE_ROW;

----------------------------------------------------------------------------------------------------

PROCEDURE DELETE_ROW (
  x_rowid 			in	VARCHAR2,
  p_record_version_number 	in 	NUMBER,
  x_return_status       	out NOCOPY  	VARCHAR2
) is

BEGIN
x_return_status := fnd_api.g_ret_sts_success;

       delete from IGW_PROP_PERSON_SUPPORT
       where rowid = x_rowid
       and record_version_number = p_record_version_number;

      if (sql%notfound) then
          fnd_message.set_name('IGW', 'IGW_SS_RECORD_CHANGED');
          fnd_msg_pub.Add;
          x_return_status := 'E';
      end if;


   EXCEPTION
      when others then
         fnd_msg_pub.add_exc_msg(p_pkg_name 		=> 	'IGW_PROP_PERSONS_SUPPORT_TBH',
         			 p_procedure_name 	=> 	'DELETE_ROW',
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
  X_MODE in VARCHAR2
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

END IGW_PROP_PERSON_SUPPORT_TBH;

/
