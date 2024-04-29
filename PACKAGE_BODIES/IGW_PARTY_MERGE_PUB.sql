--------------------------------------------------------
--  DDL for Package Body IGW_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PARTY_MERGE_PUB" as
--$Header: igwtcapb.pls 115.5 2002/11/14 18:48:43 vmedikon noship $

PROCEDURE person_degrees_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
IS

cursor from_party_cur(l_person_degree_id number) is
select *
from   igw_person_degrees
where  person_degree_id = l_person_degree_id;

from_party_rec  from_party_cur%rowtype;

cursor to_party_cur(l_party_id number,l_degree_type_code varchar2, l_degree varchar2, l_graduation_date date) is
select *
from  igw_person_degrees
where party_id = l_party_id
and degree_type_code = l_degree_type_code and
degree = l_degree and graduation_date = l_graduation_date;

to_party_rec to_party_cur%rowtype;

l_no number;
l_api_name varchar2(30) :=  'PERSON_DEGREES_PARTY_MERGE';

BEGIN
  savepoint party_merge_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  if (p_entity_name <> 'IGW_PERSON_DEGREES')
    or (p_parent_entity_name <> 'HZ_PARTIES') then
    fnd_message.set_name ('IGW', 'IGW_MRG_ENTITY_NAME_ERR');
    fnd_message.set_token('P_ENTITY',p_entity_name);
    fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  open from_party_cur(p_from_id);  -- p_from_id is the value of person_degree_id
  fetch from_party_cur into from_party_rec;
  IF(from_party_cur%found)  THEN
    open to_party_cur(p_to_fk_id,from_party_rec.degree_type_code,from_party_rec.degree,from_party_rec.graduation_date);
    fetch to_party_cur into to_party_rec;
    if(to_party_cur%found)  then

      --reject merge because the person is already used
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

    else
      --update from record with new party id
      update igw_person_degrees
      set    party_id = p_to_fk_id
      where  person_degree_id = p_from_id;

      x_to_id := p_from_id;
    end if;
    close to_party_cur;
  END IF; -- end of car_cur found check
  close from_party_cur;

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;


END person_degrees_party_merge;
---------------------------------------------------------------

PROCEDURE person_biosketch_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
IS

cursor from_party_cur(l_person_biosketch_id number) is
select *
from   igw_person_biosketch
where  person_biosketch_id = l_person_biosketch_id;

from_party_rec  from_party_cur%rowtype;

cursor to_party_cur(l_party_id number,l_biosketch_type varchar2,l_line_description varchar2) is
select *
from  igw_person_biosketch
where party_id = l_party_id and
biosketch_type = l_biosketch_type and line_description = l_line_description;

to_party_rec to_party_cur%rowtype;

l_no number;
l_api_name varchar2(30) :=  'PERSON_BIOSKETCH_PARTY_MERGE';

BEGIN
  savepoint party_merge_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  if (p_entity_name <> 'IGW_PERSON_BIOSKETCH')
    or (p_parent_entity_name <> 'HZ_PARTIES') then
    fnd_message.set_name ('IGW', 'IGW_MRG_ENTITY_NAME_ERR');
    fnd_message.set_token('P_ENTITY',p_entity_name);
    fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  open from_party_cur(p_from_id);
  fetch from_party_cur into from_party_rec;
  IF(from_party_cur%found)  THEN
    open to_party_cur(p_to_fk_id,from_party_rec.biosketch_type ,from_party_rec.line_description );
    fetch to_party_cur into to_party_rec;
    if(to_party_cur%found)  then

     -- reject merge because the person is already used
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

    else
      --update from record with new party id
      update igw_person_biosketch
      set    party_id = p_to_fk_id
      where  person_biosketch_id = p_from_id;

      x_to_id := p_from_id;
    end if;
    close to_party_cur;
  END IF; -- end of car_cur found check
  close from_party_cur;

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END person_biosketch_party_merge;

----------------------------------------------------------

PROCEDURE prop_location_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
			   IS

cursor from_party_cur(l_prop_locations_id number) is
select *
from   igw_prop_locations
where  prop_location_id = l_prop_locations_id;

from_party_rec  from_party_cur%rowtype;

cursor to_party_cur(l_party_id number,l_proposal_id number) is
select *
from  igw_prop_locations
where proposal_id = l_proposal_id and
party_id = l_party_id;

to_party_rec to_party_cur%rowtype;

l_no number;
l_api_name varchar2(30) :=  'PROP_LOCATION_PARTY_MERGE';

BEGIN
  savepoint party_merge_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  if (p_entity_name <> 'IGW_PROP_LOCATIONS')
    or (p_parent_entity_name <> 'HZ_PARTIES') then
    fnd_message.set_name ('IGW', 'IGW_MRG_ENTITY_NAME_ERR');
    fnd_message.set_token('P_ENTITY',p_entity_name);
    fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  open from_party_cur(p_from_id);
  fetch from_party_cur into from_party_rec;
  IF(from_party_cur%found)  THEN
    open to_party_cur(p_to_fk_id,from_party_rec.proposal_id);
    fetch to_party_cur into to_party_rec;
    if(to_party_cur%found)  then

     -- reject merge because the person is already used
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

    else
      --update from record with new party id
      update igw_prop_locations
      set    party_id = p_to_fk_id
      where  prop_location_id = p_from_id;

      x_to_id := p_from_id;
    end if;
    close to_party_cur;
  END IF; -- end of car_cur found check
  close from_party_cur;

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END prop_location_party_merge;

--------------------------------------------------------------------

PROCEDURE prop_person_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
			   IS

cursor from_party_cur(l_proposal_person_party_id number) is
select *
from   igw_prop_persons_tca_v
where  proposal_person_party_id = l_proposal_person_party_id ;

from_party_rec  from_party_cur%rowtype;

--this is for person party
cursor to_party_cur(l_party_id number,l_proposal_id number) is
select *
from  igw_prop_persons_tca_v
where proposal_id = l_proposal_id
and person_party_id = l_party_id;

to_party_rec to_party_cur%rowtype;


l_no number;
l_api_name varchar2(30) :=  'PROP_PERSON_PARTY_MERGE';

BEGIN
  savepoint party_merge_sp;
  x_return_status := fnd_api.g_ret_sts_success;

  if (p_entity_name <> 'IGW_PROP_PERSONS_TCA_V')
    or (p_parent_entity_name <> 'HZ_PARTIES') then
    fnd_message.set_name ('IGW', 'IGW_MRG_ENTITY_NAME_ERR');
    fnd_message.set_token('P_ENTITY',p_entity_name);
    fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  open from_party_cur(p_from_id);
  fetch from_party_cur into from_party_rec;
  IF(from_party_cur%found)  THEN
    open to_party_cur(p_to_fk_id,from_party_rec.proposal_id);
    fetch to_party_cur into to_party_rec;
    if(to_party_cur%found)  then

     -- reject merge because the person is already used
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

    else
      --update from record with new party id
      update igw_prop_persons
      set    person_party_id = p_to_fk_id
      where  proposal_id||person_party_id = p_from_id;

      begin
      update igw_prop_person_questions
      set    party_id = p_to_fk_id
      where  proposal_id = from_party_rec.proposal_id
      and    party_id = from_party_rec.person_party_id;
      exception
      when dup_val_on_index  then
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name||' - ASSURANCES');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
      end;

      begin
      update igw_prop_person_support
      set    party_id = p_to_fk_id
      where  proposal_id = from_party_rec.proposal_id
      and    party_id = from_party_rec.person_party_id;
      exception
      when dup_val_on_index  then
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name||' - OTHER SUPPORT');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
      end;

      begin
      update igw_budget_persons
      set    party_id = p_to_fk_id
      where  proposal_id = from_party_rec.proposal_id
      and    party_id = from_party_rec.person_party_id;
      exception
      when dup_val_on_index  then
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name||' - BUDGET PERSONS');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
      end;

      begin
      update igw_budget_personnel_details
      set    party_id = p_to_fk_id
      where  proposal_id = from_party_rec.proposal_id
      and    party_id = from_party_rec.person_party_id;
      exception
      when dup_val_on_index  then
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name||' - BUDGET PERSONNEL DETAILS');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
      end;

      x_to_id := p_from_id;
    end if;
    close to_party_cur;
  END IF; -- end of car_cur found check
EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END prop_person_party_merge;

-------------------------------------------------------------------------------------
PROCEDURE prop_org_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
			   IS

cursor from_party_cur(l_proposal_person_party_id number) is
select *
from   igw_prop_persons_tca_v
where  proposal_person_party_id = l_proposal_person_party_id;

from_party_rec  from_party_cur%rowtype;


--this is for organization party
cursor to_party_cur(l_party_id number,l_proposal_id number) is
select *
from  igw_prop_persons_tca_v
where org_party_id = l_party_id and
proposal_id = l_proposal_id;

to_party_rec to_party_cur%rowtype;

l_no number;
l_api_name varchar2(30) :=  'PROP_ORG_PARTY_MERGE';

BEGIN
  savepoint party_merge_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  if (p_entity_name <> 'IGW_PROP_PERSONS_TCA_V')
    or (p_parent_entity_name <> 'HZ_PARTIES') then
    fnd_message.set_name ('IGW', 'IGW_MRG_ENTITY_NAME_ERR');
    fnd_message.set_token('P_ENTITY',p_entity_name);
    fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  --Repeat the same for org party
  open from_party_cur(p_from_id);
  fetch from_party_cur into from_party_rec;
  IF(from_party_cur%found)  THEN
/*
    open to_party_cur(p_to_fk_id);
    fetch to_party_cur into to_party_rec;
    if(to_party_cur%found)  then

     -- reject merge because the person is already used
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

    else */
      --update from record with new party id
      update igw_prop_persons
      set    org_party_id = p_to_fk_id
      where  proposal_id||person_party_id = p_from_id;

      x_to_id := p_from_id;/*
    end if;
    close to_party_cur;*/
  END IF; -- end of car_cur found check
  close from_party_cur;

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END prop_org_party_merge;



PROCEDURE other_support_location_merge (
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2) IS

cursor from_party_cur(l_prop_person_support_id number) is
select *
from   igw_prop_person_support
where  prop_person_support_id = l_prop_person_support_id;

from_party_rec  from_party_cur%rowtype;


cursor to_party_cur(l_party_id number,l_proposal_id number) is
select *
from  igw_prop_persons_tca_v
where org_party_id = l_party_id and
proposal_id = l_proposal_id;

to_party_rec to_party_cur%rowtype;

l_no number;
l_api_name varchar2(30) :=  'OTHER_SUPPORT_LOCATION_MERGE';

BEGIN
  savepoint party_merge_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  if (p_entity_name <> 'IGW_PROP_PERSON_SUPPORT')
    or (p_parent_entity_name <> 'HZ_PARTIES') then
    fnd_message.set_name ('IGW', 'IGW_MRG_ENTITY_NAME_ERR');
    fnd_message.set_token('P_ENTITY',p_entity_name);
    fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  --Repeat the same for org party
  open from_party_cur(p_from_id);
  fetch from_party_cur into from_party_rec;
  IF(from_party_cur%found)  THEN
/*
    open to_party_cur(p_to_fk_id);
    fetch to_party_cur into to_party_rec;
    if(to_party_cur%found)  then

     -- reject merge because the person is already used
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

    else */
      --update from record with new party id
      update igw_prop_person_support
      set    location_party_id = p_to_fk_id
      where  prop_person_support_id = p_from_id
      and    location_party_id = p_from_fk_id;

      x_to_id := p_from_id;/*
    end if;
    close to_party_cur;*/
  END IF; -- end of car_cur found check
  close from_party_cur;

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END other_support_location_merge;


PROCEDURE other_support_pi_party_merge (
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2) IS

cursor from_party_cur(l_prop_person_support_id number) is
select *
from   igw_prop_person_support
where  prop_person_support_id = l_prop_person_support_id;

from_party_rec  from_party_cur%rowtype;


cursor to_party_cur(l_party_id number,l_proposal_id number) is
select *
from  igw_prop_persons_tca_v
where org_party_id = l_party_id and
proposal_id = l_proposal_id;

to_party_rec to_party_cur%rowtype;

l_no number;
l_api_name varchar2(30) :=  'OTHER_SUPPORT_PI_PARTY_MERGE';

BEGIN
  savepoint party_merge_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  if (p_entity_name <> 'IGW_PROP_PERSON_SUPPORT')
    or (p_parent_entity_name <> 'HZ_PARTIES') then
    fnd_message.set_name ('IGW', 'IGW_MRG_ENTITY_NAME_ERR');
    fnd_message.set_token('P_ENTITY',p_entity_name);
    fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  --Repeat the same for org party
  open from_party_cur(p_from_id);
  fetch from_party_cur into from_party_rec;
  IF(from_party_cur%found)  THEN
/*
    open to_party_cur(p_to_fk_id);
    fetch to_party_cur into to_party_rec;
    if(to_party_cur%found)  then

     -- reject merge because the person is already used
      fnd_message.set_name ('IGW', 'IGW_MRG_REJECT_MERGE');
    fnd_message.set_token('API','IGW_PARTY_MERGE_PUB.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

    else */
      --update from record with new party id
      update igw_prop_person_support
      set    pi_party_id = p_to_fk_id
      where  prop_person_support_id = p_from_id
      and    pi_party_id = p_from_fk_id;

      x_to_id := p_from_id;/*
    end if;
    close to_party_cur;*/
  END IF; -- end of car_cur found check
  close from_party_cur;

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END other_support_pi_party_merge;



END; --package

/
