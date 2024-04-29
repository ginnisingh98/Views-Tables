--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAYEE_ASSIGNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAYEE_ASSIGNS_PVT" AS
/* $Header: cnvpspab.pls 120.7 2006/02/13 17:21:47 mblum noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SRP_PAYEE_ASSIGNS_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvpspab.pls';
g_payee_role                CONSTANT NUMBER       := 54;

PROCEDURE delete_trigger
  (old_salesrep_id         NUMBER,
   old_srp_quota_assign_id NUMBER,
   old_start_date          DATE,
   old_end_date            DATE,
   old_org_id              NUMBER) IS

   x_salesrep_name cn_salesreps.name%TYPE;
BEGIN
   IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN
      SELECT name
        INTO x_salesrep_name
        FROM cn_salesreps
       WHERE salesrep_id = old_salesrep_id
	 AND org_id      = old_org_id;

      cn_mark_events_pkg.mark_event_srp_payee_assign
	('CHANGE_SRP_QUOTA_POP',
	 x_salesrep_name,
	 old_srp_quota_assign_id,
	 null,
	 null,
	 old_start_date,
	 null,
	 old_end_date,
	 old_org_id);
   END IF;
END delete_trigger;

PROCEDURE insert_trigger
  (new_salesrep_id         NUMBER,
   new_srp_quota_assign_id NUMBER,
   new_start_date          DATE,
   new_end_date            DATE,
   new_org_id              NUMBER) IS

      x_salesrep_name cn_salesreps.name%TYPE;
BEGIN
   IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN
      SELECT name
	INTO x_salesrep_name
	FROM cn_salesreps
       WHERE salesrep_id = new_salesrep_id
	 AND org_id      = new_org_id;

      cn_mark_events_pkg.mark_event_srp_payee_assign
	('CHANGE_SRP_QUOTA_POP',
	 x_salesrep_name,
	 new_srp_quota_assign_id,
	 null,
	 null,
	 new_start_date,
	 null,
	 new_end_date,
	 new_org_id);
   END IF;
END insert_trigger;

PROCEDURE update_trigger
  (old_salesrep_id     NUMBER,
   old_payee_id        NUMBER,
   old_start_date      DATE,
   old_end_date        DATE,
   new_srp_quota_assign_id NUMBER,
   new_salesrep_id     NUMBER,
   new_payee_id        NUMBER,
   new_start_date      DATE,
   new_end_date        DATE,
   new_org_id          NUMBER) IS

      x_salesrep_name cn_salesreps.name%TYPE;
BEGIN
   IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN
      SELECT name
        INTO x_salesrep_name
        FROM cn_salesreps
       WHERE salesrep_id = new_salesrep_id
	 AND org_id      = new_org_id;

      IF (new_payee_id <> old_payee_id) THEN
	 cn_mark_events_pkg.mark_event_srp_payee_assign
	   ('CHANGE_SRP_QUOTA_POP',
	    x_salesrep_name,
	    new_srp_quota_assign_id,
	    null,
	    new_start_date,
	    old_start_date,
	    new_end_date,
	    old_end_date,
	    new_org_id);
      END IF;

      -- clku fix for bug 3234665

      IF (new_start_date <> old_start_date) OR
	Nvl(old_end_date,fnd_api.g_miss_date) <>
	Nvl(new_end_date,fnd_api.g_miss_date)
	THEN
	 cn_mark_events_pkg.mark_event_srp_payee_assign
	   ('CHANGE_SRP_QUOTA_PAYEE_DATE',
	    x_salesrep_name,
	    new_srp_quota_assign_id,
	    null,
	    new_start_date,
	    old_start_date,
	    new_end_date,
	    old_end_date,
	    new_org_id);
      END IF;
   END IF;
END update_trigger;


-- ---------------------------------------------------------------------------+
-- Procedure: Validate_Payee_Dates
-- Desc     : Validating payee dates with plan elements date and with other
--	       payees of the planelement
-- ---------------------------------------------------------------------------+
PROCEDURE Validate_Payee_Dates
  (p_srp_payee_assign_id	  IN NUMBER,  -- null means we're creating
   p_srp_quota_assign_id          IN NUMBER,
   p_salesrep_id		  IN NUMBER,
   p_org_id                       IN NUMBER,
   p_start_date	                  IN DATE,
   p_end_date	  	          IN DATE,
   p_quota_id                     IN NUMBER,
   p_payee_id		          IN NUMBER,
   x_loading_status               IN OUT NOCOPY VARCHAR2
) IS

   l_count	     NUMBER;
   l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Payee_Dates';
   l_end_of_time     CONSTANT DATE := to_date('12/31/9999','MM/DD/YYYY');
BEGIN
   -- null p_srp_payee_assign_id means we're creating new assignment

   --check whether the payee start date and end date
   --fall between the start and end date of plan element
   SELECT count(1)
     INTO l_count
     FROM cn_quotas_all
    WHERE quota_id = p_quota_id
      AND p_start_date >= start_date
      AND Nvl(p_end_date, l_end_of_time) <=
          Nvl(end_date,   l_end_of_time);

   IF l_count = 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_DATE_INVALID');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PAYEE_DATE_INVALID';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- make sure payee assignment falls within a valid plan assignment
   -- fix for bug 4507995
   SELECT COUNT(1)
     INTO l_count
     FROM cn_srp_quota_assigns sqa, cn_srp_plan_assigns spa
    WHERE sqa.srp_quota_assign_id = p_srp_quota_assign_id
      AND sqa.srp_plan_assign_id = spa.srp_plan_assign_id
      AND p_start_date >= start_date
      AND Nvl(p_end_date, l_end_of_time) <=
          Nvl(end_date,   l_end_of_time);

   IF l_count = 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_DATE_INVALID');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PAYEE_DATE_INVALID';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   --check whether the payee's date overlap with the dates of
   --other payee who is already assigned
   SELECT count(1)
     INTO l_count
     FROM cn_srp_payee_assigns_all
    WHERE srp_quota_assign_id = p_srp_quota_assign_id
      AND delete_flag = 'N'
      AND srp_payee_assign_id <> Nvl(p_srp_payee_assign_id, -1)
      AND Greatest(start_date,  p_start_date) <=
          Least(Nvl(end_date,   l_end_of_time),
		Nvl(p_end_date, l_end_of_time));

   IF l_count > 0 then
      --payee dates overlap
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_DATE_OVERLAP');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PAYEE_DATE_OVERLAP';
      RAISE FND_API.G_EXC_ERROR ;
   end if;

END Validate_Payee_Dates;

-- ---------------------------------------------------------------------------+
-- Procedure: Valid_Srp_Payee_Assigns
-- Desc     : Calling the check required procedure to check the mandatory
--            values, get the respective ids for update/insert
--            return loading status should be same as passed loading status
--            others means failure
-- ---------------------------------------------------------------------------+
PROCEDURE Valid_Srp_Payee_Assigns
  (
   p_srp_payee_assign_id     IN  NUMBER,
   p_srp_quota_assign_id     IN  NUMBER,
   p_salesrep_id             IN  NUMBER,
   p_org_id                  IN  NUMBER,
   p_payee_id                IN  NUMBER,
   p_start_date              IN  DATE,
   p_end_date                IN  DATE,
   x_loading_status          IN OUT NOCOPY VARCHAR2
   ) IS

   l_api_name            CONSTANT VARCHAR2(30) := 'Valid_Srp_Payee_Assigns';
   l_payee_assign_flag   cn_quotas.payee_assign_flag%TYPE;
   l_count               NUMBER;
   l_daycount            NUMBER;
   l_sd                  DATE;
   l_ed                  DATE;
   l_end_of_time         CONSTANT DATE := to_date('12/31/9999','MM/DD/YYYY');
   l_end_date            DATE          := nvl(p_end_date, l_end_of_time);
   l_srp_name            cn_salesreps.name%TYPE;
   l_payee_name          cn_salesreps.name%TYPE;
   l_emp_num             cn_salesreps.employee_number%TYPE;
   l_pe_name             cn_quotas.name%TYPE;
   l_quota_id            NUMBER;

   CURSOR get_pgs is
   SELECT start_date, nvl(end_date,l_end_of_time) end_date
     FROM cn_srp_pay_groups_all
    WHERE salesrep_id = p_payee_id
      AND org_id = p_org_id;

   CURSOR get_roles is
   SELECT start_date, nvl(end_date,l_end_of_time) end_date
     FROM cn_srp_roles
    WHERE salesrep_id = p_payee_id
      AND org_id      = p_org_id
      AND role_id     = g_payee_role;

BEGIN
   -- API body

   --+
   -- Check active Payee
   --+
   -- get name and number
   SELECT name, employee_number
     INTO l_payee_name, l_emp_num
     FROM cn_salesreps
    WHERE salesrep_id = p_payee_id
      AND org_id      = p_org_id;

   SELECT COUNT(1)
     INTO l_count
     FROM cn_salesreps
    WHERE salesrep_id = p_payee_id
      AND org_id      = p_org_id
      AND start_date_active <= p_start_date
      AND ((end_date_active IS NULL AND p_end_date IS NULL ) OR
	   (end_date_active IS NULL AND p_end_date IS NOT NULL ) OR
	   (end_date_active >= p_end_date));

   IF l_count = 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_NOT_ACTIVE' );
	 FND_MESSAGE.SET_TOKEN('PAYEE_NAME',  l_payee_name);
	 FND_MESSAGE.SET_TOKEN('PAYEE_NUMBER',l_emp_num);
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PAYEE_NOT_ACTIVE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   --+
   -- Check salesrep and Payee are different, if not error
   --+
   IF p_payee_id = p_salesrep_id THEN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_PAYEE_CANNOT_BE_SAME' );
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PAYEE_CANNOT_BE_SAME';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   --+
   -- Validate End Date must be greater than Start Date
   --+
   IF p_end_date IS NOT NULL AND p_end_date < p_start_date THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATE_RANGE');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_INVALID_DATE_RANGE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check wheather the payee can be assigned to this plan Element
   SELECT payee_assign_flag, q.name, q.quota_id
     INTO l_payee_assign_flag, l_pe_name, l_quota_id
     FROM cn_quotas_all q, cn_srp_quota_assigns_all sqa
    WHERE sqa.srp_quota_assign_id = p_srp_quota_assign_id
      AND q.quota_id = sqa.quota_id;

   IF Nvl(l_payee_assign_flag,'N') <> 'Y' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 -- get salesrep name
	 SELECT name
	   INTO l_srp_name
	   FROM cn_salesreps
	  WHERE salesrep_id = p_salesrep_id
	    AND org_id = p_org_id;
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_HAVE_PAYEE');
	 FND_MESSAGE.SET_TOKEN('PLAN_NAME', l_pe_name);
	 FND_MESSAGE.SET_TOKEN('SALESREP_NAME', l_srp_name);
	 FND_MESSAGE.SET_TOKEN('PAYEE_NAME', l_payee_name);
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_CANNOT_HAVE_PAYEE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- ** bug 3143462
   -- check to make sure pay group is assigned over whole interval
   l_daycount := 0;
   for pg in get_pgs loop
      l_sd := greatest(p_start_date, pg.start_date);
      l_ed := least(l_end_date, pg.end_date);
      if l_ed >= l_sd then
	 l_daycount := l_daycount + (l_ed - l_sd) + 1;
      end if;
   end loop;

   if l_daycount <> (l_end_date - p_start_date + 1) then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_PG_NOT_FOUND');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PAYEE_PG_NOT_FOUND';
      RAISE FND_API.G_EXC_ERROR ;
   end if;


   -- make sure payee isn't assigned longer than the payee has payee role
   l_daycount := 0;
   for role in get_roles loop
      l_sd := greatest(p_start_date, role.start_date);
      l_ed := least(l_end_date, role.end_date);
      if l_ed >= l_sd then
	 l_daycount := l_daycount + (l_ed - l_sd) + 1;
      end if;
   end loop;

   if l_daycount <> (l_end_date - p_start_date + 1) then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_ROLE_NOT_FOUND');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PAYEE_ROLE_NOT_FOUND';
      RAISE FND_API.G_EXC_ERROR ;
   end if;

   --+
   --	Start of Payee Assigns Check
   --	CHK validity of dates assigned to payee
   --+
   Validate_Payee_Dates(p_srp_payee_assign_id => p_srp_payee_assign_id,
			p_srp_quota_assign_id => p_srp_quota_assign_id,
                        p_salesrep_id    => p_salesrep_id,
			p_org_id         => p_org_id,
   			p_start_date     => p_start_date,
   			p_end_date	 => p_end_date,
   			p_payee_id       => p_payee_id,
   			p_quota_id       => l_quota_id,
	     		x_loading_status => x_loading_status
	     		);

   --+
   -- End of API body.
   --+
END  Valid_Srp_Payee_Assigns;

-- --------------------------------------------------------------------------+
-- PROCEDURE: CREATE_UPD_NOTE
-- --------------------------------------------------------------------------+
PROCEDURE get_note
  (p_field                  IN VARCHAR2,
   p_old_value              IN VARCHAR2,
   p_new_value              IN VARCHAR2,
   x_msg                    IN OUT nocopy VARCHAR2) IS

   l_note_msg      VARCHAR2(240);
BEGIN
  fnd_message.set_name('CN', 'CN_PAYEE_UPD_NOTE');
  fnd_message.set_token('FIELD', cn_api.get_lkup_meaning(p_field, 'CN_NOTE_FIELDS'));
  fnd_message.set_token('OLD',  p_old_value);
  fnd_message.set_token('NEW',  p_new_value);
  l_note_msg := fnd_message.get;

  IF x_msg IS NOT NULL THEN
     x_msg := x_msg || fnd_global.local_chr(10);
  END IF;
  x_msg := x_msg || l_note_msg;

END get_note;

PROCEDURE raise_note
  (p_srp_payee_assign_id IN NUMBER,
   p_msg                 IN VARCHAR2) IS

   x_note_id       NUMBER;
   x_msg_count     NUMBER;
   x_msg_data      VARCHAR2(240);
   x_return_status VARCHAR2(1);

BEGIN
   jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_srp_payee_assign_id,
       p_source_object_code    => 'CN_SRP_PAYEE_ASSIGNS',
       p_notes                 => p_msg,
       p_notes_detail          => p_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => x_note_id -- returned
       );
END raise_note;

-- --------------------------------------------------------------------------+
-- PROCEDURE: CREATE_SRP_PAYEE_ASSIGNS
-- --------------------------------------------------------------------------+
PROCEDURE Create_Srp_Payee_Assigns
  (  	p_api_version              IN	NUMBER,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		   OUT NOCOPY NUMBER,
	x_msg_data		   OUT NOCOPY VARCHAR2,
	p_srp_quota_assign_id      IN   NUMBER,
	p_payee_id                 IN   NUMBER,
	p_start_date               IN   DATE,
	p_end_date                 IN   DATE,
	x_srp_payee_assign_id      OUT NOCOPY  NUMBER,
	x_object_version_number    OUT NOCOPY  NUMBER,
	x_loading_status           OUT NOCOPY  VARCHAR2
	)  IS

  l_api_name		 CONSTANT VARCHAR2(30)
    := 'Create_Srp_Payee_Assgins';
  l_api_version          CONSTANT NUMBER  := 1.0;

  l_quota_id             NUMBER;
  l_comp_plan_id         NUMBER;
  l_salesrep_id          NUMBER;
  l_org_id               NUMBER;
  l_count                NUMBER;
  l_payee_name           cn_salesreps.name%TYPE;
  l_note_msg             VARCHAR2(240);
  l_note_id              NUMBER;

BEGIN
   --+
   -- Standard Start of API savepoint
   --+
   SAVEPOINT	Create_Srp_Payee_Assigns;
   --+
   -- Standard call to check for call compatibility.
   --+
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --+
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --+
   --  Initialize API return status to success
   --+
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   --+
   -- Start API body
   --+

   -- get properties from given srp_quota_assign_id
   SELECT spa.salesrep_id, sqa.org_id, sqa.quota_id, spa.comp_plan_id
     INTO l_salesrep_id, l_org_id, l_quota_id, l_comp_plan_id
     FROM cn_srp_quota_assigns_all sqa, cn_srp_plan_assigns_all spa
    WHERE srp_quota_assign_id = p_srp_quota_assign_id
      AND sqa.srp_plan_assign_id = spa.srp_plan_assign_id;

   Valid_Srp_Payee_Assigns
     (p_srp_payee_assign_id => NULL,
      p_srp_quota_assign_id => p_srp_quota_assign_id,
      p_salesrep_id         => l_salesrep_id,
      p_org_id              => l_org_id,
      p_payee_id            => p_payee_id,
      p_start_date          => p_start_date,
      p_end_date            => p_end_date,
      x_loading_status      => x_loading_status
      );

   --+
   -- Call the Table Handler
   --+
   cn_srp_payee_assigns_pkg.insert_record
     ( x_srp_payee_assign_id => x_srp_payee_assign_id
      ,p_srp_quota_assign_id => p_srp_quota_assign_id
      ,p_org_id              => l_org_id
      ,p_payee_id	     => p_payee_id
      ,p_quota_id	     => l_quota_id
      ,p_salesrep_id         => l_salesrep_id
      ,p_start_date          => p_start_date
      ,p_end_date            => p_end_date
      ,p_last_update_date    => sysdate
      ,p_last_updated_by     => fnd_global.user_id
      ,p_creation_date       => sysdate
      ,p_created_by          => fnd_global.user_id
      ,p_last_update_login   => fnd_global.login_id);

   insert_trigger
     (new_salesrep_id         => l_salesrep_id,
      new_srp_quota_assign_id => p_srp_quota_assign_id,
      new_start_date          => p_start_date,
      new_end_date            => p_end_date,
      new_org_id              => l_org_id);

   cn_srp_periods_pvt.create_srp_periods_per_quota
     (p_api_version        => 1.0,
      x_return_status      => x_return_status,
      p_salesrep_id        => p_payee_id,
      p_role_id            => g_payee_role,
      p_quota_id           => l_quota_id,
      p_comp_plan_id       => l_comp_plan_id,
      p_start_date         => p_start_date,
      p_end_date           => p_end_date,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_loading_status     => x_loading_status
      );

   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- add note for srp_quota_assigns
   SELECT name INTO l_payee_name
     FROM cn_salesreps
    WHERE salesrep_id = p_payee_id
      AND org_id = l_org_id;

  fnd_message.set_name('CN', 'CN_PAYEE_CRE_NOTE');
  fnd_message.set_token('PAYEE', l_payee_name);
  fnd_message.set_token('START_DATE', p_start_date);
  fnd_message.set_token('END_DATE',   p_end_date);
  l_note_msg := fnd_message.get;

  jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_srp_quota_assign_id,
       p_source_object_code    => 'CN_SRP_QUOTA_ASSIGNS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => l_note_id -- returned
       );

   -- get new version number
   SELECT object_version_number
     INTO x_object_version_number
     FROM cn_srp_payee_assigns_all
    WHERE srp_payee_assign_id = x_srp_payee_assign_id;

   --+
   -- Issue the Commit and recreate the Save Point.
   --+
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   --+
   -- Standard call to get message count and if count is 1, get message info.
   --+
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_srp_payee_assigns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_srp_payee_assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_srp_payee_assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END create_srp_payee_assigns;


-- --------------------------------------------------------------------------+
-- PROCEDURE: UPDATE_SRP_PAYEE_ASSIGNS
-- Update is allowed in only start date, end date
-- --------------------------------------------------------------------------+
PROCEDURE Update_Srp_Payee_Assigns
  (
   p_api_version          IN	NUMBER,
   p_init_msg_list	  IN	VARCHAR2,
   p_commit	    	  IN  	VARCHAR2,
   p_validation_level	  IN  	NUMBER,
   x_return_status	  OUT NOCOPY VARCHAR2,
   x_msg_count		  OUT NOCOPY NUMBER,
   x_msg_data		  OUT NOCOPY VARCHAR2,
   p_srp_payee_assign_id      IN   NUMBER,
   p_payee_id                 IN   NUMBER,
   p_start_date               IN   DATE,
   p_end_date                 IN   DATE,
   p_object_version_number    IN OUT NOCOPY NUMBER,
   x_loading_status       OUT NOCOPY  VARCHAR2
   ) IS

      l_api_name		 CONSTANT VARCHAR2(30)
	                         := 'Update_Srp_Payee_Assigns';
      l_api_version           	 CONSTANT NUMBER  := 1.0;
      l_comp_plan_id             NUMBER;
      l_end_of_time              date := to_date('12/31/9999','MM/DD/YYYY');
      l_payee_name     cn_salesreps.name%TYPE;
      l_old_payee_name cn_salesreps.name%TYPE;

      CURSOR get_old_payee_rec(l_srp_payee_asgn_id number) IS
	 SELECT srp_quota_assign_id, payee_id, start_date, end_date,
	        quota_id, salesrep_id, org_id, object_version_number
	   FROM cn_srp_payee_assigns_all
	  WHERE srp_payee_assign_id = l_srp_payee_asgn_id;

      l_old_rec get_old_payee_rec%ROWTYPE;

      cursor get_worksheets(l_srp_payee_assign_id number) IS
	 SELECT ps.start_date, ps.end_date
	   FROM cn_payment_worksheets_all w,
	        cn_srp_payee_assigns_all  spa,
	        cn_payruns_all            p,
	        cn_period_statuses_all    ps
	  WHERE (w.salesrep_id = spa.payee_id or
		 w.salesrep_id = spa.salesrep_id)
	    AND w.quota_id is NULL
	    AND w.org_id = spa.org_id
	    AND p.payrun_id = w.payrun_id
	    AND p.org_id = w.org_id
	    AND p.pay_period_id = ps.period_id
	    AND p.org_id = ps.org_id
	    AND spa.srp_payee_assign_id = l_srp_payee_assign_id
	    AND spa.org_id = l_old_rec.org_id;

      l_date_range_action_tbl   cn_api.date_range_action_tbl_type;
      l_count number;

      l_key        VARCHAR2(80);
      l_list       wf_parameter_list_t;
      l_event_name VARCHAR2(80);
      l_notemsg    VARCHAR2(2000);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	update_srp_payee_assigns;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   -- API body
   OPEN  get_old_payee_rec(p_srp_payee_assign_id);
   FETCH get_old_payee_rec INTO l_old_rec;
   CLOSE get_old_payee_rec;

   IF l_old_rec.object_version_number <> p_object_version_number THEN
      --
      --Raise an error if the object_version numbers don't match
      --
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_RECORD_UPDATED');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_RECORD_UPDATED';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- get properties from given srp_quota_assign_id
   SELECT spa.comp_plan_id
     INTO l_comp_plan_id
     FROM cn_srp_quota_assigns_all sqa, cn_srp_plan_assigns_all spa
    WHERE sqa.srp_quota_assign_id = l_old_rec.srp_quota_assign_id
      AND sqa.srp_plan_assign_id = spa.srp_plan_assign_id;

   Valid_Srp_Payee_Assigns
     (p_srp_payee_assign_id => p_srp_payee_assign_id,
      p_srp_quota_assign_id => l_old_rec.srp_quota_assign_id,
      p_salesrep_id         => l_old_rec.salesrep_id,
      p_org_id              => l_old_rec.org_id,
      p_payee_id            => p_payee_id,
      p_start_date          => p_start_date,
      p_end_date            => p_end_date,
      x_loading_status      => x_loading_status
      );

   x_loading_status := 'CN_UPDATED';

   -- see if date range is shrinking in any way.  if so, delete and
   -- recreate the payee
   IF (p_start_date > l_old_rec.start_date OR
       Nvl(p_end_date,         l_end_of_time) <
       Nvl(l_old_rec.end_date, l_end_of_time))
     THEN
      -- make sure no worksheets in any part of the shrunk range
      -- this is for bug fix 3390199
      cn_api.get_date_range_diff_action
	(start_date_new    => p_start_date
	 ,end_date_new     => Nvl(p_end_date, l_end_of_time)
	 ,start_date_old   => l_old_rec.start_date
	 ,end_date_old     => Nvl(l_old_rec.end_date, l_end_of_time)
	 ,x_date_range_action_tbl => l_date_range_action_tbl  );
      FOR d IN 1..l_date_range_action_tbl.COUNT LOOP
	 if l_date_range_action_tbl(d).action_flag = 'D' THEN
	    for w in get_worksheets(p_srp_payee_assign_id) loop
	       IF CN_API.date_range_overlap
		 (l_date_range_action_tbl(d).start_date,
		  l_date_range_action_tbl(d).end_date,
		  w.start_date,
		  w.end_date) = true then
		  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		    THEN
		     FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_HAS_WKSHT');
		     FND_MSG_PUB.Add;
		  END IF;
		  x_loading_status := 'CN_PAYEE_HAS_WKSHT';
		  RAISE FND_API.G_EXC_ERROR ;
	       END IF; -- ck date range overlap
	    end loop; -- get_worksheets
	 end if; -- if action = D
      end loop; -- date range loop
   END IF;

   -- update
   cn_srp_payee_assigns_pkg.update_record
     (p_srp_payee_assign_id => p_srp_payee_assign_id,
      p_payee_id	    => p_payee_id,
      p_start_date          => p_start_date,
      p_end_date            => p_end_date,
      p_last_update_date    => Sysdate,
      p_last_updated_by     => fnd_global.user_id,
      p_last_update_login   => fnd_global.login_id);

   -- call triggers
   update_trigger
     (old_salesrep_id         => l_old_rec.salesrep_id,
      old_payee_id            => l_old_rec.payee_id,
      old_start_date          => l_old_rec.start_date,
      old_end_date            => l_old_rec.end_date,
      new_srp_quota_assign_id => l_old_rec.srp_quota_assign_id,
      new_salesrep_id         => l_old_rec.salesrep_id,
      new_payee_id            => p_payee_id,
      new_start_date          => p_start_date,
      new_end_date            => p_end_date,
      new_org_id              => l_old_rec.org_id);

   -- raise business event
   l_event_name := 'oracle.apps.cn.resource.PlanAssign.UpdatePayee';
   l_key := l_event_name || '-' || p_srp_payee_assign_id || '-' ||
     p_object_version_number;

   wf_event.AddParameterToList('SRP_PAYEE_ASSIGN_ID',
			       p_srp_payee_assign_id,l_list);
   wf_event.AddParameterToList('PAYEE_ID',p_payee_id,l_list);
   wf_event.AddParameterToList('START_DATE',p_start_date,l_list);
   wf_event.AddParameterToList('END_DATE',p_end_date,l_list);

   -- Raise Event
   wf_event.raise
     (p_event_name        => l_event_name,
      p_event_key         => l_key,
      p_parameters        => l_list);

   l_list.DELETE;

   -- create srp periods as necessary
   cn_srp_periods_pvt.create_srp_periods_per_quota
     (
      p_api_version        => 1.0,
      x_return_status      => x_return_status,
      p_salesrep_id        => p_payee_id,
      p_role_id            => g_payee_role,
      p_quota_id           => l_old_rec.quota_id,
      p_comp_plan_id       => l_comp_plan_id,
      p_start_date         => p_start_date,
      p_end_date           => p_end_date,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_loading_status     => x_loading_status
      );
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- add note for srp_payee_assigns
   l_notemsg := NULL;
   IF (l_old_rec.payee_id <> p_payee_id) THEN
     SELECT name INTO l_old_payee_name
       FROM cn_salesreps
      WHERE salesrep_id = l_old_rec.payee_id
        AND org_id = l_old_rec.org_id;
     SELECT name INTO l_payee_name
       FROM cn_salesreps
      WHERE salesrep_id = p_payee_id
        AND org_id = l_old_rec.org_id;

     get_note('PAYEE', l_old_payee_name, l_payee_name, l_notemsg);
   END IF;
   IF (l_old_rec.start_date <> p_start_date) THEN
      get_note('START_DATE', l_old_rec.start_date, p_start_date, l_notemsg);
   END IF;
   IF (Nvl(l_old_rec.end_date,fnd_api.g_miss_date) <>
       Nvl(p_end_date,        fnd_api.g_miss_date)) THEN
      get_note('END_DATE', l_old_rec.end_date, p_end_date, l_notemsg);
   END IF;

   IF (l_notemsg IS NOT NULL) THEN
      raise_note(p_srp_payee_assign_id, l_notemsg);
   END IF;

   -- get new version number
   SELECT object_version_number
     INTO p_object_version_number
     FROM cn_srp_payee_assigns_all
    WHERE srp_payee_assign_id = p_srp_payee_assign_id;

   --+
   -- Issue the Commit and recreate the Save Point.
   --+
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   --+
   -- Standard call to get message count and if count is 1, get message info.
   --+
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_srp_payee_assigns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_srp_payee_assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_srp_payee_assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END Update_Srp_Payee_Assigns ;

-- --------------------------------------------------------------------------+
-- Procedure: Valid_Delete_Srp_Payee_Assigns
-- Descr: validate Delete srp Payee Assigns
-- --------------------------------------------------------------------------+
PROCEDURE Valid_Delete_Srp_Payee_Assigns
  (   	p_init_msg_list		   IN	VARCHAR2,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		   OUT NOCOPY NUMBER,
	x_msg_data		   OUT NOCOPY VARCHAR2,
	p_srp_payee_assign_id      IN   NUMBER,
	x_loading_status           OUT NOCOPY  VARCHAR2) IS

     l_api_name           CONSTANT VARCHAR2(30) := 'Valid_Delete_Srp_Payee_Assigns';
     l_start_date         DATE;
     l_end_date           DATE;
     l_org_id             NUMBER;

     CURSOR get_worksheets IS
	select ps.start_date, ps.end_date
	  from cn_payment_worksheets_all w,
	       cn_srp_payee_assigns_all  spa,
	       cn_payruns_all            p,
	       cn_period_statuses_all    ps
	 where (w.salesrep_id = spa.payee_id or
		w.salesrep_id = spa.salesrep_id)
	   AND w.org_id = spa.org_id
	   AND w.quota_id is null
	   AND p.payrun_id = w.payrun_id
	   AND p.pay_period_id = ps.period_id
	   AND p.org_id = ps.org_id
	   AND spa.srp_payee_assign_id = p_srp_payee_assign_id
	   AND spa.org_id = l_org_id;

BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   SELECT start_date, end_date, org_id
     INTO l_start_date, l_end_date, l_org_id
     FROM cn_srp_payee_assigns_all
    WHERE srp_payee_assign_id = p_srp_payee_assign_id;

   -- check payee has no worksheet for bug 3390199
   FOR w IN get_worksheets loop
      IF CN_API.date_range_overlap
	(l_start_date,
	 l_end_date,
	 w.start_date,
	 w.end_date) = true THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYEE_HAS_WKSHT');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAYEE_HAS_WKSHT';
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data   ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );

END valid_delete_srp_payee_assigns;


-- --------------------------------------------------------------------------+
-- Procedure: Delete_srp_payee_assigns
-- Descr: Delete srp Payee Assigns
-- --------------------------------------------------------------------------+
PROCEDURE Delete_Srp_Payee_Assigns
  (  	p_api_version              IN	NUMBER,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		   OUT NOCOPY NUMBER,
	x_msg_data		   OUT NOCOPY VARCHAR2,
	p_srp_payee_assign_id      IN  NUMBER,
	x_loading_status           OUT NOCOPY  VARCHAR2
	) IS


      l_api_name	   CONSTANT VARCHAR2(30)
	:= 'Delete_Srp_Payee_Assigns';
      l_api_version   CONSTANT NUMBER  := 1.0;

      l_start_date    DATE;
      l_end_date      DATE;
      l_salesrep_id   NUMBER;
      l_org_id        NUMBER;
      l_srp_quota_assign_id NUMBER;
      l_note_id       NUMBER;
      l_note_msg      VARCHAR2(240);
      l_payee_id      NUMBER;
      l_payee_name     cn_salesreps.name%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	delete_srp_payee_assigns;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   --+
   -- API body
   --   +

   -- validate delete
   valid_delete_srp_payee_assigns
     (p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_srp_payee_assign_id      => p_srp_payee_assign_id,
      x_loading_status           => x_loading_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- get info for trigger
   SELECT salesrep_id, srp_quota_assign_id, start_date, end_date, org_id, payee_id
     INTO l_salesrep_id, l_srp_quota_assign_id, l_start_date, l_end_date, l_org_id, l_payee_id
     FROM cn_srp_payee_assigns_all
    WHERE srp_payee_assign_id = p_srp_payee_assign_id;

   cn_srp_payee_assigns_pkg.delete_record
     (p_srp_payee_assign_id  => p_srp_payee_assign_id);

   delete_trigger
     (old_salesrep_id         => l_salesrep_id,
      old_srp_quota_assign_id => l_srp_quota_assign_id,
      old_start_date          => l_start_date,
      old_end_date            => l_end_date,
      old_org_id              => l_org_id);

   -- add note for srp_quota_assigns
   SELECT name INTO l_payee_name
     FROM cn_salesreps
    WHERE salesrep_id = l_payee_id
      AND org_id = l_org_id;

  fnd_message.set_name('CN', 'CN_PAYEE_DEL_NOTE');
  fnd_message.set_token('PAYEE',      l_payee_name);
  fnd_message.set_token('START_DATE', l_start_date);
  fnd_message.set_token('END_DATE',   l_end_date);
  l_note_msg := fnd_message.get;

   jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => l_srp_quota_assign_id,
       p_source_object_code    => 'CN_SRP_QUOTA_ASSIGNS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => l_note_id -- returned
       );


   --+
   -- Issue the Commit and recreate the Save Point.
   --+
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   --+
   -- Standard call to get message count and if count is 1, get message info.
   --+
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_srp_payee_assigns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_srp_payee_assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO delete_srp_payee_assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Delete_Srp_Payee_Assigns;

END CN_SRP_PAYEE_ASSIGNS_PVT;

/
