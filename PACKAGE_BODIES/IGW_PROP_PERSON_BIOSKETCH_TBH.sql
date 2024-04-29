--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSON_BIOSKETCH_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSON_BIOSKETCH_TBH" as
 /* $Header: igwtppbb.pls 115.2 2002/03/28 19:15:08 pkm ship    $*/


PROCEDURE UPDATE_ROW (
 X_ROWID 		     in 	VARCHAR2,
 P_PROPOSAL_ID               in	 	NUMBER,
 P_PERSON_BIOSKETCH_ID       in		NUMBER,
 P_SHOW_FLAG 		     in         VARCHAR2,
 P_LINE_SEQUENCE	     in		NUMBER,
 P_MODE 		     in 	VARCHAR2 default 'R',
 P_RECORD_VERSION_NUMBER     in         NUMBER,
 X_RETURN_STATUS             out  	VARCHAR2) is

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

      update IGW_PROP_PERSON_BIOSKETCH set
    	     	 PROPOSAL_ID  			=	P_PROPOSAL_ID
 		,PERSON_BIOSKETCH_ID  		=	P_PERSON_BIOSKETCH_ID
 		,SHOW_FLAG 			=	P_SHOW_FLAG
 		,LINE_SEQUENCE			=	P_LINE_SEQUENCE
 	        ,last_update_date 		= 	l_last_update_date
 	        ,last_updated_by 		= 	l_last_updated_by
 	        ,last_update_login 		= 	l_last_update_login
 	        ,record_version_number 		= 	record_version_number + 1
      where rowid = x_rowid
      and record_version_number = p_record_version_number;

      if (sql%notfound) then
          fnd_message.set_name('IGW', 'IGW_SS_RECORD_CHANGED');
          fnd_msg_pub.Add;
          x_return_status := 'E';
      end if;

    EXCEPTION
      when others then
         fnd_msg_pub.add_exc_msg(p_pkg_name 		=> 	'IGW_PROP_PERSON_BIOSKETCH_TBH',
         			 p_procedure_name	=> 	'UPDATE_ROW',
         			 p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         raise;

END UPDATE_ROW;


END IGW_PROP_PERSON_BIOSKETCH_TBH;

/
