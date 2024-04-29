--------------------------------------------------------
--  DDL for Package Body PV_MATCH_PARTNER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_MATCH_PARTNER" as
/* $Header: pvxpmatb.pls 115.26 2004/05/25 20:32:12 dhii ship $*/

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                               privateroutines                                     */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/



--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Match_partner                                                           |
--|        This procedure Matches partner for a given where condition.         |
--|        to insert rows into pv_enty_attr_text for each partner              |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================



Procedure Match_partner(p_api_version_number   IN      NUMBER,
								p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
								p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
								p_validation_level     IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
								p_sql                  IN      VArchar2,
								p_num_of_attrs         IN      NUMBER,
								x_matched_prt          OUT     JTF_VARCHAR2_TABLE_100,
								x_prt_matched          OUT     boolean,
								x_matched_attr_cnt     OUT     NUMBER,
								x_return_status        OUT     VARCHAR2,
								x_msg_count            OUT     NUMBER,
								x_msg_data             OUT     VARCHAR2) IS

	Type Match_Partner_Rec is REF CURSOR;

	match_partner_cur          Match_Partner_Rec;
	l_possible_match_party_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_possible_match_rank_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_possible_match_count     number := 0;
	l_possible_rank_high       number := 0;
	l_match_count              number := 0;
	l_top_n_rows               number;
	l_rank_base_2              number;
	l_matching_rank            number;
	l_combined_rank            number;
	l_tmp_true_rank            number;
	l_tmp_matching_rank        number;
	l_tmp_combined_rank        number;
	l_attr_count               number;
	partner_id                 number;
	l_all_ranks                varchar2(1000);

	l_api_name            CONSTANT VARCHAR2(30) := 'Match_partner';
	l_api_version_number  CONSTANT NUMBER       := 1.0;

begin

	-- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
													p_api_version_number,
													l_api_name,
													G_PKG_NAME) THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
      fnd_msg_pub.initialize;
   END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	x_matched_prt := JTF_VARCHAR2_TABLE_100();


	l_top_n_rows :=nvl(fnd_profile.value('PV_TOP_N_MATCH_PARTNERS'), 10);
   l_matching_rank := 1;
   l_combined_rank := 1;
	l_all_ranks     := ' 1 ';

   for i in 1..p_num_of_attrs - 1 loop

      l_matching_rank := l_matching_rank * 2;
      l_combined_rank := l_combined_rank + l_matching_rank;
		l_all_ranks     := l_all_ranks || ' ' || l_combined_rank || ' '; -- like ' 1 3 8 15 31...etc'

   end loop;


	open match_partner_cur for p_sql;
   loop

		fetch match_partner_cur into partner_id, l_rank_base_2;
		exit when match_partner_cur%NOTFOUND or x_matched_prt.count = l_top_n_rows;


		while (mod (l_rank_base_2, 2) <> 0          /* ignore even numbers which will never match */
			 and l_combined_rank > l_rank_base_2     /* stop when combined rank drops below current rank */
          and l_match_count = 0)                  /* only decrease combined rank if no partners matched */
		loop

			if instr(l_all_ranks, ' ' || l_rank_base_2 || ' ') = 0 then

            -- not a complete match. eg. 'matches rank 1, 2, 4, 16. (missing 8). adds up to 23.
            -- true rank is 7. that is, sum of consecutive ranks
				-- will always match at least rank 1 if odd number rank. so find out the true rank

				l_tmp_combined_rank := l_combined_rank;
				l_tmp_matching_rank := l_matching_rank;
				l_tmp_true_rank     := l_rank_base_2;

				while l_tmp_combined_rank <> l_tmp_true_rank
				loop

					if l_tmp_combined_rank > l_tmp_true_rank then

						l_tmp_combined_rank := l_tmp_combined_rank - l_tmp_matching_rank;

					end if;

					if l_tmp_true_rank > l_tmp_combined_rank then

						l_tmp_true_rank := l_tmp_true_rank - l_tmp_matching_rank;

					end if;

					l_tmp_matching_rank := l_tmp_matching_rank / 2;

				end loop;


				if l_tmp_true_rank > l_possible_rank_high then
					l_possible_rank_high := l_tmp_true_rank;
				end if;

				l_possible_match_count := l_possible_match_count + 1;
				l_possible_match_party_tbl.extend();
				l_possible_match_rank_tbl.extend();

				l_possible_match_party_tbl(l_possible_match_count) := partner_id;
				l_possible_match_rank_tbl(l_possible_match_count)  := l_tmp_true_rank;

            exit;

         else

				l_combined_rank := l_combined_rank - l_matching_rank;
				l_matching_rank := l_matching_rank / 2;


			end if;

			for i in 1..l_possible_match_count loop

				if l_combined_rank = l_possible_match_rank_tbl(i) then

					l_match_count := l_match_count + 1;
					x_matched_prt.extend;
					x_matched_prt(l_match_count) := l_possible_match_party_tbl(i);


					l_possible_match_rank_tbl(i) := 0; -- so that it doesn't get added again the next time around

				end if;

			end loop;

		end loop;

      if l_combined_rank = l_rank_base_2 then


			l_match_count := l_match_count + 1;
			x_matched_prt.extend;
			x_matched_prt(l_match_count) := partner_id;

      else
			if l_match_count > 0 then
				exit;
			end if;
      end if;

	end loop;

   close match_partner_cur;

	if x_matched_prt.count = 0 then

		l_matching_rank := l_possible_rank_high;

		for i in 1..l_possible_match_count loop

			if l_matching_rank = l_possible_match_rank_tbl(i) then

				l_match_count := l_match_count + 1;
				x_matched_prt.extend;
				x_matched_prt(l_match_count) := l_possible_match_party_tbl(i);


			end if;

		end loop;

   end if;

	-- Set flag to true / false depending on whether partners are matched or not

	if x_matched_prt.count > 0 then

		x_prt_matched := true;

      l_attr_count := 0;
		while (l_matching_rank >= 1)
		loop
			l_attr_count := l_attr_count + 1;
         l_matching_rank := l_matching_rank / 2;
		end loop;

		x_matched_attr_cnt := l_attr_count;

	else
		x_prt_matched      := false;
		x_matched_attr_cnt := 0;
	end if;


	IF FND_API.To_Boolean ( p_commit )   THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
										p_count     =>  x_msg_count,
										p_data      =>  x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

END Match_partner;



/*************************************************************************************/

/*                               public routines                                     */
/*                                                                                   */
/*************************************************************************************/



--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|   Form_WHere_clause                                                        |
--|        This procedure Takes attributes and their values and forms where    |
--|        condition to search for partners. It keeps on dropping attributes   |
--|        in where condition until a partner is found or they get exhausted   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================


procedure Form_Where_Clause(
		p_api_version_number   IN      NUMBER,
		p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
		p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
		p_validation_level     IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		p_attr_tbl             IN OUT  JTF_VARCHAR2_TABLE_100,
		p_attr_val_count       IN      JTF_VARCHAR2_TABLE_100,
		p_val_attr_tbl         IN OUT  JTF_VARCHAR2_TABLE_100,
		p_cm_id                IN      number,
		p_lead_id              IN      number,
		p_auto_match_flag      IN      varchar2,
		x_iterations           OUT     varchar2,
		x_matched_id_tbl       OUT     JTF_VARCHAR2_TABLE_100,
		x_return_status        OUT     VARCHAR2,
		x_msg_count            OUT     NUMBER,
		x_msg_data             OUT     VARCHAR2) IS


   Type l_tmp is Table of Varchar2(4000) index by binary_integer;

   l_tmp_tbl                  l_tmp;
   l_tmp_tbl1                 l_tmp;
   l_where                    Varchar2(32000);
   l_value_count              Number;
   l_tmp_where                Varchar2(4000);
   attr_seq                   NUMBER := 1;
   l_attr_val_count           NUmber;
   l_attr                     VARCHAR2(100);
   l_attr_value               VARCHAR2(100);
   l_prt_matched              boolean := true;
	l_incumbent_pt_party_id    number;
	l_matched_attr_cnt         number;
	l_rank_base_2              number := 1;
	l_incumbent_exists_flag    boolean;
   tbl_cnt                    Number;
   cnt                        Number;
   l_iterations               Number := 0;

	l_api_name            CONSTANT VARCHAR2(30) := 'Form_Where_Clause';
	l_api_version_number  CONSTANT NUMBER       := 1.0;

	cursor lc_get_incumbent_pt (pc_lead_id number) is
		select INCUMBENT_PARTNER_PARTY_ID
		from as_leads_all
		where lead_id = pc_lead_id;

begin


	-- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
													p_api_version_number,
													l_api_name,
													G_PKG_NAME) THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
      fnd_msg_pub.initialize;
   END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	x_matched_id_tbl := JTF_VARCHAR2_TABLE_100();


	IF FND_API.To_Boolean ( p_commit )   THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
										p_count     =>  x_msg_count,
										p_data      =>  x_msg_data);
EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN

		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

END Form_Where_Clause;




--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Auto_match_criteria                                                     |
--|        This procedure creats attributes and their values in case of        |
--|        Automatic search of partners                                        |
--|                                                                            |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================


 Procedure Auto_Match_Criteria (
		p_api_version_number   IN NUMBER,
		p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
		p_commit               IN VARCHAR2 := FND_API.G_FALSE,
		p_validation_level     IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		p_lead_id              IN  Number,
		x_matched_attr         OUT JTF_VARCHAR2_TABLE_100,
		x_matched_attr_val     OUT JTF_VARCHAR2_TABLE_100,
      x_original_attr        OUT JTF_VARCHAR2_TABLE_100,
		x_original_attr_val    OUT JTF_VARCHAR2_TABLE_100,
		x_iterations           OUT varchar2,
		x_matched_id           OUT JTF_VARCHAR2_TABLE_100,
		x_return_status        OUT VARCHAR2,
		x_msg_count            OUT NUMBER,
		x_msg_data             OUT VARCHAR2) IS

	l_attr_val_cnt JTF_VARCHAR2_TABLE_100;

	cursor attr_cur  is
		select  a.attribute_id , a.sql_text ,  upper(a.src_pkcol_name) src_pkcol_name,  v.short_name
		from   pv_entity_attrs a, pv_attributes_vl v
		where  a.attribute_id = v.attribute_id
		and    a.entity = 'LEAD'
		and    a.enabled_flag= 'Y'
		and    a.auto_assign_flag='Y'
		and    v.enabled_flag='Y'
		order   by a.rank;

	type cur_type is REF CURSOR;
	c             cur_type;

	l_val_count   Number;
	l_value       VARCHAR2(100);
	l_total_count Number := 1;
	l_query       Varchar2(2000);

	l_api_name            CONSTANT VARCHAR2(30) := 'Auto_Match_Criteria';
	l_api_version_number  CONSTANT NUMBER       := 1.0;

Begin

	-- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
													p_api_version_number,
													l_api_name,
													G_PKG_NAME) THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
      fnd_msg_pub.initialize;
   END IF;

	x_matched_attr_val  := JTF_VARCHAR2_TABLE_100();
	x_matched_attr      := JTF_VARCHAR2_TABLE_100();
	x_original_attr     := JTF_VARCHAR2_TABLE_100();
	x_original_attr_val := JTF_VARCHAR2_TABLE_100();
	l_attr_val_cnt      := JTF_VARCHAR2_TABLE_100();
	x_matched_id        := JTF_VARCHAR2_TABLE_100();

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

   for attr_rec IN attr_cur loop

		l_val_count := 0;

		l_query  := replace(attr_rec.sql_text, '  ', ' ');

		if l_query is null then

			fnd_message.SET_NAME  ('PV', 'PV_SQLTEXT_NULL');
			fnd_message.SET_TOKEN ('P_ENTITY'    , 'LEAD');
			fnd_message.SET_TOKEN ('P_ATTRIBUTE' , attr_rec.short_name);
			fnd_msg_pub.ADD;

			raise FND_API.G_EXC_ERROR;

		end if;

		if(attr_rec.src_pkcol_name = 'LEAD_ID' ) then

			open c for l_query  using p_lead_id;

		elsif (attr_rec.src_pkcol_name = 'ATTRIBUTE_ID' ) then

			open c for l_query  using attr_rec.attribute_id;
		else
			open c for l_query;
		end if;

		for i in 1..ceil((length(l_query)/100)) loop
			null;
		end loop;

		loop

			fetch c into l_value ;
			exit when c%notfound;

			if (l_value is not null) then

				l_val_count := l_val_count + 1;

				x_matched_attr.extend;
				x_original_attr.extend;
				x_matched_attr(x_matched_attr.count) := attr_rec.short_name;
				x_original_attr(x_matched_attr.count) := attr_rec.short_name;

				x_matched_attr_val.extend;
				x_original_attr_val.extend;

				x_matched_attr_val(l_total_count) := l_value;
				x_original_attr_val(l_total_count) := l_value;

				l_total_count := l_total_count + 1;
			end if;
		end loop;
		close c;

		if (l_val_count <> 0 ) then
			l_attr_val_cnt.extend;
			l_attr_val_cnt(l_attr_val_cnt.count) := l_val_count;
		end if;

	end loop;

	Form_Where_clause(
			p_api_version_number  =>   l_api_version_number
			,p_init_msg_list      =>   p_init_msg_list
			,p_commit             =>   p_commit
			,p_validation_level   =>   FND_API.G_VALID_LEVEL_FULL
		   ,p_attr_tbl           =>  x_matched_attr
			,p_attr_val_count     => l_attr_val_cnt
			,p_val_attr_tbl       => x_matched_attr_val
			,p_cm_id              => 0
			,p_lead_id            => p_lead_id
			,p_auto_match_flag    => 'Y'
			,x_iterations         => x_iterations
			,x_matched_id_tbl     => x_matched_id
			,x_return_status      => x_return_status
			,x_msg_count          => x_msg_count
			,x_msg_data           => x_msg_data);

	IF (x_return_status = fnd_api.g_ret_sts_error) THEN
		RAISE fnd_api.g_exc_error;
	ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	IF FND_API.To_Boolean ( p_commit )   THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
										p_count     =>  x_msg_count,
										p_data      =>  x_msg_data);
EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN

		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

End Auto_Match_Criteria;

end PV_MATCH_PARTNER;

/
