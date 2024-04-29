--------------------------------------------------------
--  DDL for Package Body AST_UWQ_LLIST_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_LLIST_INFO_PKG" AS
/* $Header: astulinb.pls 120.3 2006/01/12 02:07:52 rkumares ship $ */

--Purpose:  This package will be used for displaying information within the work panel
--Created by: Sekar Sundaram dated 5/16/02
--Last Updated by:  Joseph Raj dated 6/08/02
-- changed data to header type..
--Derived from astnoteb.pls

 procedure ast_uwq_llist_notes (
        p_resource_id                IN  NUMBER,
 		p_language                   IN  VARCHAR2,
 		p_source_lang              	 IN  VARCHAR2,
 		p_action_key                 IN  VARCHAR2,
 		p_workitem_data_list   		 IN  SYSTEM.ACTION_INPUT_DATA_NST,
 		x_notes_data_list          	 OUT NOCOPY SYSTEM.app_info_header_nst,
 		x_msg_count                	 OUT NOCOPY NUMBER,
 		x_msg_data                   OUT NOCOPY VARCHAR2,
 		x_return_status              OUT NOCOPY VARCHAR2
 		) IS

  l_ctr                     binary_integer;

  l_name  					varchar2(500);
  l_value  					varchar2(2000);
  l_party_id 				number;
  l_contact_party_id 			number;
  l_party_type 				varchar2(100);

  l_notes 					VARCHAR2(2000);

  l_curr_rec				VARCHAR2(3000);
  l_new_line				VARCHAR2(30);

  l_lead_id 				NUMBER;
  l_fnd_user_id				NUMBER;
  l_object_code				VARCHAR2(30);
  l_object_id				NUMBER;

  l_months number;
  l_from_date date;
  l_cur_ind				VARCHAR2(10);

--Code added for BugFix#4451689 --Start
  x_client_time		date;

  l_client_tz_id		number;
  l_server_tz_id		number;
 --Code added for BugFix#4451689 --End

  CURSOR C_note_details_desc(p_fnd_user_id NUMBER,
					    p_object_code VARCHAR2,
	                        p_object_id NUMBER) is
	SELECT a.notes,
		  a.created_by_name,
		  a.entered_date, --modified with a.entered_date instead of a.creation_date for bug#4177915
		  a.note_type_meaning,
		  a.note_status_meaning,
		  a.source_object_id,
		  a.source_object_code,
		  b.select_id,
		  b.select_name,
		  b.select_details,
		  b.from_table,
		  b.where_clause,
		  tl.name,
		  a.notes_detail_size
	FROM ast_notes_bali_vl a,
		jtf_objects_b b,
		jtf_objects_tl tl
	WHERE (a.note_status <> 'P' or a.created_by = p_fnd_user_id)
		and a.object_code like p_object_code
		and a.object_id = p_object_id
		and a.source_object_code = b.object_code
		and b.object_code = tl.object_code
		and tl.language = userenv('LANG')
	order by a.entered_date desc; --modified with a.entered_date instead of a.creation_date for bug#4177915


 cursor C_note_details_months(p_fnd_user_id NUMBER,
					    p_object_code VARCHAR2,
	                        p_object_id NUMBER,
							p_from_date date) is
	SELECT a.notes,
		  a.created_by_name,
		  a.entered_date, --modified with a.entered_date instead of a.creation_date for bug#4177915
		  a.note_type_meaning,
		  a.note_status_meaning,
		  a.source_object_id,
		  a.source_object_code,
		  b.select_id,
		  b.select_name,
		  b.select_details,
		  b.from_table,
		  b.where_clause,
		  tl.name,
		  a.notes_detail_size
	FROM ast_notes_bali_vl a,
		jtf_objects_b b,
		jtf_objects_tl tl
	WHERE (a.note_status <> 'P' or a.created_by = p_fnd_user_id)
		and a.object_code like p_object_code
		and a.object_id = p_object_id
		and a.source_object_code = b.object_code
		and b.object_code = tl.object_code
		and tl.language = userenv('LANG')
		and trunc(a.creation_date) between trunc(p_from_date) and trunc(sysdate)
	order by a.entered_date desc; --modified with a.entered_date instead of a.creation_date for bug#4177915

BEGIN

	x_notes_data_list  := SYSTEM.app_info_header_nst();

	l_new_line := '          ';
	l_curr_rec := null;

	FOR I IN 1.. p_workitem_data_list.COUNT LOOP
              l_name := p_workitem_data_list(i).name;
              l_value := p_workitem_data_list(i).value;

              ------ Get field name and value of your records ------

	   if     l_name = 'CONTACT_PARTY_ID'   then
   	        l_contact_party_id :=  l_value ;
	   elsif     l_name = 'PARTY_ID'   then
   	        l_party_id :=  l_value ;
	   elsif     l_name = 'SALES_LEAD_ID'   then
   	        l_lead_id :=  l_value ;
	   end if;
	END LOOP;

	l_fnd_user_id := fnd_profile.value('USER_ID');



	l_curr_rec := null;
    l_ctr := 1;

    if  p_action_key in ('astulinb_cust_notes', 'astulinb_prof_cust_notes') then  -- begin of main "if"

	     l_object_id := l_party_id;
	     l_object_code := 'PARTY%';

    elsif p_action_key in ('astulinb_cont_notes', 'astulinb_prof_cont_notes') then  -- begin of main "if"

	     l_object_id := l_contact_party_id;
	     l_object_code := 'PARTY%';

	elsif p_action_key in ('astulinb_lead_notes', 'astulinb_prof_lead_notes') then  -- begin of main "if"

	   l_object_id := l_lead_id;
	   l_object_code := 'LEAD';

    end if;

	if p_action_key in ('astulinb_cust_notes','astulinb_cont_notes', 'astulinb_lead_notes') then
	    l_cur_ind := 'DESC'  ;
	elsif p_action_key in ('astulinb_prof_cust_notes','astulinb_prof_cont_notes', 'astulinb_prof_lead_notes') then
	     l_months    := nvl(FND_PROFILE.VALUE('AST_DEFAULT_MONTHS_TO_VIEW'), 1);
        l_from_date := add_months(sysdate, -1 * l_months );
	    l_cur_ind := 'MON'  ;
	end if;

	-----Notes in descending order ( latest to the oldest )
     if l_object_id is not null and l_cur_ind = 'DESC' then
		for c2_rec in  C_note_details_desc (l_fnd_user_id,
							 l_object_code,
							 l_object_id)
		LOOP
		--Code added for BugFix#4451689 --Start
	   		if fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS')='Y' THEN
				l_client_tz_id :=         to_number ( fnd_profile.value('CLIENT_TIMEZONE_ID'));
				l_server_tz_id :=         to_number( fnd_profile.value('SERVER_TIMEZONE_ID'));
				--modified with c2_rec.entered_date instead of c2_rec.creation_date for bug#4177915
				c2_rec.entered_date:=HZ_TIMEZONE_PUB.Convert_DateTime(l_server_tz_id,l_client_tz_id,c2_rec.entered_date);

			end if;
		 --Code added for BugFix#4451689 --Start

			--modified with c2_rec.entered_date instead of c2_rec.creation_date for bug#4177915
			l_curr_rec := ' *** ' || to_char(c2_rec.entered_date,'DD-MON-RRRR HH24:MI:SS') || ' *** ' || '
' || ' *** ' || c2_rec.created_by_name   || ' *** ' || '
' || ' *** ' || c2_rec.note_type_meaning || ' *** ' || '
' || c2_rec.notes;

			if nvl(c2_rec.notes_detail_size,0) > 0 then
				l_curr_rec := l_curr_rec || '   <...>';
			end if;

			x_notes_data_list.EXTEND;
				  x_notes_data_list(x_notes_data_list.LAST) := SYSTEM.APP_INFO_HEADER_OBJ( l_curr_rec);
				l_ctr := l_ctr + 1;
	   END LOOP;

     elsif l_object_id is not null and l_cur_ind = 'MON' then
		for c2_rec in  C_note_details_months (l_fnd_user_id,
							 l_object_code,
							 l_object_id, l_from_date)
		LOOP
			--Code added for BugFix#4451689 --Start
	   		if fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS')='Y' THEN
			  l_client_tz_id :=         to_number ( fnd_profile.value('CLIENT_TIMEZONE_ID'));
			  l_server_tz_id :=         to_number( fnd_profile.value('SERVER_TIMEZONE_ID'));

			--modified with c2_rec.entered_date instead of c2_rec.creation_date for bug#4177915
			c2_rec.entered_date:=HZ_TIMEZONE_PUB.Convert_DateTime(l_server_tz_id,l_client_tz_id,c2_rec.entered_date);

			end if;
			--Code added for BugFix#4451689 --Start
			--modified with c2_rec.entered_date instead of c2_rec.creation_date for bug#4177915
			l_curr_rec := ' *** ' || to_char(c2_rec.entered_date,'DD-MON-RRRR HH24:MI:SS') || ' *** ' || '
' || ' *** ' || c2_rec.created_by_name   || ' *** ' || '
' || ' *** ' || c2_rec.note_type_meaning || ' *** ' || '
' || c2_rec.notes;

			if nvl(c2_rec.notes_detail_size,0) > 0 then
				l_curr_rec := l_curr_rec || '   <...>';
			end if;

			x_notes_data_list.EXTEND;
				  x_notes_data_list(x_notes_data_list.LAST) := SYSTEM.APP_INFO_HEADER_OBJ( l_curr_rec);
				l_ctr := l_ctr + 1;
	   END LOOP;
     end if;


	 x_return_status	:=fnd_api.g_ret_sts_success;

	 fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
	                           p_data  => x_msg_data);

	EXCEPTION

	when fnd_api.g_exc_error  then
      x_return_status:=fnd_api.g_ret_sts_error;

	when fnd_api.g_exc_unexpected_error  then
      x_return_status:=fnd_api.g_ret_sts_unexp_error;

	when others then
      x_return_status:=fnd_api.g_ret_sts_unexp_error;

	 fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
	                           p_data  => x_msg_data);



end ast_uwq_llist_notes;
END ast_uwq_llist_info_pkg;

/
