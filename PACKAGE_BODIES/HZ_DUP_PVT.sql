--------------------------------------------------------
--  DDL for Package Body HZ_DUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_PVT" AS
/*$Header: ARHDUPBB.pls 120.43.12010000.3 2009/10/28 18:00:51 awu ship $*/

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
         RETURN VARCHAR2;

-- called by Data Librarian UI. Default master based on the profile.
-- Dup set has to be created first with random winner party, then change
-- winner party id to the one based on defaulting rule.

procedure default_master(
 p_dup_set_id            IN NUMBER,
 x_master_party_id        OUT NOCOPY NUMBER,
 x_master_party_name     OUT NOCOPY VARCHAR2,
 x_return_status         OUT NOCOPY VARCHAR2,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2 ) is

	-- party with last update date
	cursor get_def_master_lu_csr(cp_status varchar2) is
		select party_id, party_name
		from(
	 		select p.party_id party_id, p.party_name party_name,
			RANK() OVER (ORDER BY p.last_update_date desc ) rank
			from hz_parties p, hz_dup_set_parties mp
			where p.party_id = mp.dup_party_id
			and mp.dup_set_id = p_dup_set_id
			and p.status = cp_status
			and nvl(mp.merge_flag,'Y') = 'Y'
			)
		where rank = 1 and rownum=1;


	-- party with latest creation date
	cursor get_def_master_lc_csr(cp_status varchar2) is
		select party_id, party_name
		from(
	 		select p.party_id party_id,p.party_name party_name,
			RANK() OVER (ORDER BY p.creation_date desc, p.party_id desc ) rank
			from hz_parties p, hz_dup_set_parties mp
			where p.party_id = mp.dup_party_id
			and mp.dup_set_id = p_dup_set_id
			and p.status = cp_status
			and nvl(mp.merge_flag,'Y') = 'Y'
			)
		where rank = 1 and rownum=1;

	-- party with earliest creation date
	cursor get_def_master_ec_csr(cp_status varchar2) is
		select party_id, party_name
		from(
	 		select p.party_id party_id,p.party_name party_name,
			RANK() OVER (ORDER BY p.creation_date, p.party_id) rank
			from hz_parties p, hz_dup_set_parties mp
			where p.party_id = mp.dup_party_id
			and mp.dup_set_id = p_dup_set_id
			and p.status = cp_status
			and nvl(mp.merge_flag,'Y') = 'Y'
			)
		where rank = 1 and rownum=1;


	-- Party with Most Accounts
	cursor get_def_master_macc_csr(cp_status varchar2) is
                select party_id, party_name
	        from
		(select party_id, party_name,rank() over (order by cnt desc) rank, last_update_date
	 	  from (
	 		SELECT
					ca.party_id party_id, party.party_name party_name,
					count(*) over (partition by ca.party_id) as cnt,
					ca.last_update_date
			from
					HZ_CUST_ACCOUNTS CA,HZ_PARTIES PARTY, HZ_DUP_SETS DS,
					HZ_DUP_SET_PARTIES DSP, HZ_DUP_BATCH DB
			WHERE CA.PARTY_ID =DSP.DUP_PARTY_ID
				AND DB.DUP_BATCH_ID = DS.DUP_BATCH_ID
				AND DS.DUP_SET_ID = DSP.DUP_SET_ID
				AND CA.PARTY_ID = PARTY.PARTY_ID
				AND DSP.DUP_SET_ID= p_dup_set_id
				AND nvl(dsp.merge_flag, 'Y') <> 'N'
				and party.status = cp_status
			)
			order by last_update_date desc )
		where rank = 1 and rownum=1;

	-- Party with Most Addresses:
	cursor get_def_master_maddr_csr(cp_status varchar2) is
        	select party_id, party_name
	        from
		(select party_id, party_name,rank() over (order by cnt desc) rank, last_update_date
	 	 from (
	 		SELECT
				ps.party_id party_id, party.party_name party_name,
				count(*) over (partition by ps.party_id) as cnt,
				ps.last_update_date
			from HZ_PARTY_SITES PS,HZ_PARTIES PARTY,
				HZ_DUP_SETS DS, HZ_DUP_SET_PARTIES DSP, HZ_DUP_BATCH DB
			WHERE PS.PARTY_ID =DSP.DUP_PARTY_ID
				AND DB.DUP_BATCH_ID = DS.DUP_BATCH_ID
				AND DS.DUP_SET_ID = DSP.DUP_SET_ID
				AND PS.PARTY_ID = PARTY.PARTY_ID
				AND DSP.DUP_SET_ID= p_dup_set_id
				AND nvl(dsp.merge_flag, 'Y') <> 'N'
				and party.status = cp_status
		)
		order by last_update_date desc )
	        where rank = 1 and rownum=1;

	-- Party with Most Relationships
	cursor get_def_master_mrel_csr(cp_status varchar2) is
                select party_id, party_name
	        from (
		    	select party_id, party_name, rank() over (order by cnt desc) rank,
				last_update_date
	 		from ( SELECT
				party.party_id party_id,
				party.party_name party_name,
				count(*) over (partition by party.party_id) as cnt,
				party.last_update_date
				from HZ_RELATIONSHIPS R,HZ_PARTIES PARTY, HZ_DUP_SETS DS,
				HZ_DUP_SET_PARTIES DSP, HZ_DUP_BATCH DB
			      WHERE PARTY.PARTY_ID =DSP.DUP_PARTY_ID
				AND DB.DUP_BATCH_ID = DS.DUP_BATCH_ID
				AND DS.DUP_SET_ID = DSP.DUP_SET_ID
				AND R.OBJECT_ID = PARTY.PARTY_ID
				AND DSP.DUP_SET_ID= p_dup_set_id
				AND nvl(dsp.merge_flag, 'Y') <> 'N'
				and party.status = cp_status
			)
			order by last_update_date desc )
	       where rank = 1 and rownum=1;

	-- Party with highest Certification:
	cursor get_def_master_hcert_csr(cp_status varchar2) is
        	select party_id, party_name
	 	from(
	 		select p.party_id party_id, p.party_name party_name,
			RANK() OVER (ORDER BY p.certification_level, p.last_update_date desc ) rank
			from hz_parties p, hz_dup_set_parties mp
			where p.party_id = mp.dup_party_id
			and mp.dup_set_id = p_dup_set_id
			and p.status = cp_status
			and nvl(mp.merge_flag,'Y') = 'Y'
		)
		where rank = 1 and rownum=1;

	cursor get_active_party_count_csr is
		select count(*)
		from hz_parties p, hz_dup_set_parties mp
		where p.party_id = mp.dup_party_id
		and mp.dup_set_id = p_dup_set_id
		and p.status = 'A';

	 cursor get_set_obj_num_csr is
   		select object_version_number
   		from HZ_DUP_SETS
   		where dup_set_id = p_dup_set_id;

	-- validate party_id and party_name combination.
	cursor  check_set_party_exist_csr(cp_party_id number, cp_party_name varchar2) is
   		select count(*)
   		from HZ_DUP_SET_PARTIES dsp, hz_parties p
   		where dsp.dup_set_id = p_dup_set_id
   		and dsp.dup_party_id = p.party_id
		and dsp.dup_party_id = cp_party_id
		and p.party_name = cp_party_name;

	-- Bug 4592273: only one active party in the set
	cursor get_active_party_csr is
		select p.party_id, p.party_name
		from hz_parties p, hz_dup_set_parties mp
		where p.party_id = mp.dup_party_id
		and mp.dup_set_id = p_dup_set_id
		and p.status = 'A'
		and rownum = 1;


l_prof_value varchar2(30);
l_active_party_cnt number;
l_status varchar2(30);
l_set_obj_version_number number;
l_master_party_id number;
l_lu_master_party_id number;
l_lu_master_party_name varchar2(360);
l_active_party_id number;
l_active_party_name varchar2(360);
l_count number;

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	open get_active_party_count_csr;
	fetch get_active_party_count_csr into l_active_party_cnt;
	close get_active_party_count_csr;
	if l_active_party_cnt = 0
	then l_status := 'I';
	else l_status := 'A';
	end if;

	/* default to last updated party if other profile returns null master*/
	open get_def_master_lu_csr(l_status);
	fetch get_def_master_lu_csr into l_lu_master_party_id, l_lu_master_party_name;
	close get_def_master_lu_csr;

	l_prof_value := nvl(fnd_profile.value('HZ_PARTY_MASTER_DEFAULT'),'MOST_ACCOUNTS');
	if l_prof_value = 'MOST_ACCOUNTS'
	then
		open get_def_master_macc_csr(l_status);
		fetch get_def_master_macc_csr into l_master_party_id, x_master_party_name;
		close get_def_master_macc_csr;
	elsif	l_prof_value = 'LATEST_UPDATE_DATE'
	then
		l_master_party_id := l_lu_master_party_id;
		x_master_party_name := l_lu_master_party_name;

	elsif	l_prof_value = 'LATEST_CREATION_DATE'
	then
		open get_def_master_lc_csr(l_status);
		fetch get_def_master_lc_csr into l_master_party_id, x_master_party_name;
		close get_def_master_lc_csr;
	elsif	l_prof_value = 'EARLIEST_CREATION_DATE'
	then
		open get_def_master_ec_csr(l_status);
		fetch get_def_master_ec_csr into l_master_party_id, x_master_party_name;
		close get_def_master_ec_csr;
	elsif l_prof_value = 'MOST_ADDRESSES'
	then
		open get_def_master_maddr_csr(l_status);
		fetch get_def_master_maddr_csr into l_master_party_id, x_master_party_name;
		close get_def_master_maddr_csr;
	elsif l_prof_value = 'MOST_RELATIONSHIPS'
	then
		open get_def_master_mrel_csr(l_status);
		fetch get_def_master_mrel_csr into l_master_party_id, x_master_party_name;
		close get_def_master_mrel_csr;
	elsif l_prof_value = 'HIGHEST_CERTIFICATION'
	then
		open get_def_master_hcert_csr(l_status);
		fetch get_def_master_hcert_csr into l_master_party_id, x_master_party_name;
		close get_def_master_hcert_csr;
	elsif l_prof_value = 'USER_HOOK'
	then
		HZ_USER_HOOK_PKG.default_master_user_hook(
  			p_dup_set_id        => p_dup_set_id,
  			x_master_party_id   => l_master_party_id,
			x_master_party_name   => x_master_party_name,
  			x_return_status     => x_return_status,
  			x_msg_count         => x_msg_count,
  			x_msg_data          => x_msg_data );

		-- validate master party id and master party name
		open check_set_party_exist_csr(l_master_party_id,x_master_party_name);
		fetch check_set_party_exist_csr into l_count;
		close check_set_party_exist_csr;

		IF l_count = 0 or l_master_party_id is null or x_master_party_name is null THEN
          		fnd_message.set_name('AR', 'HZ_DL_USER_HOOK_ERR');
          		fnd_msg_pub.add;
          		x_return_status := fnd_api.g_ret_sts_error;
          		RAISE FND_API.G_EXC_ERROR;
		end if;

	end if;

	open get_set_obj_num_csr;
	fetch get_set_obj_num_csr into l_set_obj_version_number;
	close get_set_obj_num_csr;


	if l_master_party_id is null
	then
		if l_active_party_cnt = 1 -- only one active party
		then
			open get_active_party_csr;
			fetch get_active_party_csr into l_active_party_id, l_active_party_name;
			close get_active_party_csr;
			l_master_party_id := l_active_party_id;
			x_master_party_name := l_active_party_name;
		else
			l_master_party_id := l_lu_master_party_id;
			x_master_party_name := l_lu_master_party_name;
		end if;
	end if;

     if l_master_party_id is not null -- should not be null in general
     then

	 -- update the winner party id to have merge_flag = 'Y'

	update hz_dup_set_parties
        set merge_flag = 'Y'
        where dup_set_id = p_dup_set_id
        and dup_party_id = l_master_party_id;

	update_winner_party (
   	p_dup_set_id       => p_dup_set_id
  	,p_winner_party_id  => l_master_party_id
  	,px_set_obj_version_number  => l_set_obj_version_number
  	,x_return_status   => x_return_status
  	,x_msg_count    => x_msg_count
  	,x_msg_data   => x_msg_data );
     end if;

	x_master_party_id := l_master_party_id;



EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END default_master;


-- This procedure create one dup batch, one dup set and one dup set party record
PROCEDURE create_dup (
   dup_batch_name              IN      VARCHAR2
  ,match_rule_id               IN      NUMBER
  ,application_id              IN      NUMBER
  ,request_type                IN      VARCHAR2
  ,winner_party_id             IN      NUMBER
  ,status                      IN      VARCHAR2
  ,assigned_to_user_id         IN      NUMBER
  ,merge_type                  IN      VARCHAR2
  ,party_id                    IN      NUMBER
  ,score                       IN      NUMBER
  ,merge_flag                  IN      VARCHAR2
  ,not_dup                     IN      VARCHAR2
  ,merge_seq_id                IN      NUMBER
  ,merge_batch_id              IN      NUMBER
  ,merge_batch_name            IN      VARCHAR2
  ,x_dup_batch_id              OUT NOCOPY     NUMBER
  ,x_dup_set_id                OUT NOCOPY     NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

   l_dup_batch_rec             DUP_BATCH_REC_TYPE;
   l_dup_set_rec               DUP_SET_REC_TYPE;
   l_dup_set_party_tbl         DUP_PARTY_TBL_TYPE;

   l_return_status    VARCHAR2(30);
   l_msg_data         VARCHAR2(2000);
   l_msg_count        NUMBER;

BEGIN

   savepoint create_dup_pvt;
   FND_MSG_PUB.initialize;

--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_dup_batch_rec.dup_batch_name := dup_batch_name;
   l_dup_batch_rec.match_rule_id := match_rule_id;
   l_dup_batch_rec.application_id := application_id;
   l_dup_batch_rec.request_type := request_type;
   l_dup_set_rec.winner_party_id := winner_party_id;
   l_dup_set_rec.status := status;
   l_dup_set_rec.assigned_to_user_id := assigned_to_user_id;
   l_dup_set_rec.merge_type := merge_type;
   IF(party_id IS NOT NULL) THEN
     l_dup_set_party_tbl(1).party_id := party_id;
     l_dup_set_party_tbl(1).score := score;
     l_dup_set_party_tbl(1).merge_flag := merge_flag;
     l_dup_set_party_tbl(1).not_dup := not_dup;
     l_dup_set_party_tbl(1).merge_seq_id := merge_seq_id;
     l_dup_set_party_tbl(1).merge_batch_id := merge_batch_id;
     l_dup_set_party_tbl(1).merge_batch_name := merge_batch_name;
   END IF;

   create_dup_batch(
      p_dup_batch_rec    => l_dup_batch_rec
     ,p_dup_set_rec      => l_dup_set_rec
     ,p_dup_party_tbl    => l_dup_set_party_tbl
     ,x_dup_batch_id     => x_dup_batch_id
     ,x_dup_set_id       => x_dup_set_id
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_dup_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_dup_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_dup_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END create_dup;

-- This procedure create only dup set party record
PROCEDURE create_dup_set_party (
   p_dup_set_id                IN      NUMBER
  ,p_dup_set_party_id          IN      NUMBER
  ,p_score                     IN      NUMBER
  ,p_merge_flag                IN      VARCHAR2
  ,p_not_dup                   IN      VARCHAR2
  ,p_merge_seq_id              IN      NUMBER
  ,p_merge_batch_id            IN      NUMBER
  ,p_merge_batch_name          IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

   l_dup_set_id         NUMBER;
   l_dup_set_party_id   NUMBER;
   l_score              NUMBER;
   l_not_dup            VARCHAR2(1);
   l_merge_seq_id       NUMBER;
   l_merge_batch_id     NUMBER;
   l_merge_batch_name   VARCHAR2(30);
   l_winner_type        VARCHAR2(30);
   l_cand_type          VARCHAR2(30);

   cursor get_winner_party_type(l_dset_id NUMBER) is
   select party_type
   from HZ_PARTIES a, HZ_DUP_SETS b
   where a.party_id = b.winner_party_id
   and b.dup_set_id = l_dset_id;

   cursor get_party_type(l_party_id NUMBER) is
   select party_type
   from HZ_PARTIES
   where party_id = l_party_id;

BEGIN

   savepoint create_dup_set_party_pvt;
   FND_MSG_PUB.initialize;

--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF(p_dup_set_id IS NULL OR p_dup_set_id = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN('COLUMN' ,'DUP_SET_ID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_dup_set_party_id IS NULL OR p_dup_set_party_id = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN('COLUMN' ,'DUP_SET_PARTY_ID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_dup_set_id := p_dup_set_id;
   l_dup_set_party_id := p_dup_set_party_id;

   OPEN get_winner_party_type(l_dup_set_id);
   FETCH get_winner_party_type into l_winner_type;
   CLOSE get_winner_party_type;
 ----Commented for Bug 5552118
   /*OPEN get_party_type(l_dup_set_party_id);
   FETCH get_party_type into l_cand_type;
   CLOSE get_party_type;

   IF NOT (l_winner_type = l_cand_type) THEN
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
     -- parties have different type in a merge request
       FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_PARTIES');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;*/
  ----Commented for Bug 5552118

   l_score := p_score;
   l_not_dup := p_not_dup;
   l_merge_seq_id := p_merge_seq_id;
   l_merge_batch_id := p_merge_batch_id;
   l_merge_batch_name := p_merge_batch_name;

   HZ_DUP_SET_PARTIES_PKG.Insert_Row(
      p_dup_party_id      => l_dup_set_party_id
     ,p_dup_set_id        => l_dup_set_id
     ,p_merge_flag        => 'Y'
     ,p_not_dup           => l_not_dup
     ,p_score             => l_score
     ,p_merge_seq_id      => l_merge_seq_id
     ,p_merge_batch_id    => l_merge_batch_id
     ,p_merge_batch_name  => l_merge_batch_name
     ,p_created_by        => HZ_UTILITY_V2PUB.CREATED_BY
     ,p_creation_date     => HZ_UTILITY_V2PUB.CREATION_DATE
     ,p_last_update_login => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     ,p_last_update_date  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     ,p_last_updated_by   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_dup_set_party_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_dup_set_party_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_dup_set_party_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END create_dup_set_party;

-- create records in dup batch, dup set and dup set parties
PROCEDURE create_dup_batch (
   p_dup_batch_rec             IN      DUP_BATCH_REC_TYPE
  ,p_dup_set_rec               IN      DUP_SET_REC_TYPE
  ,p_dup_party_tbl             IN      DUP_PARTY_TBL_TYPE
  ,x_dup_batch_id              OUT NOCOPY     NUMBER
  ,x_dup_set_id                OUT NOCOPY     NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

   l_dup_batch_id     NUMBER := null;
   l_dup_set_id       NUMBER := null;

   l_party_id         NUMBER;
   l_temp             VARCHAR2(1);
   l_party_type       VARCHAR2(30);
   l_temp_type        VARCHAR2(30);

   cursor get_party_type(l_party_id NUMBER) is
   select party_type
   from HZ_PARTIES
   where party_id = l_party_id;

BEGIN

   savepoint create_dup_batch_pvt;

   FND_MSG_PUB.initialize;

--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF(p_dup_batch_rec.match_rule_id IS NULL OR
      p_dup_batch_rec.match_rule_id = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_NO_MATCH_RULE' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_dup_batch_rec.request_type IS NULL OR
      p_dup_batch_rec.request_type = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN('COLUMN' ,'REQUEST_TYPE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_dup_set_rec.status IS NULL OR
      p_dup_set_rec.status = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN('COLUMN' ,'STATUS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_dup_set_rec.merge_type = 'PARTY_MERGE') THEN

     -- get the first party type
     OPEN get_party_type(p_dup_party_tbl(1).party_id);
     FETCH get_party_type INTO l_party_type;
     CLOSE get_party_type;

     -- check if the first party type is different than others
     FOR i IN 2..p_dup_party_tbl.count LOOP
       OPEN get_party_type(p_dup_party_tbl(i).party_id);
       FETCH get_party_type INTO l_temp_type;
       CLOSE get_party_type;
       IF NOT (l_party_type = l_temp_type) THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           -- parties have different type in a merge request
           FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_PARTIES');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
     END LOOP;
   END IF;

   HZ_DUP_BATCH_PKG.Insert_Row(
      px_dup_batch_id     => l_dup_batch_id
     ,p_dup_batch_name    => p_dup_batch_rec.dup_batch_name
     ,p_match_rule_id     => p_dup_batch_rec.match_rule_id
     ,p_application_id    => p_dup_batch_rec.application_id
     ,p_request_type      => p_dup_batch_rec.request_type
     ,p_created_by        => HZ_UTILITY_V2PUB.CREATED_BY
     ,p_creation_date     => HZ_UTILITY_V2PUB.CREATION_DATE
     ,p_last_update_login => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     ,p_last_update_date  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     ,p_last_updated_by   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   );

   x_dup_batch_id := l_dup_batch_id;

   HZ_DUP_SETS_PKG.Insert_Row(
      px_dup_set_id       => l_dup_set_id
     ,p_dup_batch_id      => l_dup_batch_id
     ,p_winner_party_id   => p_dup_set_rec.winner_party_id
     ,p_status            => 'SYSBATCH'
     ,p_assigned_to_user_id   => p_dup_set_rec.assigned_to_user_id
     ,p_merge_type        => p_dup_set_rec.merge_type
     ,p_object_version_number => 1
     ,p_created_by        => HZ_UTILITY_V2PUB.CREATED_BY
     ,p_creation_date     => HZ_UTILITY_V2PUB.CREATION_DATE
     ,p_last_update_login => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     ,p_last_update_date  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     ,p_last_updated_by   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   );

   x_dup_set_id := l_dup_set_id;

   FOR i IN 1..p_dup_party_tbl.count LOOP
     l_party_id := p_dup_party_tbl(i).party_id;
     HZ_DUP_SET_PARTIES_PKG.Insert_Row(
        p_dup_party_id      => l_party_id
       ,p_dup_set_id        => l_dup_set_id
       ,p_merge_flag        => 'Y'
       ,p_not_dup           => p_dup_party_tbl(i).not_dup
       ,p_score             => p_dup_party_tbl(i).score
       ,p_merge_seq_id      => p_dup_party_tbl(i).merge_seq_id
       ,p_merge_batch_id    => p_dup_party_tbl(i).merge_batch_id
       ,p_merge_batch_name  => p_dup_party_tbl(i).merge_batch_name
       ,p_created_by        => HZ_UTILITY_V2PUB.CREATED_BY
       ,p_creation_date     => HZ_UTILITY_V2PUB.CREATION_DATE
       ,p_last_update_login => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
       ,p_last_update_date  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
       ,p_last_updated_by   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   );
   END LOOP;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_dup_batch_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_dup_batch_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_dup_batch_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END create_dup_batch;

-- create records in dup set and dup set parties
PROCEDURE create_dup_set (
   p_dup_set_rec               IN      DUP_SET_REC_TYPE
  ,p_dup_party_tbl             IN      DUP_PARTY_TBL_TYPE
  ,x_dup_set_id                OUT NOCOPY     NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

   l_dup_set_id       NUMBER := null;
   l_party_id         NUMBER;
   l_temp             VARCHAR2(1);

   cursor check_dup_batch_id is
   select 'X'
   from HZ_DUP_BATCH
   where dup_batch_id = p_dup_set_rec.dup_batch_id;

BEGIN

   savepoint create_dup_set_pvt;

   FND_MSG_PUB.initialize;

--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF(p_dup_set_rec.dup_batch_id IS NULL OR
      p_dup_set_rec.dup_batch_id = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN('COLUMN' ,'DUP_BATCH_ID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN check_dup_batch_id;
   FETCH check_dup_batch_id INTO l_temp;
   IF(check_dup_batch_id%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_DUP_BATCH' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_dup_set_rec.status IS NULL OR
      p_dup_set_rec.status = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN('COLUMN' ,'STATUS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   HZ_DUP_SETS_PKG.Insert_Row(
      px_dup_set_id       => l_dup_set_id
     ,p_dup_batch_id      => p_dup_set_rec.dup_batch_id
     ,p_winner_party_id   => p_dup_set_rec.winner_party_id
     ,p_status            => 'SYSBATCH'
     ,p_assigned_to_user_id   => p_dup_set_rec.assigned_to_user_id
     ,p_merge_type        => p_dup_set_rec.merge_type
     ,p_object_version_number => 1
     ,p_created_by        => HZ_UTILITY_V2PUB.CREATED_BY
     ,p_creation_date     => HZ_UTILITY_V2PUB.CREATION_DATE
     ,p_last_update_login => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     ,p_last_update_date  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     ,p_last_updated_by   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   );

   x_dup_set_id := l_dup_set_id;

   FOR i IN 1..p_dup_party_tbl.count LOOP
     l_party_id := p_dup_party_tbl(i).party_id;
     HZ_DUP_SET_PARTIES_PKG.Insert_Row(
        p_dup_party_id      => l_party_id
       ,p_dup_set_id        => l_dup_set_id
       ,p_merge_flag        => 'Y'
       ,p_not_dup           => p_dup_party_tbl(i).not_dup
       ,p_score             => p_dup_party_tbl(i).score
       ,p_merge_seq_id      => p_dup_party_tbl(i).merge_seq_id
       ,p_merge_batch_id    => p_dup_party_tbl(i).merge_batch_id
       ,p_merge_batch_name  => p_dup_party_tbl(i).merge_batch_name
       ,p_created_by        => HZ_UTILITY_V2PUB.CREATED_BY
       ,p_creation_date     => HZ_UTILITY_V2PUB.CREATION_DATE
       ,p_last_update_login => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
       ,p_last_update_date  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
       ,p_last_updated_by   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   );
   END LOOP;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_dup_set_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_dup_set_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_dup_set_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END create_dup_set;

-- update winner_party_id in HZ_DUP_SETS table
-- and swap the master and candidate
PROCEDURE update_winner_party (
   p_dup_set_id                IN      NUMBER
  ,p_winner_party_id           IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY  NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

   l_temp                    VARCHAR2(1);
   l_set_obj_version_number  NUMBER;
   l_old_winner_party_id     NUMBER;

   cursor check_winner_party_exist is
   select 'X'
   from HZ_DUP_SET_PARTIES
   where dup_set_id = p_dup_set_id
   and dup_party_id = p_winner_party_id
   and nvl(merge_flag,'Y') = 'Y';

   cursor get_dup_sets_info is
   select winner_party_id, object_version_number
   from HZ_DUP_SETS
   where dup_set_id = p_dup_set_id;

BEGIN

   savepoint update_winner_party_pvt;

   FND_MSG_PUB.initialize;
--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN check_winner_party_exist;
   FETCH check_winner_party_exist INTO l_temp;
   IF check_winner_party_exist%NOTFOUND THEN
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       -- new winner party_id cannot be found in dup_set_parties
       FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_WINNER_PARTY');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   CLOSE check_winner_party_exist;

   OPEN get_dup_sets_info;
   FETCH get_dup_sets_info into
       l_old_winner_party_id
      ,l_set_obj_version_number;
   CLOSE get_dup_sets_info;

   -- check last_update_date of hz_dup_sets, not hz_dup_set_parties
   IF (l_set_obj_version_number IS NOT NULL) THEN
     IF (l_set_obj_version_number <> px_set_obj_version_number) THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         -- row has been changed by another user.
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
         FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DUP_SETS');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   END IF;

   px_set_obj_version_number := nvl(l_set_obj_version_number,1)+1;

   -- Swap master and candidate
   -- in hz_dup_set_parties, winner party has merge_flag = null and other
   -- candidate has merge_flag = 'Y'. So, swapping master and candidate
   -- is actually updating the merge_flag

   -- Update old winner party.  Set merge_flag = 'Y'
   UPDATE HZ_DUP_SET_PARTIES
   SET merge_flag = 'Y'
     , last_update_date = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     , last_update_login = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     , last_updated_by = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   WHERE dup_party_id = l_old_winner_party_id
   AND dup_set_id = p_dup_set_id;

-- no need to set the merge flag back to NULL for master party
   UPDATE HZ_DUP_SET_PARTIES
   SET last_update_date = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     , last_update_login = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     , last_updated_by = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   WHERE dup_party_id = p_winner_party_id
   AND dup_set_id = p_dup_set_id;

   BEGIN
     -- clean up merge batch tables
     DELETE HZ_MERGE_PARTY_DETAILS
     WHERE batch_party_id
       in (select batch_party_id
           from HZ_MERGE_PARTIES mp
           where mp.batch_id = p_dup_set_id);
     DELETE HZ_MERGE_BATCH WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_PARTIES WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_ENTITY_ATTRIBUTES WHERE merge_batch_id = p_dup_set_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
   END;

-- not doing any update to HZ_DUP_SETS status since user may
-- be in create merge request flow and status should remain
-- the same.  For merge multiple party flow, the update call
-- will be followed by submit_dup call which will update the
-- status to 'PREPROCESS' when successfully call conc request

   UPDATE HZ_DUP_SETS
   SET winner_party_id = p_winner_party_id
     , last_update_date = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     , last_update_login = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     , last_updated_by = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
     , object_version_number = px_set_obj_version_number
   WHERE dup_set_id = p_dup_set_id;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_winner_party_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_winner_party_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO update_winner_party_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END update_winner_party;

PROCEDURE delete_dup_party (
   p_dup_set_id                IN      NUMBER
  ,p_dup_party_id              IN      NUMBER
  ,p_new_winner_party_id       IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY  NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

  CURSOR get_dup_sets_info IS
  select winner_party_id, object_version_number
  from HZ_DUP_SETS
  where dup_set_id = p_dup_set_id;

  CURSOR check_winner_party(x_party_id NUMBER) IS
  select 'X'
  from HZ_DUP_SETS
  where winner_party_id = x_party_id
  and dup_set_id = p_dup_set_id;

  CURSOR check_dup_party(x_party_id NUMBER) IS
  select 'X'
  from HZ_DUP_SET_PARTIES
  where dup_set_id = p_dup_set_id
  and dup_party_id = x_party_id;

  l_check                    VARCHAR2(1);
  l_winner_party_id          NUMBER;
  l_set_obj_version_number   NUMBER;

BEGIN

   savepoint delete_dup_party_pvt;

   FND_MSG_PUB.initialize;
--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN get_dup_sets_info;
   FETCH get_dup_sets_info into
       l_winner_party_id
      ,l_set_obj_version_number;
   CLOSE get_dup_sets_info;

   -- check last_update_date of hz_dup_sets, not hz_dup_set_parties
   IF (l_set_obj_version_number IS NOT NULL) THEN
     IF (l_set_obj_version_number <> px_set_obj_version_number) THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         -- row has been changed by another user.
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
         FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DUP_SETS');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   END IF;

   px_set_obj_version_number := nvl(l_set_obj_version_number,1)+1;

   IF(p_new_winner_party_id IS NULL) THEN
     -- delete candidate only
     OPEN check_winner_party(p_dup_party_id);
     FETCH check_winner_party INTO l_check;
     IF check_winner_party%FOUND THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         -- cannot remove winner party without specifying a new winner party
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
         FND_MESSAGE.SET_TOKEN('COLUMN' ,'NEW_WINNER_PARTY_ID');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
     CLOSE check_winner_party;

     UPDATE HZ_DUP_SETS
     set object_version_number = px_set_obj_version_number
       , last_update_date = hz_utility_v2pub.last_update_date
       , last_updated_by = hz_utility_v2pub.last_updated_by
       , last_update_login = hz_utility_v2pub.last_update_login
     where dup_set_id = p_dup_set_id;

     -- remove dup party
     UPDATE HZ_DUP_SET_PARTIES
     SET merge_flag = 'N'
       , last_update_date = hz_utility_v2pub.last_update_date
       , last_updated_by = hz_utility_v2pub.last_updated_by
       , last_update_login = hz_utility_v2pub.last_update_login
     WHERE dup_set_id = p_dup_set_id
     AND dup_party_id = p_dup_party_id;

   ELSE
     -- delete winner party and specify new winner party also
     OPEN check_winner_party(p_dup_party_id);
     FETCH check_winner_party INTO l_check;
     IF check_winner_party%FOUND THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         -- cannot remove winner party without specifying a new winner party
         FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_WINNER_PARTY');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
     CLOSE check_winner_party;

     OPEN check_dup_party(p_new_winner_party_id);
     FETCH check_dup_party INTO l_check;
     IF check_dup_party%NOTFOUND THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         -- cannot remove winner party without specifying a new winner party
         FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DUP_PARTY');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
     CLOSE check_dup_party;

     UPDATE HZ_DUP_SETS
     set winner_party_id = p_new_winner_party_id
       , object_version_number = px_set_obj_version_number
       , last_update_date = hz_utility_v2pub.last_update_date
       , last_updated_by = hz_utility_v2pub.last_updated_by
       , last_update_login = hz_utility_v2pub.last_update_login
     where dup_set_id = p_dup_set_id;

     UPDATE HZ_DUP_SET_PARTIES
     SET merge_flag = 'N'
       , last_update_date = hz_utility_v2pub.last_update_date
       , last_updated_by = hz_utility_v2pub.last_updated_by
       , last_update_login = hz_utility_v2pub.last_update_login
     WHERE dup_set_id = p_dup_set_id
     AND dup_party_id = p_dup_party_id;

   END IF;

   BEGIN
   -- clean up merge batch tables
     DELETE HZ_MERGE_PARTY_DETAILS
     WHERE batch_party_id
       in (select batch_party_id
           from HZ_MERGE_PARTIES mp
           where mp.batch_id = p_dup_set_id);
     DELETE HZ_MERGE_BATCH WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_PARTIES WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_ENTITY_ATTRIBUTES WHERE merge_batch_id = p_dup_set_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
   END;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_dup_party_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_dup_party_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO delete_dup_party_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END delete_dup_party;

--
-- Reset merge_type of HZ_DUP_SETS and hard delete candidate which has merge_flag = 'N'
-- this procedure is used in system duplicate identification flow
--
-- If a duplicate set found by system duplicate identification program has more than
-- one party involved, the merge_type of this dup set is set to PARTY_MERGE.  Howvever,
-- on UI, user is allowed to remove candidates from a dup set.  If user removed all
-- candidates except master and click submit to create merge request.  The merge_type of
-- dup set should be restamped as 'SAME_PARTY_MERGE' for single party.  All candidates
-- should be removed except the master in HZ_DUP_SET_PARTIES.
--
PROCEDURE reset_merge_type (
   p_dup_set_id                IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY  NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

  CURSOR get_dup_sets_info IS
  select winner_party_id, object_version_number
  from HZ_DUP_SETS
  where dup_set_id = p_dup_set_id;

  CURSOR check_only_master IS
  select count(1)
  from HZ_DUP_SET_PARTIES
  where dup_set_id = p_dup_set_id;

  CURSOR check_winner_party IS
  select 'X'
  from HZ_DUP_SETS
  where winner_party_id =
  ( select dup_party_id
    from HZ_DUP_SET_PARTIES
    where dup_set_id = p_dup_set_id
    and nvl(merge_flag,'Y') <> 'N' )
  and dup_set_id = p_dup_set_id;

  l_check                    VARCHAR2(1);
  l_winner_party_id          NUMBER;
  l_set_obj_version_number   NUMBER;
  l_count                    NUMBER;

BEGIN

   savepoint reset_merge_type_pvt;

   FND_MSG_PUB.initialize;
--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN get_dup_sets_info;
   FETCH get_dup_sets_info into
       l_winner_party_id
      ,l_set_obj_version_number;
   CLOSE get_dup_sets_info;

   -- check last_update_date of hz_dup_sets, not hz_dup_set_parties
   IF (l_set_obj_version_number IS NOT NULL) THEN
     IF (l_set_obj_version_number <> px_set_obj_version_number) THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         -- row has been changed by another user.
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
         FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DUP_SETS');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   END IF;

   px_set_obj_version_number := nvl(l_set_obj_version_number,1)+1;

   OPEN check_winner_party;
   FETCH check_winner_party INTO l_check;
   IF check_winner_party%NOTFOUND THEN
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
     -- the remain party in HZ_DUP_SET_PARTIES which has merge_flag <> 'N'
     -- is not the same as the winner_party_id in HZ_DUP_SETS
       FND_MESSAGE.SET_NAME('AR', 'HZ_DL_SEL_MASTER');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   CLOSE check_winner_party;

   BEGIN
     UPDATE HZ_DUP_SETS
     set merge_type = 'SAME_PARTY_MERGE'
       , object_version_number = px_set_obj_version_number
       , last_update_date = hz_utility_v2pub.last_update_date
       , last_updated_by = hz_utility_v2pub.last_updated_by
       , last_update_login = hz_utility_v2pub.last_update_login
     where dup_set_id = p_dup_set_id;

     DELETE HZ_DUP_SET_PARTIES
     where dup_party_id not in
     ( select winner_party_id
       from HZ_DUP_SETS
       where dup_set_id = p_dup_set_id )
     and dup_set_id = p_dup_set_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
   END;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO reset_merge_type_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO reset_merge_type_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO reset_merge_type_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END reset_merge_type;

PROCEDURE reject_merge (
   p_dup_set_id                IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY  NUMBER
  ,p_init_msg_list             IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2 )
IS

   cursor get_dup_sets_info is
   select winner_party_id, object_version_number
   from HZ_DUP_SETS
   where dup_set_id = p_dup_set_id;

   l_winner_party_id        NUMBER;
   l_set_obj_version_number NUMBER;

BEGIN

   savepoint reject_merge_pvt;

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
   END IF;

--Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN get_dup_sets_info;
   FETCH get_dup_sets_info into
       l_winner_party_id
      ,l_set_obj_version_number;
   CLOSE get_dup_sets_info;

   -- check last_update_date of hz_dup_sets, not hz_dup_set_parties
   IF (l_set_obj_version_number IS NOT NULL) THEN
     IF (l_set_obj_version_number <> px_set_obj_version_number) THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         -- row has been changed by another user.
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
         FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DUP_SETS');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   END IF;

   px_set_obj_version_number := nvl(l_set_obj_version_number,1)+1;

   BEGIN
     -- clean up merge batch tables
     DELETE HZ_MERGE_PARTY_DETAILS
     WHERE batch_party_id
       in (select batch_party_id
           from HZ_MERGE_PARTIES mp
           where mp.batch_id = p_dup_set_id);
     DELETE HZ_MERGE_BATCH WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_PARTIES WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_ENTITY_ATTRIBUTES WHERE merge_batch_id = p_dup_set_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
   END;

   UPDATE HZ_DUP_SETS
   set status = 'REJECTED'
     , object_version_number = px_set_obj_version_number
     , last_update_date = hz_utility_v2pub.last_update_date
     , last_updated_by = hz_utility_v2pub.last_updated_by
     , last_update_login = hz_utility_v2pub.last_update_login
   where dup_set_id = p_dup_set_id;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO reject_merge_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO reject_merge_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO reject_merge_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END reject_merge;

procedure set_default_assign_to_user(p_dup_set_id in number) is

	cursor get_dl_resp_user_csr is
	select u.USER_ID
	from
		FND_USER u,
		wf_local_user_roles wur,
		FND_RESPONSIBILITY r,
		FND_MENU_ENTRIES m,
		FND_MENU_ENTRIES mp,
		FND_MENUS_VL mv
	where wur.user_name = u.user_name
		and wur.ROLE_ORIG_SYSTEM_ID  = r.responsibility_id
		and wur.role_orig_system = 'FND_RESP'
		and not wur.role_name like 'FND_RESP|%|ANY'
 		and wur.partition_id = 2
 		and ( ( ( wur.start_date is NULL )
    		or ( trunc ( sysdate ) >= trunc ( wur.start_date ) ) )
 		and ( ( wur.expiration_date is NULL )
    		or ( trunc ( sysdate ) < trunc ( wur.expiration_date ) ) )
 		and ( ( wur.user_start_date is NULL )
    		or ( trunc ( sysdate ) >= trunc ( wur.user_start_date ) ) )
 		and ( ( wur.user_end_date is NULL )
    		or ( trunc ( sysdate ) < trunc ( wur.user_end_date ) ) )
 		and ( ( wur.role_start_date is NULL )
    		or ( trunc ( sysdate ) >= trunc ( wur.role_start_date ) ) )
 		and ( ( wur.role_end_date is NULL )
    		or ( trunc ( sysdate ) < trunc ( wur.role_end_date ) ) ) )
		and r.menu_id = mp.menu_id
		and mp.sub_menu_id = m.menu_id
		and m.sub_menu_id = mv.menu_id
		and mv.menu_name = 'IMC_NG_DATA_QUALITY'
		and u.user_id = HZ_UTILITY_V2PUB.CREATED_BY
		and not exists (
		select 'X'
		from FND_RESP_FUNCTIONS rf, FND_MENUS m
		where rf.action_id = m.menu_id
		and r.responsibility_id = rf.responsibility_id
		and m.menu_name = 'IMC_NG_DATA_QUALITY'
		and rf.rule_type = 'M')
		and rownum = 1;

l_user_id number;

begin
	open get_dl_resp_user_csr;
	fetch get_dl_resp_user_csr into l_user_id;
	close get_dl_resp_user_csr;

	if l_user_id is not null
	then

		UPDATE HZ_DUP_SETS
   		SET assigned_to_user_id = l_user_id
     		, last_update_date = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     		, last_update_login = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     		, last_updated_by = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
     		, object_version_number = object_version_number+1
   		WHERE dup_set_id = p_dup_set_id;
	end if;

end;


PROCEDURE submit_dup (
   p_dup_set_id        IN NUMBER
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2
)
IS

  l_request_id            NUMBER := NULL;

  l_last_request_id       NUMBER;
  l_conc_phase            VARCHAR2(80);
  l_conc_status           VARCHAR2(80);
  l_conc_dev_phase        VARCHAR2(30);
  l_conc_dev_status       VARCHAR2(30);
  l_message               VARCHAR2(240);
  call_status             boolean;
  l_dup_status            VARCHAR2(30);
  retcode number;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;

  SAVEPOINT submit_dup;

  SELECT status , request_id
  INTO  l_dup_status ,l_last_request_id
  FROM hz_dup_sets
  WHERE dup_set_id = p_dup_set_id;

  IF l_last_request_id IS NOT NULL THEN
     call_status := FND_CONCURRENT.GET_REQUEST_STATUS(
                        request_id  => l_last_request_id,
                        phase       => l_conc_phase,
                        status      => l_conc_status,
                        dev_phase   => l_conc_dev_phase,
                        dev_status  => l_conc_dev_status,
                        message     => l_message ) ;

     IF l_conc_dev_phase <> 'COMPLETE' THEN
       FND_MESSAGE.set_name('AR', 'HZ_CANNOT_SUBMIT_PROCESSING');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     ELSE
       IF l_conc_status <>'NORMAL' THEN
         l_request_id := fnd_request.submit_request('AR','ARHDUPB','Create Merge Batch',to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                    FALSE,p_dup_set_id );

         IF l_request_id = 0 THEN
           FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_request_id is not null Then
           UPDATE HZ_DUP_SETS
           SET status = 'PREPROCESS',
             request_id = l_request_id,
             LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
             LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
           WHERE  dup_set_id = p_dup_set_id;
         END IF;

       ELSE  --if completed normally
         FND_MESSAGE.set_name('AR', 'HZ_CANNOT_SUBMIT_REQUEST');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF; --l_conc_status
     END IF;     --l_conc_dev_phase
  ELSE      ---last_request_id is null
     l_request_id := fnd_request.submit_request('AR','ARHDUPB','Create Merge Batch',to_char(sysdate,'DD-MON-YY HH24:MI:SS')
                  ,FALSE,p_dup_set_id );

     IF l_request_id = 0 THEN
          FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_request_id is not null Then
         UPDATE HZ_DUP_SETS
         SET status = 'PREPROCESS',
             request_id = l_request_id,
             LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
             LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
         WHERE  dup_set_id = p_dup_set_id;
     END IF;
   END IF; ---last_request_id

   set_default_assign_to_user(p_dup_set_id);

   x_request_id := l_request_id;

   -- standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to submit_dup;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to submit_dup;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to submit_dup;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END submit_dup;

PROCEDURE create_merge (
   Errbuf                      OUT NOCOPY     VARCHAR2
  ,Retcode                     OUT NOCOPY     VARCHAR2
  ,p_dup_set_id                IN      NUMBER )

IS

   l_dup_set_id             NUMBER;
   l_merge_batch_id         NUMBER;
   l_return_status          VARCHAR2(30);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_dummy                  VARCHAR2(1);
   l_set_obj_version_number NUMBER;
   l_default_mapping         VARCHAR2(1) DEFAULT 'Y';--Bug 5635453

   cursor check_merge_batch is
   select 'X'
   from HZ_MERGE_BATCH mb, HZ_MERGE_PARTIES mp
   where mb.batch_id = mp.batch_id
   and mb.batch_id = p_dup_set_id;

   cursor get_dup_set_obj_version is
   select nvl(object_version_number,-1)
   from HZ_DUP_SETS
   where dup_set_id = p_dup_set_id;

BEGIN

   -- Stamp concurrent request id to dup sets
   UPDATE HZ_DUP_SETS
   SET REQUEST_ID = hz_utility_v2pub.request_id
   WHERE dup_set_id = p_dup_set_id;
   COMMIT;

   savepoint create_merge_pvt;

   FND_MSG_PUB.initialize;

   FND_FILE.PUT_LINE (FND_FILE.LOG, 'Create Merge Batch concurrent program');
   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
   FND_FILE.PUT_LINE (FND_FILE.LOG, 'Parameters - ');
   FND_FILE.PUT_LINE (FND_FILE.LOG, 'Merge ID : '||p_dup_set_id);
   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

   FND_FILE.PUT_LINE (FND_FILE.LOG, 'Start: validate_overlapping_merge_req');
   HZ_MERGE_DUP_PVT.validate_overlapping_merge_req(
	p_dup_set_id     => p_dup_set_id,
	p_merge_batch_id => null,
	p_init_msg_list  => FND_API.G_FALSE,
        p_reject_req_flag => 'Y',
	x_return_status  => l_return_status,
	x_msg_count      => l_msg_count,
	x_msg_data       => l_msg_data);

   FND_FILE.PUT_LINE (FND_FILE.LOG, 'End: validate_overlapping_merge_req');
   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

   /* error messages have been pushed into message stack in above procedure */
   IF l_return_status = 'E' THEN
     RAISE  FND_API.G_EXC_ERROR;
   ELSIF l_return_status = 'U' THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_dup_set_id := p_dup_set_id;

   OPEN get_dup_set_obj_version;
   FETCH get_dup_set_obj_version into l_set_obj_version_number;
   CLOSE get_dup_set_obj_version;

   IF(l_set_obj_version_number = -1) THEN
     l_set_obj_version_number := NULL;
   END IF;

   -- check if the merge batch is already created
   open check_merge_batch;
   fetch check_merge_batch into l_dummy;
   if(check_merge_batch%NOTFOUND) then

     BEGIN

       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       --FND_FILE.PUT_LINE (FND_FILE.LOG, 'Checking Profile Value for HZ_DL_DQM_MERGE_SUGG');
 	        --Bug 5635453
 	        fnd_profile.get(
 	       name   => 'HZ_DL_DQM_MERGE_SUGG',
 	       val    => l_default_mapping
 	       );

 	       If (NVL(l_default_mapping,'Y') <>'N') THEN
 	       l_default_mapping := 'Y';
 	       END IF;

 	        --Bug 5635453
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'Start: create_merge_batch');
       HZ_MERGE_DUP_PVT.create_merge_batch (
          p_dup_set_id            => l_dup_set_id
         ,p_default_mapping       => l_default_mapping--Bug 5635453
         ,p_object_version_number => l_set_obj_version_number
         ,x_merge_batch_id        => l_merge_batch_id
         ,x_return_status         => l_return_status
         ,x_msg_count             => l_msg_count
         ,x_msg_data              => l_msg_data
       );
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'End: create_merge_batch');
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

     EXCEPTION
       WHEN OTHERS THEN
         l_return_status := 'U';
         NULL;
     END;

     IF(l_set_obj_version_number = -1) THEN
       l_set_obj_version_number := 2;
     ELSE
       l_set_obj_version_number := l_set_obj_version_number + 1;
     END IF;

     IF (l_return_status = 'E') THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'HZ_DUP_PVT.create_merge expected error. ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       RAISE FND_API.G_EXC_ERROR;
     ELSIF (l_return_status = 'U') THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'HZ_DUP_PVT.create_merge unexpected error. ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = 'S') THEN
       UPDATE HZ_DUP_SETS
       set status = 'REQUESTED'
         , last_update_date = hz_utility_v2pub.last_update_date
         , last_updated_by = hz_utility_v2pub.last_updated_by
         , last_update_login = hz_utility_v2pub.last_update_login
       where dup_set_id = l_dup_set_id;
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'call create_merge_batch without error. ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       COMMIT;
     END IF; -- return_status
   else
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'merge batch/parties exists. ');
       FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
       RAISE FND_API.G_EXC_ERROR;
   end if; -- check_merge_batch
   close check_merge_batch;

   FND_FILE.PUT_LINE (FND_FILE.LOG, 'validate_overlapping_merge_req second try');
   HZ_MERGE_DUP_PVT.validate_overlapping_merge_req(
	p_dup_set_id     => p_dup_set_id,
	p_merge_batch_id => null,
	p_init_msg_list  => FND_API.G_FALSE,
        p_reject_req_flag => 'Y',
	x_return_status  => l_return_status,
	x_msg_count      => l_msg_count,
	x_msg_data       => l_msg_data);

   FND_FILE.PUT_LINE (FND_FILE.LOG, 'End: validate_overlapping_merge_req second try');
   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

   /* error messages have been pushed into message stack in above procedure */
   IF l_return_status = 'E' THEN
     RAISE  FND_API.G_EXC_ERROR;
   ELSIF l_return_status = 'U' THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_merge_pvt;
     UPDATE HZ_DUP_SETS
     SET STATUS = 'ERROR'
     WHERE DUP_SET_ID = p_dup_set_id;
     COMMIT;
     Retcode := 2;
     log('HZ_DUP_PVT.create_merge - Expected Error Encountered');
     log(' ');
     Errbuf := logerror(SQLERRM);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_merge_pvt;
     UPDATE HZ_DUP_SETS
     SET STATUS = 'ERROR'
     WHERE DUP_SET_ID = p_dup_set_id;
     COMMIT;
     Retcode := 2;
     log('HZ_DUP_PVT.create_merge - Unexpected Error Encountered');
     log(' ');
     Errbuf := logerror(SQLERRM);

   WHEN OTHERS THEN
     ROLLBACK TO create_merge_pvt;
     UPDATE HZ_DUP_SETS
     SET STATUS = 'ERROR'
     WHERE DUP_SET_ID = p_dup_set_id;
     COMMIT;
     Retcode := 2;
     log('HZ_DUP_PVT.create_merge - Others Error Encountered');
     log(' ');
     Errbuf := logerror(SQLERRM);

END create_merge;

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

/*-----------------------------------------------------------------------
 | Function to fetch messages of the stack and log the error
 | Also returns the error
 |-----------------------------------------------------------------------*/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

PROCEDURE validate_party_modeling( p_party_ids    IN   VARCHAR2,
                                   x_cert_warn     OUT NOCOPY VARCHAR2,
				   x_reln_warn     OUT NOCOPY VARCHAR2,
				   x_reln_token    OUT NOCOPY VARCHAR2
				 )
IS
  l_count NUMBER;
  l_prev_hier_type VARCHAR2(30);
  l_prev_parent_id NUMBER;
  l_token_str      VARCHAR2(4000);
  l_regid_str      VARCHAR2(2000);
  TYPE c_ref IS REF CURSOR;
  c_cursor c_ref;
  l_parent_id NUMBER;
  l_child_id  NUMBER;
  l_top_parent_flag varchar2(1);
  l_level_number NUMBER;
  l_hierarchy_type  VARCHAR2(30);
  l_parent_reg_id  VARCHAR2(30);
  l_child_reg_id  VARCHAR2(30);
  l_prev_par_reg_id   VARCHAR2(30);
BEGIN

  ---Per PM, take out Party Modeling for Certification Level
/*   OPEN c_cursor for 'select count(*) '||
		    ' from  HZ_PARTIES pa '||
		    ' where pa.certification_level = 100  '||
		    ' and   pa.party_id IN ('||p_party_ids||')';
  FETCH c_cursor INTO l_count;
  if (l_count > 1) then
     x_cert_warn := 'HZ_PMODEL_PROTECT_CERT_WARN';
   end if;
  CLOSE c_cursor;  */

 IF NVL(fnd_profile.value('HZ_DL_PROTECT_PARTY_MODELING'), 'Y') = 'Y' THEN
  l_count := 0;
  ---Party Modeling for relationship Hierarchy
  open c_cursor FOR ' select distinct parent_id,child_id,nvl(top_parent_flag,''N'') top_parent_flag,level_number,hierarchy_type,'||
		    '                p1.party_number parent_reg_id,p2.party_number child_reg_id '||
		    ' from hz_hierarchy_nodes h,hz_parties p1,hz_parties p2 '||
		    ' where EXISTS (select 1 from hz_hierarchy_nodes h2 '||
		    '               where h2.parent_id = h.parent_id '||
		    '               and   h2.hierarchy_type = h.hierarchy_type '||
		    '	            and   nvl(h2.top_parent_flag,''N'') = ''Y'' '||
		    '	            and   h2.level_number = 0 '||
		    '              )'||
		    ' and   h.parent_id = p1.party_id'||
		    ' and   h.child_id  = p2.party_id'||
		    ' and   (nvl(top_parent_flag,''N'')=''N'' and level_number <> 0) '||
		    ' and    h.child_id IN ('|| p_party_ids ||')'||
		    ' and  sysdate between h.effective_start_date and h.effective_end_date'||
		    ' order by hierarchy_type,parent_id,nvl(top_parent_flag,''N'') desc,level_number';
  LOOP
    FETCH c_cursor INTO l_parent_id,l_child_id,l_top_parent_flag,l_level_number,l_hierarchy_type,l_parent_reg_id,l_child_reg_id;
    EXIT WHEN c_cursor%NOTFOUND;
    IF(l_parent_id <> l_child_id) THEN
      IF(l_prev_hier_type IS NULL OR l_prev_hier_type <> l_hierarchy_type) THEN
         IF(l_count > 0 OR nvl(instr(l_regid_str,l_prev_par_reg_id),0) > 0 ) THEN /* to handle the cases like C is child of A in hierarchy H1 */
           l_token_str := rtrim(l_token_str,',') || l_regid_str;	          /* and C is child of B in hierarchy H2 and A and C are in the merge. */
	   l_regid_str := null;
	 END IF;
	 IF(nvl(instr(p_party_ids,l_parent_id),0) > 0) THEN
  	   l_regid_str :='& '||l_parent_reg_id||','||l_child_reg_id||',';
         ELSE
           l_regid_str :='& '||l_child_reg_id||',';
	 END IF;
	 l_count := 0;
      ELSE
         IF(l_prev_parent_id IS NULL OR l_parent_id <> l_prev_parent_id) THEN
	   IF(nvl(instr(l_regid_str,l_parent_reg_id),0) = 0) THEN
	     IF(l_count > 0 OR nvl(instr(l_regid_str,l_prev_par_reg_id),0) > 0 ) THEN
              l_token_str := rtrim(l_token_str,',') || l_regid_str;
	      l_regid_str := null;
             END IF;
   	     IF(nvl(instr(p_party_ids,l_parent_id),0) > 0) THEN
  	       l_regid_str :='& '||l_parent_reg_id||','||l_child_reg_id||',';
             ELSE
               l_regid_str :='& '||l_child_reg_id||',';
	     END IF;
	   END IF;
         END IF;
         IF(nvl(instr(l_regid_str,l_child_reg_id),0) = 0) THEN
  	   l_regid_str := l_regid_str || l_child_reg_id||',';
	   l_count := l_count+1;
	 END IF;
      END IF;
      l_prev_parent_id   := l_parent_id;
      l_prev_par_reg_id  := l_parent_reg_id;
      l_prev_hier_type   := l_hierarchy_type;
    END IF;
  END LOOP;
 if(c_cursor%ISOPEN )then
  close c_cursor;
 end if;
  IF(l_regid_str IS NOT NULL AND (l_count > 0 OR nvl(instr(l_regid_str,l_parent_reg_id),0) > 0)) THEN
   l_token_str := rtrim(l_token_str,',') || l_regid_str;
  END IF;
  IF(l_token_str IS NOT NULL) THEN
    l_token_str := rtrim(l_token_str,',');
    x_reln_token := l_token_str;
    x_reln_warn  := 'HZ_PMODEL_PROTECT_REL_WARN';
  END IF;
 end if; -- if nvl(fnd_profile.value...
END;

FUNCTION get_automerge_candidate(p_party_score NUMBER, p_automerge_score NUMBER)
	RETURN VARCHAR2 IS
BEGIN
	If (p_party_score >= p_automerge_score) THEN
    	RETURN 'Y';
  	ELSE
		RETURN 'N';
  	END IF;
END;

FUNCTION get_update_flag(x_dup_set_id NUMBER)
	RETURN VARCHAR2 IS
update_count NUMBER;
CURSOR update_dupset(p_dup_set_id NUMBER) IS
select count(*) from hz_dup_set_parties where dup_set_id=p_dup_set_id and remove_flag is not null;
BEGIN
 open update_dupset(x_dup_Set_id);
 fetch update_dupset into update_count;
 close update_dupset;

  	If ( update_count>0) THEN
    	RETURN 'Y';
  	ELSE
		RETURN 'N';
  	END IF;
END;

procedure party_merge_dss_check(p_merge_batch_id in number,
			    x_dss_update_flag out nocopy varchar2,
			    x_return_status   OUT NOCOPY VARCHAR2,
  			    x_msg_count       OUT NOCOPY NUMBER,
  			    x_msg_data        OUT NOCOPY VARCHAR2 ) is

	cursor get_merge_parties_csr is
		select party_id
		from hz_merge_parties mp, hz_parties party
		where (party.party_id = mp.from_party_id or party.party_id = mp.to_party_id)
		and mp.batch_id = p_merge_batch_id;

l_party_id number;
dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
dss_msg_count     NUMBER := 0;
dss_msg_data      VARCHAR2(2000):= null;
l_test_security   VARCHAR2(1):= 'F';
l_dl_dss_prof  VARCHAR2(1);

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	FND_MSG_PUB.initialize;

	x_dss_update_flag := 'Y';
	l_dl_dss_prof := NVL(fnd_profile.value('HZ_DL_DISPLAY_LOCK'), 'N');
	open get_merge_parties_csr;
	loop
		fetch get_merge_parties_csr into l_party_id;
		exit when get_merge_parties_csr%notfound;

		-- DSS Check if dss profile enabled and dl dss rule is not set to F(do not check DSS)
    		IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' and l_dl_dss_prof <> 'F' THEN

      			l_test_security := hz_dss_util_pub.test_instance(
                  		p_operation_code     => 'UPDATE',
                  		p_db_object_name     => 'HZ_PARTIES',
                  		p_instance_pk1_value => l_party_id,
                  		p_user_name          => fnd_global.user_name,
                  		x_return_status      => dss_return_status,
                  		x_msg_count          => dss_msg_count,
                  		x_msg_data           => dss_msg_data);

      			if dss_return_status <> fnd_api.g_ret_sts_success THEN
				x_dss_update_flag := 'N';
         			RAISE FND_API.G_EXC_ERROR;
      			end if;

      			if (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) then

				if l_dl_dss_prof = 'S'
				then -- show error at submission
					FND_MESSAGE.SET_NAME('AR', 'HZ_DL_MERGE_PROTECTION');

				else -- show error at mapping
					FND_MESSAGE.SET_NAME('AR', 'HZ_DL_DSS_NO_PRIVILEGE');
				end if;

         			FND_MSG_PUB.ADD;
				x_dss_update_flag := 'N';
 				close get_merge_parties_csr;
         			RAISE FND_API.G_EXC_ERROR;
      			end if;
    		END IF;
	end loop;
        close get_merge_parties_csr;

   -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        return; -- only find one is ok
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
end party_merge_dss_check;

function show_dss_lock(p_dup_set_id in number) return varchar2 is

l_dss_update_flag varchar2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

begin
	if NVL(fnd_profile.value('HZ_DL_DISPLAY_LOCK'), 'N') = 'Y'
	then
		party_merge_dss_check(p_merge_batch_id => p_dup_set_id,
			    x_dss_update_flag => l_dss_update_flag,
			    x_return_status   => l_return_status,
  			    x_msg_count       => l_msg_count,
  			    x_msg_data        => l_msg_data);
		if l_dss_update_flag = 'N'
		then return 'Y';
		else return 'N';
		end if;
	else
		-- in ('F'(no dss check),'N'(check dss at mapping and don't show access column),'S'(only check dss at submission)
		return 'N';
	end if;
end show_dss_lock;

PROCEDURE reprocess_merge_request (
   p_dup_set_id        IN NUMBER
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2 ) is

	cursor validate_reprocess_req_csr is
		select count(*)
		from hz_dup_sets
		where status in ('REJECTED', 'COMPLETED','SUBMITTED')
		and dup_set_id = p_dup_set_id;
l_count number;
begin

   FND_MSG_PUB.initialize;
   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open validate_reprocess_req_csr;
   fetch validate_reprocess_req_csr into l_count;
   close validate_reprocess_req_csr;

   if l_count > 0
   then
	FND_MESSAGE.SET_NAME( 'AR', 'HZ_MRQ_REPROCESS_ERR' );
      	FND_MSG_PUB.ADD;
      	RAISE FND_API.G_EXC_ERROR;
   end if;

   begin
   -- clean up merge batch tables
     DELETE HZ_MERGE_PARTY_DETAILS
     WHERE batch_party_id
       in (select batch_party_id
           from HZ_MERGE_PARTIES mp
           where mp.batch_id = p_dup_set_id);
     DELETE HZ_MERGE_BATCH WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_PARTIES WHERE batch_id = p_dup_set_id;
     DELETE HZ_MERGE_ENTITY_ATTRIBUTES WHERE merge_batch_id = p_dup_set_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
   end;

   submit_dup (
   p_dup_set_id    => p_dup_set_id
  ,x_request_id    => x_request_id
  ,x_return_status => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);


end reprocess_merge_request;

procedure reset_dup_set_status is

	cursor get_submitted_count_csr is
		select count(*)
		from hz_dup_sets
		where status = 'SUBMITTED'
		and rownum = 1; /* as long as we have one submitted status */
l_count number;
begin

	open get_submitted_count_csr;
	fetch get_submitted_count_csr into l_count;
	close get_submitted_count_csr;

	if l_count > 0
	then
	  update hz_dup_sets
	  set status = 'ERROR'
	  where dup_set_id in
	  (select dup_set_id
		from HZ_MERGE_BATCH mb,
		HZ_DUP_SETS ds,
		Fnd_Concurrent_Requests r,
		FND_CONCURRENT_PROGRAMS cp
	where
 	mb.batch_id = ds.dup_set_id
 	and R.Program_Application_ID = 222
	and r.request_id = mb.request_id
	and cp.application_id = R.Program_Application_ID
	and cp.concurrent_program_id = r.concurrent_program_id
	and cp.concurrent_program_name = 'ARHPMERGE'
	and r.phase_code = 'C'
	and  ds.status ='SUBMITTED');


	/* handle the case that requests have been deleted from the Fnd_Concurrent_Requests*/

	update hz_dup_sets
	  set status = 'ERROR'
	  where dup_set_id in
		(select dup_set_id
		from HZ_MERGE_BATCH mb,
		HZ_DUP_SETS ds,
		Fnd_Concurrent_Requests r
		where
		 mb.batch_id = ds.dup_set_id
		and r.request_id(+) = mb.request_id
		and  ds.status ='SUBMITTED'
		and r.request_id is null);

	commit;

    end if;

end  reset_dup_set_status;

procedure get_match_rule_thresholds(p_match_rule_id in number,
				    x_match_threshold out nocopy number,
				    x_automerge_threshold out nocopy number) is

	cursor get_match_rule_thresholds_csr is
		select match_score, nvl(auto_merge_score, 101)
	        from hz_match_rules_vl
	        where match_rule_id = p_match_rule_id;

l_match_rule_id number;

begin
	open get_match_rule_thresholds_csr;
	fetch get_match_rule_thresholds_csr into x_match_threshold,x_automerge_threshold;
	close get_match_rule_thresholds_csr;

end get_match_rule_thresholds;

procedure get_most_matching_party(p_search_ctx_id in number,
				  p_new_party_id in number,
				       x_party_id out nocopy number,
				       x_match_score out nocopy number,
				       x_party_name out nocopy varchar2) is

	cursor get_party_with_highest_score_c is
		SELECT party_id, score, party_name
   		FROM (SELECT mpg.party_id party_id, mpg.score, p.party_name,
    			RANK() OVER (ORDER BY score desc) rank
    	  		FROM hz_matched_parties_gt mpg, hz_parties p
          		WHERE mpg.party_id = p.party_id
            		AND mpg.search_context_id = p_search_ctx_id
			AND mpg.party_id <> p_new_party_id -- newly created id
    	    		ORDER BY p.last_update_date desc)
		WHERE rank = 1 and rownum = 1;

begin
	open get_party_with_highest_score_c;
	fetch get_party_with_highest_score_c into x_party_id, x_match_score, x_party_name;
	if get_party_with_highest_score_c%NOTFOUND
	then
		x_party_id := null;
	end if;
	close get_party_with_highest_score_c;
end get_most_matching_party;

procedure validate_master_party_id(px_party_id in out nocopy number,
				   x_overlap_merge_req_id out nocopy number) is

	cursor validate_master_party_id_csr is
		select to_party_id, mb.batch_id
		from hz_merge_batch mb, hz_merge_parties mp
		where mb.batch_id = mp.batch_id
			and mp.from_party_id = px_party_id
			and mp.to_party_id <> px_party_id
			and mb.batch_status <> 'COMPLETED' and rownum = 1;

l_party_id number;
begin
	open validate_master_party_id_csr;
	fetch validate_master_party_id_csr into l_party_id, x_overlap_merge_req_id;
	close validate_master_party_id_csr;
	if l_party_id is not null
	then
	   px_party_id := l_party_id; -- if px_party_id is from_id in merge request,
                                      -- change it to to_party_id in the merge request.
	end if;
end validate_master_party_id;

END HZ_DUP_PVT;

/
