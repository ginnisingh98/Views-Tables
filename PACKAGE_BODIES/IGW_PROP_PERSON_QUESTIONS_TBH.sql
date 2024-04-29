--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSON_QUESTIONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSON_QUESTIONS_TBH" as
 /* $Header: igwtppqb.pls 115.5 2002/11/15 00:42:17 ashkumar ship $*/

PROCEDURE INSERT_ROW (
	x_rowid 		out NOCOPY 		VARCHAR2,
        p_proposal_id		in              NUMBER,
 	p_party_id              in 		NUMBER,
 	p_person_id             in 		NUMBER,
 	p_question_number       in              VARCHAR2,
	p_answer     		in		VARCHAR2,
 	p_explanation           in		VARCHAR2,
 	p_review_date           in              DATE,
	p_mode 			in 		VARCHAR2,
	x_return_status         out NOCOPY  		VARCHAR2
	) is

cursor c is select ROWID from IGW_PROP_PERSON_QUESTIONS
      where proposal_id = p_proposal_id
      and   party_id = p_party_id
      and   question_number = p_question_number;

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

insert into igw_prop_person_questions (
        proposal_id,
        party_id,
 	person_id,
 	question_number,
 	answer,
 	explanation,
 	review_date,
 	last_update_date,
 	last_updated_by,
 	creation_date,
 	created_by,
 	last_update_login,
 	record_version_number
  ) values (
        p_proposal_id,
        p_party_id,
 	p_person_id,
	p_question_number,
 	p_answer,
 	p_explanation,
 	p_review_date,
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
        fnd_msg_pub.add_exc_msg(p_pkg_name 		=> 	'IGW_PROP_PERSON_QUESTIONS_TBH',
      			        p_procedure_name 	=> 	'INSERT_ROW',
      			        p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        raise;

END INSERT_ROW;
----------------------------------------------------------------------------------------------------
-------- Since the primary key is updateable on the front end rowid is REQUIRED for doing update ------
PROCEDURE UPDATE_ROW (
	x_rowid 		in 		VARCHAR2,
	p_record_version_number in              NUMBER,
        p_proposal_id		in              NUMBER,
 	p_party_id              in 		NUMBER,
 	p_person_id             in 		NUMBER,
 	p_question_number       in              VARCHAR2,
	p_answer     		in		VARCHAR2,
 	p_explanation           in		VARCHAR2,
 	p_review_date           in              DATE,
	p_mode 			in 		VARCHAR2,
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

      update IGW_PROP_PERSON_QUESTIONS set
            proposal_id = p_proposal_id,
            party_id = p_party_id,
 	    person_id = p_person_id,
 	    question_number = p_question_number,
 	    answer = p_answer,
 	    explanation = p_explanation,
 	    review_date = p_review_date,
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
           fnd_msg_pub.add_exc_msg(p_pkg_name 			=> 	'IGW_PROP_PERSON_QUESTIONS_TBH',
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

       delete from IGW_PROP_PERSON_QUESTIONS
       where rowid = x_rowid
       and record_version_number = p_record_version_number;

       if (sql%notfound) then
          fnd_message.set_name('IGW', 'IGW_SS_RECORD_CHANGED');
          fnd_msg_pub.Add;
          x_return_status := 'E';
       end if;


   EXCEPTION
      when others then
           fnd_msg_pub.add_exc_msg(p_pkg_name 			=> 	'IGW_PROP_PERSON_QUESTIONS_TBH',
         			   p_procedure_name 		=> 	'DELETE_ROW',
         			   p_error_text  		=>  	 SUBSTRB(SQLERRM, 1, 240));
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           raise;

END DELETE_ROW;

END IGW_PROP_PERSON_QUESTIONS_TBH;

/
