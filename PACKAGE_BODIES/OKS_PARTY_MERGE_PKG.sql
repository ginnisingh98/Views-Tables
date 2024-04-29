--------------------------------------------------------
--  DDL for Package Body OKS_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_PARTY_MERGE_PKG" AS
/* $Header: OKSPYMGB.pls 120.0 2005/05/25 18:23:54 appldev noship $ */

g_api_name    constant  varchar2(30) := 'OKS_PARTY_MERGE_PKG';
g_user_id     constant  number(15)   := arp_standard.profile.user_id;
g_login_id    constant  number(15)   := arp_standard.profile.last_update_login;

/* Merge the records in OKS_BILLING_PROFILES_B */

PROCEDURE OKS_BILLING_PROFILES(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_billing_profiles_b.id%type,
  x_to_id          in out  nocopy oks_billing_profiles_b.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2) IS

  l_proc_name  varchar2(30) := 'OKS_BILLING_PROFILES';
  l_count      number(10)   := 0;

BEGIN
  arp_message.set_line(g_api_name||'.'||l_proc_name);

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
    return;
  end if;

  --If party_id 1000 is getting merged to party_id 2000,
  --update the party_id to 2000 which were previously 1000.

  if p_from_fk_id <> p_to_fk_id then
    BEGIN

      arp_message.set_line('Updating OKS_BILLING_PROFILES_B...');

      update oks_billing_profiles_b
	 set owned_party_id1    = p_to_fk_id,
	     last_update_date   = sysdate,
	     last_updated_by    = g_user_id,
	     last_update_login  = g_login_id,
		object_version_number = object_version_number+1
      where owned_party_id1 = p_from_fk_id;

      l_count := sql%rowcount;
      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));

    EXCEPTION
      when OTHERS then
	   arp_message.set_line(g_api_name||'.'||l_proc_name||': '||sqlerrm);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
	   raise;
    END;
  end if;
END OKS_BILLING_PROFILES;


/* Merge the records in OKS_K_DEFAULTS */

PROCEDURE OKS_DEFAULTS(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_k_defaults.id%type,
  x_to_id          in out  nocopy oks_k_defaults.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2) IS


  l_proc_name  varchar2(30) := 'OKS_DEFAULTS';
  l_count      number(10)   := 0;

--Added by CK 04/03
  l_from_start_date     date;
  l_from_end_date       date;
  l_from_end_date1       date;
  l_to_start_date       date;
  l_to_start_date1       date;
  l_to_end_date         date;
  l_to_end_date1         date;
  l_row_count_exists      boolean;
  cursor default_cur(p_fk_id  hz_merge_parties.from_party_id%type) IS
  SELECT start_date,end_date
  FROM  oks_k_defaults
  where segment_id1 =p_fk_id;
  from_rec default_cur%ROWTYPE;
  to_rec default_cur%ROWTYPE;

BEGIN
  arp_message.set_line(g_api_name||'.'||l_proc_name);

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
    return;
  end if;

  --If party_id 1000 is getting merged to party_id 2000,
  --update the party_id to 2000 which were previously 1000.

  -- Fetch start and end dates
  OPEN default_cur(p_from_fk_id);
  FETCH default_cur INTO from_rec;
  IF default_cur%FOUND THEN
    l_from_start_date:=from_rec.start_date;
    l_from_end_date:=from_rec.end_date;
  END IF;
  CLOSE default_cur;

  OPEN default_cur(p_to_fk_id);
  FETCH default_cur INTO to_rec;
  IF default_cur%FOUND THEN
    l_to_start_date:=to_rec.start_date;
    l_to_end_date:=to_rec.end_date;
    l_row_count_exists :=true;
  ELSE
   l_row_count_exists := false;
  END IF;
  CLOSE default_cur;
  l_to_start_date1 := least(l_from_start_date,l_to_start_date);
  l_to_end_date1 := greatest(l_from_end_date,l_to_end_date);

  -- If From StartDate is greater than or equal to sysdate, update to sysdate-1
  -- If From EndDate is greater than or equal to sysdate, update to sysdate-1
  IF l_from_start_date >= sysdate THEN
      l_from_start_date:=sysdate-1;
  END IF;
  IF l_from_end_date >= sysdate
	OR l_from_end_date is null THEN
      l_from_end_date :=sysdate -1;
  END IF;

  if p_from_fk_id <> p_to_fk_id then
    BEGIN
    -- Updateing from(source) record -- Party getting merged

    IF not l_row_count_exists THEN
         update oks_k_defaults
	     set segment_id1    = p_to_fk_id,
	     last_update_date   = sysdate,
         last_updated_by    = g_user_id,
		 object_version_number = object_version_number+1
         where segment_id1 = p_from_fk_id
	     and jtot_object_code = 'OKX_PARTY';
    ELSE
    IF l_to_start_date1<> l_to_start_date
    AND l_to_end_date1 <> l_to_end_date
    THEN
                update oks_k_defaults
	            set
                start_date    =   l_to_start_date1,
                end_date      =   l_to_end_date1,
                last_update_date   = sysdate,
                last_updated_by    = g_user_id,
		        object_version_number = object_version_number+1
                where segment_id1 = p_to_fk_id
	            and jtot_object_code = 'OKX_PARTY';
    ELSIF l_to_start_date1<> l_to_start_date
    AND l_to_end_date1 = l_to_end_date    THEN
               update oks_k_defaults
 	           set
                start_date    =   l_to_start_date1,
                last_update_date   = sysdate,
                last_updated_by    = g_user_id,
		        object_version_number = object_version_number+1
                where segment_id1 = p_to_fk_id
	            and jtot_object_code = 'OKX_PARTY';
    ELSIF l_to_start_date1 = l_to_start_date
    AND l_to_end_date1 <> l_to_end_date    THEN
               update oks_k_defaults
 	           set
                end_date    =   l_to_end_date1,
                last_update_date   = sysdate,
                last_updated_by    = g_user_id,
		        object_version_number = object_version_number+1
                where segment_id1 = p_to_fk_id
	            and jtot_object_code = 'OKX_PARTY';

     END IF;
      l_count := sql%rowcount;
      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
         update oks_k_defaults
	     set segment_id1    = p_to_fk_id,
	     last_update_date   = sysdate,
         last_updated_by    = g_user_id,
         start_date  =  l_from_start_date,
         end_date  =  l_from_end_date,
		 object_version_number = object_version_number+1
         where segment_id1 = p_from_fk_id
	     and jtot_object_code = 'OKX_PARTY';
      l_count := sql%rowcount;
      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
      arp_message.set_line('Updating OKS_K_DEFAULTS...');

 END IF;

    EXCEPTION
      when OTHERS then
	   arp_message.set_line(g_api_name||'.'||l_proc_name||': '||sqlerrm);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
	   raise;
    END;
  end if;
END OKS_DEFAULTS;

/* Merge the records in OKS_SERV_AVAIL_EXCEPTS */
--chkrishn 04/16/03 modify code to delete service avail exceptions of both from and to parties during merge
PROCEDURE OKS_SERVICE_EXCEPTS(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_serv_avail_excepts.id%type,
  x_to_id          in out  nocopy oks_serv_avail_excepts.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2) IS

  l_proc_name  varchar2(30) := 'OKS_SERVICE_EXCEPTS';
  l_count      number(10)   := 0;

BEGIN
  arp_message.set_line(g_api_name||'.'||l_proc_name);

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
    return;
  end if;

  --If party_id 1000 is getting merged to party_id 2000,
  --update the party_id to 2000 which were previously 1000.

  if p_from_fk_id <> p_to_fk_id then
    BEGIN

/*   original code   arp_message.set_line('Updating OKS_SERV_AVAIL_EXCEPTS...');

      update oks_serv_avail_excepts
	 set object1_id1        = p_to_fk_id,
	     last_update_date   = sysdate,
	     last_updated_by    = g_user_id,
	     last_update_login  = g_login_id,
		object_version_number = object_version_number+1
      where object1_id1 = p_from_fk_id
	   and jtot_object1_code = 'OKX_PARTY';

      l_count := sql%rowcount;
      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));*/

      arp_message.set_line('Deleting OKS_SERV_AVAIL_EXCEPTS...');

      delete from oks_serv_avail_excepts
      where object1_id1 in (p_from_fk_id,p_to_fk_id)
	   and jtot_object1_code = 'OKX_PARTY';

      l_count := sql%rowcount;
      arp_message.set_name('AR','AR_ROWS_DELETED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));

    EXCEPTION
      when OTHERS then
	   arp_message.set_line(g_api_name||'.'||l_proc_name||': '||sqlerrm);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
	   raise;
    END;
  end if;
END OKS_SERVICE_EXCEPTS;


PROCEDURE OKS_QUALIFIERS(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  number,
  x_to_id          in out  nocopy number,
  p_from_fk_id         in  number,
  p_to_fk_id           in  number,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2) IS

  l_proc_name  varchar2(30) := 'OKS_QUALIFIERS';
  l_count      number(10)   := 0;
  l_return_status              VARCHAR2(1);

BEGIN
  arp_message.set_line(g_api_name||'.'||l_proc_name);

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
    return;
  end if;

  --If party_id 1000 is getting merged to party_id 2000,
  --update the party_id to 2000 which were previously 1000.

  if p_from_fk_id <> p_to_fk_id then
    BEGIN

      arp_message.set_line('Updating OKS_QUALIFIERS...');

    OKS_QP_INT_PVT.QUALIFIER_PARTY_MERGE(
    p_from_fk_id        =>p_from_fk_id,
    p_to_fk_id         =>p_to_fk_id,
    x_return_status     =>l_return_status);

   IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;

    EXCEPTION
      when OTHERS then
	   arp_message.set_line(g_api_name||'.'||l_proc_name||': '||sqlerrm);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
	   raise;
    END;
  end if;
END OKS_QUALIFIERS;

END OKS_PARTY_MERGE_PKG;

/
