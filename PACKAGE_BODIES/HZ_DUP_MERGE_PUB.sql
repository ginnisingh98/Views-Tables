--------------------------------------------------------
--  DDL for Package Body HZ_DUP_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_MERGE_PUB" AS
/*$Header: ARHBCMBB.pls 120.1.12010000.3 2009/03/30 07:58:01 vsegu ship $ */

  -- PROCEDURE create_dup_merge_request
  --
  -- DESCRIPTION
  --     Create merge request for duplicate parties
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --  p_init_msg_list  	Standard IN parameter to initialize message stack.
  --  p_dup_id_objs  	An object table of duplicate party ids.
  --  p_note_text   	note for the merge request
  --
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_merge_request_id   merge request id
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   10-JAN-2006   AWU          Created.


FUNCTION is_ss_provided(
    p_os                  IN     VARCHAR2,
    p_osr                 IN     VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF((p_os is null or p_os = fnd_api.g_miss_char)
      and (p_osr is null or p_osr = fnd_api.g_miss_char))THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
  END is_ss_provided;

PROCEDURE validate_ssm_id(
    px_id                        IN OUT NOCOPY NUMBER,
    px_os                        IN OUT NOCOPY VARCHAR2,
    px_osr                       IN OUT NOCOPY VARCHAR2,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
  ) IS
  CURSOR is_pty_valid(l_pty_id NUMBER) IS
    SELECT status, party_id
    FROM HZ_PARTIES
    WHERE party_id = l_pty_id
    AND status in ('A', 'I');

l_ss_flag                   VARCHAR2(1);
l_debug_prefix              VARCHAR2(30);
l_status varchar2(1);
l_valid_id number;
l_owner_table_id number;
l_count number;
begin
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- if px_id pass in, check if px_id is valid or not
    IF(px_id IS NOT NULL) THEN

    	OPEN is_pty_valid(px_id);
    	FETCH is_pty_valid INTO l_status, l_valid_id;
    	CLOSE is_pty_valid;
    end if;

    if l_status = 'M'
    then
	 FND_MESSAGE.SET_NAME('AR','HZ_DL_ALREADY_MERGED');
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
    end if;


    l_ss_flag := is_ss_provided(p_os  => px_os,
                                p_osr => px_osr);

    -- if px_os/px_osr pass in, get owner_table_id and set l_ss_flag to 'Y'
    IF(l_ss_flag = 'Y')THEN

      -- Get how many rows return
      l_count := HZ_MOSR_VALIDATE_PKG.get_orig_system_ref_count(
                   p_orig_system           => px_os,
                   p_orig_system_reference => px_osr,
                   p_owner_table_name      => 'HZ_PARTIES');

      IF(l_count = 1) THEN
        -- Get owner_table_id
        HZ_ORIG_SYSTEM_REF_PUB.get_owner_table_id(
          p_orig_system           => px_os,
          p_orig_system_reference => px_osr,
          p_owner_table_name      => 'HZ_PARTIES',
          x_owner_table_id        => l_owner_table_id,
          x_return_status         => x_return_status);

	OPEN is_pty_valid(l_owner_table_id);
    	FETCH is_pty_valid INTO l_status, l_valid_id;
    	CLOSE is_pty_valid;
        if l_status = 'M'
        then
	  FND_MESSAGE.SET_NAME('AR','HZ_DL_ALREADY_MERGED');
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
        end if;
     end if;

   end if;

   -- if px_id pass in
     IF(px_id IS NOT NULL) THEN
        -- if px_id is invalid, raise error
        IF(l_valid_id IS NULL) THEN
          FND_MESSAGE.SET_NAME('AR','HZ_DL_MR_INV_PARTYNUM');
          fnd_message.set_token('PARTY_ID', px_id);
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
        -- if px_id is valid
        ELSE
          -- check if px_os/px_osr is passed
          IF(l_ss_flag = 'Y') THEN
            IF(l_count = 0) THEN
              FND_MESSAGE.SET_NAME('AR','HZ_DL_MR_INV_OSOSR');
	      fnd_message.set_token('OSOSR', px_os||' - '||px_osr);
              FND_MSG_PUB.ADD();
              RAISE fnd_api.g_exc_error;
            -- if px_os/px_osr is valid
            ELSE
              -- if px_os/px_osr is valid, but not same as px_id
              IF(l_owner_table_id <> px_id) OR (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                FND_MESSAGE.SET_NAME('AR','HZ_DL_MR_INVALID');
	        fnd_message.set_token('OSOSR', px_os||' - '||px_osr);
                FND_MSG_PUB.ADD();
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
            -- if px_os/px_osr is valid and return value is same as px_id
            -- do nothing
          END IF;
        END IF;
      -- if px_id not pass in
      ELSE
        -- check if px_os/px_osr can find TCA identifier, owner_table_id
        -- if not found, raise error
        -- else, get owner_table_id and assign it to px_id
        IF(l_ss_flag = 'Y') AND (l_count = 1) AND (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          px_id := l_owner_table_id;
        ELSE
          FND_MESSAGE.SET_NAME('AR','HZ_DL_MR_INV_OSOSR');
	  fnd_message.set_token('OSOSR', px_os||' - '||px_osr);
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END validate_ssm_id;

function check_obj_dup_value(p_dup_id_objs  IN  HZ_DUP_ID_OBJ_TBL) return varchar2 is
TYPE PartyIdTbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_PartyIdTbl PartyIdTbl;
begin
  for i in 1..p_dup_id_objs.count loop
    if l_PartyIdTbl.EXISTS(p_dup_id_objs(i).party_id)
    then return 'Y';
    else l_PartyIdTbl(p_dup_id_objs(i).party_id) := 1;
    end if;
  end loop;
  return 'N';
end;

PROCEDURE create_dup_merge_request(
  p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
  p_dup_id_objs    	IN            HZ_DUP_ID_OBJ_TBL,
  p_note_text           IN            VARCHAR2,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,
  x_merge_request_id           OUT NOCOPY    NUMBER
) IS

 CURSOR get_party_name(l_party_id NUMBER) is
  select party_name
  from HZ_PARTIES
  where party_id = l_party_id;

l_jtf_note_id number;
l_dup_set_id number;
l_dup_batch_rec  HZ_DUP_PVT.DUP_BATCH_REC_TYPE;
l_dup_set_rec    HZ_DUP_PVT.DUP_SET_REC_TYPE;
l_dup_party_tbl  HZ_DUP_PVT.DUP_PARTY_TBL_TYPE;
l_dup_id_objs    HZ_DUP_ID_OBJ_TBL;
l_party_name     varchar2(360);
l_dup_batch_id   number;
l_request_id     number;
l_master_party_id number;
l_debug_prefix              VARCHAR2(30) := '';
l_dup varchar2(1);
begin

    -- Standard start of API savepoint
    SAVEPOINT create_dup_merge_req_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_dup_merge_request(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
--Bug8342391
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    l_dup_id_objs := p_dup_id_objs;
    for i in 1..l_dup_id_objs.count loop
    	validate_ssm_id(
      		px_id              => l_dup_id_objs(i).party_id,
      		px_os              => l_dup_id_objs(i).orig_system,
      		px_osr             => l_dup_id_objs(i).orig_system_reference,
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
    	END IF;

    end loop;

    l_dup := check_obj_dup_value(l_dup_id_objs);

    if l_dup = 'Y'
    then
	 FND_MESSAGE.SET_NAME('AR','HZ_MERGE_UNIQUE_CONST');
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
    end if;

    OPEN get_party_name(l_dup_id_objs(1).party_id); -- choose any party
    FETCH get_party_name INTO l_party_name;
    CLOSE get_party_name;

    if l_dup_id_objs.count = 1
    then
	l_dup_set_rec.merge_type := 'SAME_PARTY_MERGE';
    else
	l_dup_set_rec.merge_type := 'PARTY_MERGE';
    end if;

    l_dup_batch_rec.dup_batch_name := l_party_name ||'-'|| to_char(sysdate);
    l_dup_batch_rec.match_rule_id := nvl(fnd_profile.value('HZ_DL_IDENTIFY_DUP_RULE'),-2);
    -- match rule is not really needed in create case. default to -2.
    l_dup_batch_rec.application_id := 222;
    l_dup_batch_rec.request_type := 'SYSTEM_GENERATED';
    l_dup_batch_id := NULL;
    l_dup_set_rec.winner_party_id := l_dup_id_objs(1).party_id; -- call default master later
    l_dup_set_rec.status := 'SYSBATCH';
    l_dup_set_rec.assigned_to_user_id := NULL;

    for i in 1..l_dup_id_objs.count loop
      l_dup_party_tbl(i).party_id := l_dup_id_objs(i).party_id;
      l_dup_party_tbl(i).score := -1;
      l_dup_party_tbl(i).merge_flag := 'N';
    end loop;

    HZ_DUP_PVT.create_dup_batch(
         p_dup_batch_rec             => l_dup_batch_rec
        ,p_dup_set_rec               => l_dup_set_rec
        ,p_dup_party_tbl             => l_dup_party_tbl
        ,x_dup_batch_id              => l_dup_batch_id
        ,x_dup_set_id                => l_dup_set_id
        ,x_return_status             => x_return_status
        ,x_msg_count                 => x_msg_count
        ,x_msg_data                  => x_msg_data );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      	RAISE FND_API.G_EXC_ERROR;
      END IF;

     if p_dup_id_objs.count > 1
     then
	hz_dup_pvt.default_master(
 		p_dup_set_id      => l_dup_set_id,
 		x_master_party_id => l_master_party_id,
 		x_master_party_name  => l_party_name,
 		x_return_status      => x_return_status,
 		x_msg_count          => x_msg_count,
 		x_msg_data           => x_msg_data );

   	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
         END IF;

     	update hz_dup_batch
     	set dup_batch_name = l_party_name || ' - '||l_dup_batch_id
        where dup_batch_id = l_dup_batch_id;

     end if;

     HZ_MERGE_DUP_PVT.validate_overlapping_merge_req(
	p_dup_set_id     => l_dup_set_id,
	p_merge_batch_id => null,
	p_init_msg_list  => FND_API.G_FALSE,
        p_reject_req_flag => 'N',
	x_return_status  => x_return_status,
	x_msg_count      => x_msg_count,
	x_msg_data       => x_msg_data);

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
     	RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- populate merge tables
     hz_dup_pvt.submit_dup (
   		p_dup_set_id    => l_dup_set_id
  		,x_request_id    => l_request_id
  		,x_return_status => x_return_status
  		,x_msg_count     => x_msg_count
  		,x_msg_data      => x_msg_data);

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF p_note_text IS NOT NULL THEN

	     jtf_notes_pub.Create_note
   		(p_parent_note_id	=>null
   		,p_jtf_note_id	=>null
   		,p_api_version	=>1
   		,p_init_msg_list	=>FND_API.g_false
   		,p_commit		=>FND_API.g_false
   		,p_validation_level	=>100
   		,x_return_status	=>x_return_status
   		,x_msg_count		=>x_msg_count
   		,x_msg_data          =>x_msg_data
   		,p_org_id	        =>null
   		,p_source_object_id => l_dup_set_id
   		,p_source_object_code => 'MERGE_DUP_SET'
   		,p_notes => p_note_text
   		,p_notes_detail=>null
  		 ,p_note_status	=>'I'
   		,p_entered_by	=>fnd_global.user_id
   		,p_entered_date => sysdate
   		,x_jtf_note_id => l_jtf_note_id
   		,p_last_update_date	=> sysdate
   		,p_last_updated_by   =>fnd_global.user_id
   		,p_creation_date     => sysdate
   		,p_created_by        => fnd_global.user_id
   		,p_last_update_login	=> fnd_global.login_id
   		,p_attribute1		   => NULL
    		,p_attribute2		   => NULL
    		,p_attribute3		   => NULL
    		,p_attribute4		   => NULL
    		,p_attribute5		   => NULL
    		,p_attribute6		   => NULL
    		,p_attribute7		   => NULL
    		,p_attribute8		   => NULL
    		,p_attribute9		   => NULL
    		,p_attribute10		   => NULL
    		,p_attribute11		   => NULL
    		,p_attribute12		   => NULL
    		,p_attribute13		   => NULL
    		,p_attribute14		   => NULL
    		,p_attribute15		   => NULL
    		,p_context			   => NULL
    		,p_note_type                   => 'GENERAL'
 	);

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      	RAISE FND_API.G_EXC_ERROR;
    END IF;

    END IF; --p_note_text
    x_merge_request_id := l_dup_set_id;


  -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_dup_merge_request(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_dup_merge_req_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_dup_merge_request(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_dup_merge_req_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_dup_merge_request(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_dup_merge_req_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	  hz_utility_v2pub.debug(p_message=>'create_dup_merge_request(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_dup_merge_request;

END HZ_DUP_MERGE_PUB;

/
