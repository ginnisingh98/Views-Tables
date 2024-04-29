--------------------------------------------------------
--  DDL for Package Body CN_MULTI_RATE_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MULTI_RATE_SCHEDULES_PVT" AS
/*$Header: cnvrschb.pls 120.31.12010000.2 2010/02/24 15:46:08 rajukum ship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30)  :='CN_MULTI_RATE_SCHEDULES_PVT';

-- validate schedule name and commission_unit_code
PROCEDURE validate_schedule
  (p_rate_schedule_id           IN      CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE := NULL,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_number_dim                 IN      CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,
   p_dims_tbl                   IN      dims_tbl_type := g_miss_dims_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE --new
   --R12 MOAC Changes--End
  )
  IS
     l_prompt                  cn_lookups.meaning%TYPE;
     l_dummy                   NUMBER;

     CURSOR name_exists IS
	SELECT 1
	  FROM cn_rate_schedules
	  WHERE name = p_name
	    AND (p_rate_schedule_id IS NULL OR p_rate_schedule_id <> rate_schedule_id)
          --R12 MOAC Changes--Start
          AND  org_id = p_org_id;
          --R12 MOAC Changes--End
BEGIN
   IF (p_name IS NULL) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 l_prompt := cn_api.get_lkup_meaning('RATE_TABLE_NAME', 'CN_PROMPTS');
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', l_prompt);
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   OPEN name_exists;
   FETCH name_exists INTO l_dummy;
   CLOSE name_exists;

   IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_NAME_NOT_UNIQUE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- validate commission_unit_code
   IF (p_commission_unit_code NOT IN ('AMOUNT', 'PERCENT')) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_INVALID_CUC');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- if p_dims_tbl is not empty, then p_number_dim should be equal to the number of
   -- records in p_dims_tbl.  also the sequence numbers should be unique
   IF (p_number_dim <> p_dims_tbl.count) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_X_NUMBER_DIM');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (p_number_dim >= 2) THEN
       for i in p_dims_tbl.first..p_dims_tbl.last-1 loop
         for j in i+1..p_dims_tbl.last loop
--     for i in 1..p_number_dim-1 loop
--       for j in i+1..p_number_dim loop
	    if p_dims_tbl(i).rate_dim_sequence = p_dims_tbl(j).rate_dim_sequence then
	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		  fnd_message.set_name('CN', 'CN_SEQUENCE_NOT_UNIQUE');
		  fnd_msg_pub.ADD;
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    if p_dims_tbl(i).rate_dimension_id = p_dims_tbl(j).rate_dimension_id then
	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		  fnd_message.set_name('CN', 'CN_DUPLICATE_DIM_ASSIGN');
		  fnd_msg_pub.ADD;
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 end loop;
      end loop;
   END IF;

END validate_schedule;

PROCEDURE usage_check(p_rate_schedule_id CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
		      x_usage_code OUT NOCOPY VARCHAR2)
  IS
     CURSOR usage_check IS
	SELECT 'USED'
	  FROM dual
	  WHERE (exists (SELECT 1
			FROM cn_rt_formula_asgns
			WHERE rate_schedule_id = p_rate_schedule_id))
	  OR (exists (SELECT 1
		     FROM cn_rt_quota_asgns
		     WHERE rate_schedule_id = p_rate_schedule_id));
BEGIN
   OPEN usage_check;
   FETCH usage_check INTO x_usage_code;
   CLOSE usage_check;

   IF (x_usage_code IS NULL) THEN
      x_usage_code := 'NOT_USED';
   END IF;
END usage_check;


PROCEDURE create_note_bus_event
  (p_srp_quota_assign_id   IN NUMBER,
   p_rt_quota_asgn_id      IN NUMBER,
   p_rate_sequence         IN NUMBER,
   p_old_amt               IN NUMBER,
   p_new_amt               IN NUMBER,
   p_key                   IN VARCHAR2,
   p_rate_schedule_id      IN VARCHAR2 DEFAULT 0) IS

   x_note_id       NUMBER;
   x_msg_count     NUMBER;
   x_msg_data      VARCHAR2(240);
   x_return_status VARCHAR2(1);
   l_note_msg      VARCHAR2(2000);

   l_seq number := p_rate_sequence - 1;
   l_tier_seq number;

   l_tiers varchar2(500);
   l_tier  varchar2(240);
   l_pct      number := 1;

   l_key        VARCHAR2(80);
   l_event_name VARCHAR2(80);
   l_list       wf_parameter_list_t;

   cursor get_rate_info is
   select s.name, rqa.start_date, rqa.end_date, s.commission_unit_code, s.rate_schedule_id
     from cn_rate_schedules s, cn_rt_quota_asgns rqa
    where s.rate_schedule_id = rqa.rate_schedule_id
      and rqa.rt_quota_asgn_id = p_rt_quota_asgn_id;
   l_info_rec get_rate_info%rowtype;

   cursor get_rate_info_for_mul_rate is
   select s.name,null,null,s.commission_unit_code, s.rate_schedule_id
     from cn_rate_schedules s
    where s.rate_schedule_id =p_rate_schedule_id;

   cursor get_rate_dims(p_rate_schedule_id NUMBER) is
   select d.name, d.rate_dimension_id, d.number_tier
     from cn_rate_sch_dims rsd, cn_rate_dimensions d
    where rate_schedule_id = p_rate_schedule_id
      and rsd.rate_dimension_id = d.rate_dimension_id
    order by rsd.rate_dim_sequence desc;

   cursor get_tier(p_rate_dimension_id number, p_sequence number) is
select decode(rd.dim_unit_code,
              'AMOUNT', rdt.minimum_amount || ' - ' || rdt.maximum_amount,
              'PERCENT', rdt.minimum_amount * 100 || '% - ' || rdt.maximum_amount * 100 || '%',
              'STRING', rdt.string_value,
              'EXPRESSION', e1.name || ' - ' || e2.name) tier
  from cn_rate_dim_tiers_all rdt, cn_rate_dimensions_all rd, cn_calc_sql_exps e1, cn_calc_sql_exps e2
 where rdt.rate_dimension_id = p_rate_dimension_id
   and rdt.tier_sequence = p_sequence
   and rd.rate_dimension_id = rdt.rate_dimension_id
   and rdt.min_exp_id = e1.calc_sql_exp_id(+)
   and rdt.max_exp_id = e2.calc_sql_exp_id(+);

BEGIN
   IF p_old_amt = p_new_amt THEN
      RETURN; -- no change -> no note
   END IF;

if p_rate_schedule_id = 0 then
  open  get_rate_info;
  fetch get_rate_info into l_info_rec;
  close get_rate_info;
else
   open  get_rate_info_for_mul_rate;
  fetch get_rate_info_for_mul_rate into l_info_rec;
  close get_rate_info_for_mul_rate;

end if ;
  if l_info_rec.commission_unit_code = 'PERCENT' then
    l_pct := 100;
  end if;

  for d in get_rate_dims(l_info_rec.rate_schedule_id) loop
    l_tier_seq := mod(l_seq, d.number_tier) + 1;
    l_seq := floor(l_seq / d.number_tier);

    open  get_tier(d.rate_dimension_id, l_tier_seq);
    fetch get_tier into l_tier;
    close get_tier;

    if l_tiers is not null then
      l_tiers := ', ' || l_tiers;
    end if;
    l_tiers := d.name || ' (' || l_tier || ')' || l_tiers;
  end loop;

  if p_rate_schedule_id = 0 then
  fnd_message.set_name('CN', 'CN_SRP_RATE_ASSIGNS_NOTE');
  fnd_message.set_token('RATE_TABLE', l_info_rec.name);
  fnd_message.set_token('START_DATE', l_info_rec.start_date);
  fnd_message.set_token('END_DATE',   l_info_rec.end_date);
  fnd_message.set_token('DIMENSIONS', l_tiers);
  fnd_message.set_token('OLD', p_old_amt * l_pct);
  fnd_message.set_token('NEW', p_new_amt * l_pct);

  l_note_msg := fnd_message.get();
   jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_srp_quota_assign_id ,--p_srp_quota_assign_id
       p_source_object_code    => 'CN_SRP_QUOTA_ASSIGNS',--CN_SRP_QUOTA_ASSIGNS
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => x_note_id -- returned
       );

  else
  fnd_message.set_name('CN', 'CN_MULTI_RATE_ASSIGNS_NOTE');
  fnd_message.set_token('RATE_TABLE', l_info_rec.name);
  fnd_message.set_token('DIMENSIONS', l_tiers);
  fnd_message.set_token('OLD', p_old_amt * l_pct);
  fnd_message.set_token('NEW', p_new_amt * l_pct);
  l_note_msg := fnd_message.get();
  jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_rate_schedule_id ,--p_srp_quota_assign_id
       p_source_object_code    => 'CN_RATE_SCHEDULES',--CN_SRP_QUOTA_ASSIGNS
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => x_note_id -- returned
       );
  end if;

  -- create business event also
    if p_rate_schedule_id = 0 then
  l_event_name := 'oracle.apps.cn.resource.PlanAssign.UpdateRate';
  l_key := l_event_name || '-' || p_key;

  wf_event.AddParameterToList('SRP_QUOTA_ASSIGN_ID',p_srp_quota_assign_id,l_list);
  wf_event.AddParameterToList('RT_QUOTA_ASGN_ID',p_rt_quota_asgn_id,l_list);
  wf_event.AddParameterToList('RATE_SEQUENCE',p_rate_sequence,l_list);
  wf_event.AddParameterToList('COMMISSION_AMOUNT',p_new_amt,l_list);

  -- Raise Event
  wf_event.raise
    (p_event_name        => l_event_name,
     p_event_key         => l_key,
     p_parameters        => l_list);

  l_list.DELETE;
  end if;

END create_note_bus_event;

-- Start of comments
--    API name        : Create_Schedule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version          IN      NUMBER       Required
--                      p_init_msg_list        IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit               IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level     IN      NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_name                 IN      VARCHAR2     Required
--                      p_commission_unit_code IN      VARCHAR2     Required
--                      p_number_dim           IN      NUMBER       Required
--                      p_dims_tbl             IN      dims_tbl_type Optional
--                        Default = g_miss_dims_tbl
--    OUT             : x_rate_schedule_id     OUT     NUMBER
--                      x_return_status        OUT     VARCHAR2(1)
--                      x_msg_count            OUT     NUMBER
--                      x_msg_data             OUT     VARCHAR2(2000)
--    Version :         Current version        1.0
--                      Initial version        1.0
--
--    Notes           : Create rate schedule and schedule dimensions
--                      1) Validate schedule name (should be unique)
--                      2) Validate commission_unit_code (valid values are AMOUNT, PERCENT)
--                      3) Validate number_dim which should equal the number of dimensions
--                         in p_dims_tbl if it is not empty
--
-- End of comments
PROCEDURE Create_Schedule
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE     ,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_number_dim                 IN      CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,  -- not used
   p_dims_tbl                   IN      dims_tbl_type := g_miss_dims_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   x_rate_schedule_id           IN OUT NOCOPY     CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                 CONSTANT VARCHAR2(30) := 'Create_Schedule';
     l_api_version              CONSTANT NUMBER       := 1.0;
     l_number_dim               CN_RATE_SCHEDULES.NUMBER_DIM%TYPE  := 0;
     l_temp_id                  CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE;

     --R12 Notes Hoistory
     l_rate_sch_name    VARCHAR2(80);
     l_note_msg          VARCHAR2(240);
     l_note_id           NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
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

   -- calculate number of dimensions (p_number_dim not used)
   -- set number_dim := number of dimensions of p_dims_tbl
   l_number_dim := p_dims_tbl.count;

   -- API body
   validate_schedule(p_rate_schedule_id     => NULL, -- validation for new record creation
		     p_name                 => p_name,
		     p_commission_unit_code => p_commission_unit_code,
		     p_number_dim           => l_number_dim,
		     p_dims_tbl             => p_dims_tbl,
                 --R12 MOAC Changes--Start
                 p_org_id               => p_org_id
                 --R12 MOAC Changes--End
                 );

   -- call table handler to create rate schedule record in cn_rate_schedules
   cn_multi_rate_schedules_pkg.insert_row(x_rate_schedule_id     => x_rate_schedule_id,
					  x_name                 => p_name,
					  x_commission_unit_code => p_commission_unit_code,
					  x_number_dim           => l_number_dim,
                      --R12 MOAC Changes--Start
                      x_org_id               => p_org_id);
                      --R12 MOAC Changes--End

   -- *********************************************************************
   -- ************ Start - R12 Notes History ************** ***************
   -- *********************************************************************
      select name into l_rate_sch_name
      from   cn_rate_schedules
      where  rate_schedule_id = x_rate_schedule_id;

      fnd_message.set_name('CN', 'CNR12_NOTE_RT_CREATE');
      fnd_message.set_token('RT_NAME', l_rate_sch_name);
      l_note_msg := fnd_message.get;

      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_rate_schedule_id,
                            p_source_object_code      => 'CN_RATE_SCHEDULES',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

   -- call table handler to create dimension assignments and populate cn_rate_tiers
   IF (p_dims_tbl.COUNT > 0) THEN
      FOR i IN p_dims_tbl.first..p_dims_tbl.last LOOP
	 l_temp_id := NULL;
	 cn_rate_sch_dims_pkg.insert_row(x_rate_sch_dim_id     => l_temp_id,
					 x_rate_dimension_id   => p_dims_tbl(i).rate_dimension_id,
					 x_rate_schedule_id    => x_rate_schedule_id,
					 x_rate_dim_sequence   => p_dims_tbl(i).rate_dim_sequence,
                     --R12 MOAC Changes--Start
                     x_org_id              => p_org_id);
                     --R12 MOAC Changes--End
       END LOOP;
   END IF;

   -- leave table empty and fill in tiers as needed for sparse impl
   /*
   -- create records in cn_rate_tiers (product[T_i] tiers for i=1..number of dims)
   create_rate_tiers(p_rate_schedule_id   => x_rate_schedule_id,
		     p_rate_dim_sequence  => NULL);
     */

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Schedule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END Create_Schedule;


-- Start of comments
--    API name        : Update_Schedule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version          IN      NUMBER       Required
--                      p_init_msg_list        IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit               IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level     IN      NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_rate_schedule_id     IN      NUMBER       Required
--                      p_name                 IN      VARCHAR2     Required
--                      p_commission_unit_code IN      VARCHAR2     Required
--                      p_number_dim           IN      NUMBER       Required
--                      p_dims_tbl             IN      dims_tbl_type Optional
--                        Default = g_miss_dims_tbl
--    OUT             : x_return_status        OUT     VARCHAR2(1)
--                      x_msg_count            OUT     NUMBER
--                      x_msg_data             OUT     VARCHAR2(2000)
--    Version :         Current version        1.0
--                      Initial version        1.0
--
--    Notes           : Update rate schedule and schedule dimensions
--                      1) Validate schedule name (should be unique)
--                      2) Validate commission_unit_code (valid values are AMOUNT, PERCENT)
--                      3) Validate number_dim which should equal the number of dimensions
--                         in p_dims_tbl if it is not empty
--                      4) Insert new dimensions and delete obsolete dimensions
--                      5) Update rate tiers also
--                      6) If this rate table is used, then update of dimensions and
--                         commission_unit_code is not allowed
--
-- End of comments
PROCEDURE Update_Schedule
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_id           IN      CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_number_dim                 IN      CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,  -- not used
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- Changed
   --R12 MOAC Changes--End
   p_dims_tbl                   IN      dims_tbl_type := g_miss_dims_tbl,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Update_Schedule';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_temp_id                     CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE;
     l_commission_unit_code_old    CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE;
     l_number_dim                  CN_RATE_SCHEDULES.NUMBER_DIM%TYPE  := 0;
     l_number_dim_old              CN_RATE_SCHEDULES.NUMBER_DIM%TYPE  := 0;
     l_delete_flag                 VARCHAR2(1);
     l_usage_code                  VARCHAR2(30);
     i                             pls_integer;

     --R12 Notes Hoistory
     l_rate_sch_old    VARCHAR2(80);
     l_type_old        VARCHAR2(30);
     l_note_msg        VARCHAR2(240);
     l_note_id         NUMBER;
     l_consolidated_note           VARCHAR2(2000);


     CURSOR schedule_info IS
	SELECT commission_unit_code, number_dim
	  FROM cn_rate_schedules
	  WHERE rate_schedule_id = p_rate_schedule_id;

     CURSOR db_dim_assignments IS
	SELECT rate_sch_dim_id
	  FROM cn_rate_sch_dims
	  WHERE rate_schedule_id = p_rate_schedule_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
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

   -- calculate number of dimensions (p_number_dim not used)
   -- set number_dim := number of dimensions of p_dims_tbl
   l_number_dim := p_dims_tbl.count;

   -- API body
   validate_schedule(p_rate_schedule_id     => p_rate_schedule_id,
		     p_name                 => p_name,
		     p_commission_unit_code => p_commission_unit_code,
		     p_number_dim           => l_number_dim,
		     p_dims_tbl             => p_dims_tbl,
             --R12 MOAC Changes--Start
             p_org_id               => p_org_id
             --R12 MOAC Changes--End
                );

   OPEN schedule_info;
   FETCH schedule_info INTO l_commission_unit_code_old, l_number_dim_old;
   CLOSE schedule_info;

   -- if it is used, then can not update commission_unit_code and number_dim as well
   -- as dimension assignments
   usage_check(p_rate_schedule_id => p_rate_schedule_id,
	       x_usage_code       => l_usage_code);
   IF (l_usage_code = 'USED' AND
       (l_commission_unit_code_old <> p_commission_unit_code OR	l_number_dim > 0))
     THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_SCHEDULE_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- Start - R12 Notes History Query for old Rate Table Name
   select name into l_rate_sch_old
   from   cn_rate_schedules
   where  rate_schedule_id = p_rate_schedule_id;

   select commission_unit_code into l_type_old
   from   cn_rate_schedules
   where  rate_schedule_id = p_rate_schedule_id;
   -- End - R12 Notes History Query for old Rate Table Name

   -- lock rate schedule for update or delete
   cn_multi_rate_schedules_pkg.lock_row
     (x_rate_schedule_id      => p_rate_schedule_id,
      x_object_version_number => p_object_version_number);

   IF (p_dims_tbl.COUNT > 0) THEN
      -- we passed in a dimensions table... delete and re-create the table as the
      -- dimensions have been changed

      -- delete all rate tiers and rate_sch_dims
      delete from cn_rate_sch_dims where rate_schedule_id = p_rate_schedule_id;
      delete from cn_rate_tiers    where rate_schedule_id = p_rate_schedule_id;

      -- reassign rate schedule dimensions
      FOR i IN p_dims_tbl.first..p_dims_tbl.last LOOP
	 l_temp_id := NULL;
	 cn_rate_sch_dims_pkg.insert_row
	   (x_rate_sch_dim_id     => l_temp_id,
	    x_rate_dimension_id   => p_dims_tbl(i).rate_dimension_id,
	    x_rate_schedule_id    => p_rate_schedule_id,
	    x_rate_dim_sequence   => p_dims_tbl(i).rate_dim_sequence,
          --R12 MOAC Changes--Start
          x_org_id             => p_org_id
          --R12 MOAC Changes--End
         );
      END LOOP;

      --  rate table being built up again from scratch - purge existing tiers
      delete from cn_rate_tiers where rate_schedule_id = p_rate_schedule_id;
      /*
      -- create records in cn_rate_tiers (product[T_i] tiers for i=1..number of dims)
      create_rate_tiers(p_rate_schedule_id   => p_rate_schedule_id,
			p_rate_dim_sequence  => NULL);
	*/
   END IF;

   -- get correct # of dims
   OPEN  schedule_info;
   FETCH schedule_info INTO l_commission_unit_code_old, l_number_dim;
   CLOSE schedule_info;

   cn_multi_rate_schedules_pkg.update_row
     (x_rate_schedule_id      => p_rate_schedule_id,
      x_name                  => p_name,
      x_commission_unit_code  => p_commission_unit_code,
      x_number_dim            => l_number_dim,
      x_object_version_number => p_object_version_number);

   -- *********************************************************************
   -- ************ Start - R12 Notes History ************** ***************
   -- *********************************************************************

   l_consolidated_note := '';

   IF (p_name <> l_rate_sch_old) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_RT_NAME_UPDATE');
        fnd_message.set_token('OLD_RT', l_rate_sch_old);
        fnd_message.set_token('NEW_RT', p_name);
        l_note_msg := fnd_message.get;
	l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);

	/*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_schedule_id,
                            p_source_object_code      => 'CN_RATE_SCHEDULES',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
	*/
     END IF;

     IF (p_commission_unit_code <> l_type_old) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_RT_ASGN_TYPE_UPDATE');
        fnd_message.set_token('OLD_RT_TYPE', l_type_old);
        fnd_message.set_token('NEW_RT_TYPE', p_commission_unit_code);
        l_note_msg := fnd_message.get;
	l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);

	/*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_schedule_id,
                            p_source_object_code      => 'CN_RATE_SCHEDULES',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
	*/
     END IF;

     if LENGTH(l_consolidated_note) > 1 THEN
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_schedule_id,
                            p_source_object_code      => 'CN_RATE_SCHEDULES',
                            p_notes                   => l_consolidated_note,
                            p_notes_detail            => l_consolidated_note,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

     END IF;

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Schedule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END Update_Schedule;

-- Start of comments
--    API name        : Delete_Schedule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN      NUMBER       Required
--                      p_init_msg_list       IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN      NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_rate_schedule_id    IN      NUMBER       Required
--                      p_name                IN      VARCHAR2     Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Delete rate schedule
--                      1) If it is used, it can not be deleted
--                      2) If it can be deleted, delete corresponding records in
--                         cn_rate_sch_dims and cn_rate_tiers
--
-- End of comments
PROCEDURE Delete_Schedule
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_id           IN      CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
   --R12 MOAC Changes--Start
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- new
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Schedule';
     l_api_version               CONSTANT NUMBER       := 1.0;
     l_usage_code                VARCHAR2(30);

     --R12 Notes Hoistory
     l_rate_sch_name    VARCHAR2(80);
     l_org_id           Number;
     l_note_msg         VARCHAR2(240);
     l_note_id          NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
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

   -- API body

   usage_check(p_rate_schedule_id => p_rate_schedule_id,
	       x_usage_code => l_usage_code);
   IF (l_usage_code = 'USED') THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_SCHEDULE_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   /* Start - R12 Notes History */
   SELECT org_id INTO l_org_id
   FROM   cn_rate_schedules
   WHERE  rate_schedule_id = p_rate_schedule_id;

   SELECT name INTO l_rate_sch_name
   FROM   cn_rate_schedules
   WHERE  rate_schedule_id = p_rate_schedule_id;
   /* End - R12 Notes History */

   -- deleting a rate schedule causes cascading delete
   cn_multi_rate_schedules_pkg.delete_row(p_rate_schedule_id);

   -- *********************************************************************
   -- ************ Start - R12 Notes History ******************************
   -- *********************************************************************
        IF (l_org_id <> -999) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_RT_DELETE');
        fnd_message.set_token('RT_NAME', l_rate_sch_name);
        l_note_msg := fnd_message.get;

        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_org_id,
                            p_source_object_code      => 'CN_DELETED_OBJECTS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
     END IF;

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Schedule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END Delete_Schedule;

-- Start of comments
--      API name        : Delete_Dimension_Assign
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version        IN      NUMBER       Required
--                        p_init_msg_list      IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit             IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level   IN      NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rate_sch_dim_id    IN      NUMBER
--                        p_rate_schedule_id   IN      NUMBER
--      OUT             : x_return_status      OUT     VARCHAR2(1)
--                        x_msg_count          OUT     NUMBER
--                        x_msg_data           OUT     VARCHAR2(2000)
--      Version :         Current version      1.0
--                        Initial version      1.0
--
--      Notes           : Delete schedule dimension
--                        1) If the rate schedule is used, its dimensions can not be deleted
--                        2) delete the corresponding records in cn_rate_sch_dims and cn_rate_tiers
--                        3) update cn_rate_schedules.number_dim if not called from form
--                        4) rate_dim_sequence is not adjusted here, users should take care
--                           of the adjustment by calling
--                           update_dimension_assign
--
-- End of comments
PROCEDURE delete_dimension_assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_sch_dim_id            IN      CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE,
   p_rate_schedule_id           IN      CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
   --R12 MOAC Changes--Start
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- new
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Dimension_Assign';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_usage_code              VARCHAR2(30);
     l_rate_dim_sequence       NUMBER;

     --R12 Notes Hoistory
     l_dimension_name_old   VARCHAR2(30);
     l_rate_sch_name_old    VARCHAR2(80);
     l_org_id               Number;
     l_note_msg             VARCHAR2(240);
     l_note_id              NUMBER;
     l_dimension_id         NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Dimension_Assign;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
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

   -- API body

   usage_check(p_rate_schedule_id => p_rate_schedule_id,
	       x_usage_code => l_usage_code);
   IF (l_usage_code = 'USED') THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_SCHEDULE_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- delete the records corresponding to this dimension in cn_rate_tiers
   BEGIN
      SELECT rate_dim_sequence
	INTO l_rate_dim_sequence
	FROM cn_rate_sch_dims
       WHERE rate_schedule_id = p_rate_schedule_id
	 AND rate_sch_dim_id  = p_rate_sch_dim_id;
   EXCEPTION
      when no_data_found then
	 fnd_message.set_name('CN', 'CN_RECORD_DELETED');
	 fnd_msg_pub.add;
	 raise fnd_api.g_exc_unexpected_error;
   END;

   delete_rate_tiers(p_rate_schedule_id  => p_rate_schedule_id,
		     p_rate_dim_sequence => l_rate_dim_sequence);

   /* Start - R12 Notes History */

   SELECT org_id,rate_dimension_id INTO l_org_id,l_dimension_id
   FROM   cn_rate_sch_dims
   WHERE  rate_sch_dim_id  = p_rate_sch_dim_id;

   select name into l_dimension_name_old
   from   cn_rate_dimensions
   where  rate_dimension_id = l_dimension_id;

   select name into l_rate_sch_name_old
   from   cn_rate_schedules
   where  rate_schedule_id = p_rate_schedule_id;

   /* End - R12 Notes History */

   -- delete records in cn_rate_sch_dims
   cn_rate_sch_dims_pkg.delete_row(x_rate_sch_dim_id   => p_rate_sch_dim_id);

   -- *********************************************************************
   -- ************ Start - R12 Notes History ******************************
   -- *********************************************************************
    IF (l_org_id <> -999) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_RT_ASGN_DIM_DELETE');
        fnd_message.set_token('OLD_DIM', l_dimension_name_old);
        fnd_message.set_token('RT_NAME', l_rate_sch_name_old);
        l_note_msg := fnd_message.get;

        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_schedule_id,
                            p_source_object_code      => 'CN_RATE_SCHEDULES',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
     END IF;

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

   -- update rate schedule (number_dim is treated as a "virtual column" - just a
   -- count(*) of dimensions assigned to the rate_schedule... it is not ovn controlled here
   UPDATE cn_rate_schedules
      SET number_dim = (select count(*) from cn_rate_sch_dims
		         where rate_schedule_id = p_rate_schedule_id)
    WHERE rate_schedule_id = p_rate_schedule_id;

   -- push dimension sequence numbers down by one
   --update cn_rate_sch_dims set rate_dim_sequence = rate_dim_sequence - 1
   -- where rate_schedule_id   = p_rate_schedule_id
   --   and rate_dim_sequence >= l_rate_dim_sequence;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END Delete_Dimension_Assign;

-- Start of comments
--      API name        : Update_Dimension_Assign
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version        IN      NUMBER       Required
--                        p_init_msg_list      IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit             IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level   IN      NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rate_sch_dim_id    IN      NUMBER
--                        p_rate_schedule_id   IN      NUMBER
--                        p_rate_dimension_id  IN      NUMBER
--                        p_rate_dim_sequence  IN      NUMBER
--      OUT             : x_return_status      OUT     VARCHAR2(1)
--                        x_msg_count          OUT     NUMBER
--                        x_msg_data           OUT     VARCHAR2(2000)
--      Version :         Current version      1.0
--                        Initial version      1.0
--
--      Notes           : Update dimension assignment
--                        1) If the rate table is used, then update is not allowed
--                        2) If it can be updated, update records in cn_rate_sch_dims and cn_rate_tiers
--
-- End of comments
PROCEDURE update_dimension_assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_sch_dim_id            IN      CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE,
   p_rate_schedule_id           IN      CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dimension_id          IN      CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE := cn_api.g_miss_num,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE := cn_api.g_miss_num, -- not used
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Dimension_Assign';
     l_api_version              CONSTANT NUMBER       := 1.0;

     l_rate_dimension_id_old    CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE;
     l_number_tier_old          CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE;
     l_number_tier_new          CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE;
     l_usage_code               VARCHAR2(30);
     l_rate_dim_sequence        NUMBER;
     l_count                    NUMBER;

     --R12 Notes Hoistory
     l_rate_dimension_id       Number;
     l_dimension_name_old      VARCHAR2(30);
     l_dimension_name_new      VARCHAR2(30);
     l_note_msg                VARCHAR2(240);
     l_note_id                 NUMBER;

     CURSOR old_sch_dim IS
	SELECT rate_dimension_id, rate_dim_sequence
	  FROM cn_rate_sch_dims
	  WHERE rate_sch_dim_id = p_rate_sch_dim_id;

     CURSOR old_dim_info IS
	SELECT number_tier
	  FROM cn_rate_dimensions
	  WHERE rate_dimension_id = l_rate_dimension_id_old;

     CURSOR new_dim_info IS
	SELECT number_tier
	  FROM cn_rate_dimensions
	  WHERE rate_dimension_id = p_rate_dimension_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Dimension_Assign;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
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

   -- API body

   usage_check(p_rate_schedule_id,
	       x_usage_code => l_usage_code);
   IF (l_usage_code = 'USED') THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_SCHEDULE_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   OPEN old_sch_dim;
   FETCH old_sch_dim INTO l_rate_dimension_id_old, l_rate_dim_sequence;
   CLOSE old_sch_dim;

   OPEN old_dim_info;
   FETCH old_dim_info INTO l_number_tier_old;
   CLOSE old_dim_info;

   OPEN new_dim_info;
   FETCH new_dim_info INTO l_number_tier_new;
   CLOSE new_dim_info;

   -- if rate dimension is replaced, then adjust cn_rate_tiers also
   -- remove the dimension and re-create it
   IF (l_rate_dimension_id_old <> p_rate_dimension_id) THEN
      -- make sure the dimension hasn't already been assigned
      select count(*) into l_count from cn_rate_sch_dims
       where rate_schedule_id  = p_rate_schedule_id
	 and rate_dimension_id = p_rate_dimension_id;
      if l_count > 0 then
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_DUPLICATE_DIM_ASSIGN');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;
      IF (l_number_tier_new > l_number_tier_old) THEN
	 create_rate_tiers(p_rate_schedule_id   => p_rate_schedule_id,
			   p_rate_dim_sequence  => l_rate_dim_sequence,
			   p_tier_sequence      => l_number_tier_old + 1,
			   p_num_tiers          => l_number_tier_new - l_number_tier_old,
               --R12 MOAC Changes--Start
               p_org_id             => p_org_id );
               --R12 MOAC Changes--End
      ELSIF (l_number_tier_new < l_number_tier_old) THEN
	 delete_rate_tiers(p_rate_schedule_id   => p_rate_schedule_id,
			   p_rate_dim_sequence  => l_rate_dim_sequence,
			   p_tier_sequence      => l_number_tier_new + 1,
			   p_num_tiers          => l_number_tier_old - l_number_tier_new);
      END IF;
   END IF;

   -- Move Up/Down - Setting Commission rates to 0
    if ( (l_rate_dimension_id_old = p_rate_dimension_id) AND (p_rate_dim_sequence <> l_rate_dim_sequence)) THEN
           delete from cn_rate_tiers where rate_sequence <> 1 AND rate_schedule_id= p_rate_schedule_id AND org_id = p_org_id;
    END IF;

   -- Start - R12 Notes History Query for old dimension id assigned to rate table
   select rate_dimension_id into l_rate_dimension_id
   from   cn_rate_sch_dims
   where  rate_sch_dim_id = p_rate_sch_dim_id;

   select name into l_dimension_name_old
   from   cn_rate_dimensions
   where  rate_dimension_id = l_rate_dimension_id;
   -- End - R12 Notes History Query for old dimension id assigned to rate table

   -- lock and update the row
   cn_rate_sch_dims_pkg.lock_row
     (x_rate_sch_dim_id       => p_rate_sch_dim_id,
      x_object_version_number => p_object_version_number);

   cn_rate_sch_dims_pkg.update_row
     (x_rate_sch_dim_id       => p_rate_sch_dim_id,
      x_rate_schedule_id      => p_rate_schedule_id,
      x_rate_dimension_id     => p_rate_dimension_id,
      x_rate_dim_sequence     => p_rate_dim_sequence,
      x_object_version_number => p_object_version_number);

   -- *********************************************************************
   -- ************ Start - R12 Notes History ************** ***************
   -- *********************************************************************
   IF (p_rate_dimension_id <> l_rate_dimension_id) THEN

        select name into l_dimension_name_new
        from   cn_rate_dimensions
        where  rate_dimension_id = p_rate_dimension_id;

        fnd_message.set_name('CN', 'CNR12_NOTE_RT_ASGN_DIM_UPDATE');
        fnd_message.set_token('OLD_DIM', l_dimension_name_old);
        fnd_message.set_token('NEW_DIM', l_dimension_name_new);
        l_note_msg := fnd_message.get;

        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_schedule_id,
                            p_source_object_code      => 'CN_RATE_SCHEDULES',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
     END IF;
   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************
   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END Update_Dimension_Assign;

-- Start of comments
--      API name        : Create_Dimension_Assign
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version        IN      NUMBER       Required
--                        p_init_msg_list      IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit             IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level   IN      NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rate_schedule_id   IN      NUMBER
--                        p_rate_dimension_id  IN      NUMBER
--                        p_rate_dim_sequence  IN      NUMBER
--      OUT             : x_rate_sch_dim_id    OUT     NUMBER
--                        x_return_status      OUT     VARCHAR2(1)
--                        x_msg_count          OUT     NUMBER
--                        x_msg_data           OUT     VARCHAR2(2000)
--      Version :         Current version      1.0
--                        Initial version      1.0
--
--      Notes           : Create dimension assignment
--                        1) If the rate table is used, new assignment can not be created
--                        2) if the rate table is not used, update cn_rate_tiers;
--                           and adjust cn_rate_tiers.rate_sequence
--                        3) update cn_rate_schedules.number_dim
--                        4) rate_dim_sequence is not adjusted here, users should do it by
--                           calling update_dimension_assign
--
-- End of comments
PROCEDURE create_dimension_assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_id           IN      CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dimension_id          IN      CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   x_rate_sch_dim_id            IN OUT NOCOPY     CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Create_Dimension_Assign';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_usage_code              VARCHAR2(30);
     l_dummy                   NUMBER;
     l_count                   NUMBER;
     l_num_dims                NUMBER;
     l_rate_dim_sequence       NUMBER := p_rate_dim_sequence;

     --R12 Notes Hoistory
     l_dimension_name          VARCHAR2(30);
     l_rate_sch_name           VARCHAR2(80);
     l_note_msg                VARCHAR2(240);
     l_note_id                 NUMBER;

     CURSOR tier_exist IS
	SELECT count(1) from cn_rate_tiers
	 WHERE rate_schedule_id = p_rate_schedule_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Dimension_Assign;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
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

   -- API body

   usage_check(p_rate_schedule_id,
	       x_usage_code => l_usage_code);
   IF (l_usage_code = 'USED') THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_SCHEDULE_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- make sure the dimension hasn't already been assigned
   select count(*) into l_count from cn_rate_sch_dims
    where rate_schedule_id  = p_rate_schedule_id
      and rate_dimension_id = p_rate_dimension_id;
   if l_count > 0 then
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_DUPLICATE_DIM_ASSIGN');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- if assigned rate sequence is too high, bring it down to a valid value
   select count(*) into l_num_dims
     from cn_rate_sch_dims
    where rate_schedule_id  = p_rate_schedule_id;

   --push dimensions with higher sequence numbers than l_rate_dim_sequence up by one
   --   l_rate_dim_sequence := l_num_dims + 1;
   --end if;

   -- push dimensions with higher sequence numbers than l_rate_dim_sequence up by one
   --update cn_rate_sch_dims set rate_dim_sequence = rate_dim_sequence + 1
   -- where rate_schedule_id   = p_rate_schedule_id
   --   and rate_dim_sequence >= l_rate_dim_sequence;

   -- create this dimension assignment in cn_rate_sch_dims
   cn_rate_sch_dims_pkg.insert_row(x_rate_sch_dim_id    => x_rate_sch_dim_id,
				   x_rate_schedule_id   => p_rate_schedule_id,
				   x_rate_dimension_id  => p_rate_dimension_id,
				   x_rate_dim_sequence  => l_rate_dim_sequence,
                           --R12 MOAC Changes--Start
                           x_org_id             => p_org_id
                           --R12 MOAC Changes--End
                          );

   -- *********************************************************************
   -- ************ Start - R12 Notes History ******************************
   -- *********************************************************************
      select name into l_dimension_name
      from   cn_rate_dimensions
      where  rate_dimension_id = p_rate_dimension_id;

      select name into l_rate_sch_name
      from   cn_rate_schedules
      where  rate_schedule_id = p_rate_schedule_id;

      fnd_message.set_name('CN', 'CNR12_NOTE_RT_ASGN_DIM_CREATE');
      fnd_message.set_token('RT_DIM', l_dimension_name);
      fnd_message.set_token('RT_NAME', l_rate_sch_name);
      l_note_msg := fnd_message.get;

      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_schedule_id,
                            p_source_object_code      => 'CN_RATE_SCHEDULES',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

   -- update rate schedule (number_dim is treated as a "virtual column" - just a
   -- count(*) of dimensions assigned to the rate_schedule... it is not ovn controlled here
   UPDATE cn_rate_schedules
      SET number_dim = l_num_dims + 1
    WHERE rate_schedule_id = p_rate_schedule_id;

   -- insert records into cn_rate_tiers
   OPEN  tier_exist;
   FETCH tier_exist INTO l_dummy;
   CLOSE tier_exist;

   IF (l_dummy > 0) THEN
      create_rate_tiers(p_rate_schedule_id   => p_rate_schedule_id,
			p_rate_dim_sequence  => l_rate_dim_sequence,
            --R12 MOAC Changes--Start
            p_org_id             => p_org_id
            --R12 MOAC Changes--End
            );
      -- if table had no tiers, then nothing to migrate
      /*
    ELSE
      create_rate_tiers(p_rate_schedule_id   => p_rate_schedule_id,
			p_rate_dim_sequence  => NULL);
      */
   END IF;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END Create_Dimension_Assign;

-- 1. if two or more tiers are inserted at the same time, create_rate_tiers will
--    face problems. The solution is to use the actual number of tiers in the dimension
--    instead of cn_rate_dimensions.number_tier
-- 2. form processing changes in the following order: delete --> update --> insert
PROCEDURE create_rate_tiers
  (p_rate_schedule_id                   CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dim_sequence                  CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE := NULL,
   p_tier_sequence                      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE    := NULL,
   p_num_tiers                          NUMBER := 1,
   --R12 MOAC Changes--Start
   p_org_id                      IN     CN_RATE_TIERS.ORG_ID%TYPE
   --R12 MOAC Changes--End
  ) IS

   l_number_dim        CN_RATE_SCHEDULES.NUMBER_DIM%TYPE;
   l_coords            NUM_TBL_TYPE;
   l_seq               NUMBER;
   l_new_seq           NUMBER;
   l_dim_count         NUMBER := 0; -- number of dimensions in cn_rate_sch_dims for this rate table
   dim_size_table      num_tbl_type;
   l_num_tiers         number := nvl(p_num_tiers,1);

   CURSOR dims_info IS
      SELECT COUNT(*) number_tier
	FROM cn_rate_dim_tiers rdt,
	     cn_rate_sch_dims rsd
       WHERE rdt.rate_dimension_id = rsd.rate_dimension_id
	 AND rsd.rate_schedule_id = p_rate_schedule_id
       GROUP BY rsd.rate_dim_sequence
       ORDER BY rsd.rate_dim_sequence;

      CURSOR get_rate_tiers IS
      SELECT rate_tier_id, rate_sequence
	FROM cn_rate_tiers
       WHERE rate_schedule_id = p_rate_schedule_id;

BEGIN
   SELECT number_dim
     INTO l_number_dim
     FROM cn_rate_schedules
    WHERE rate_schedule_id = p_rate_schedule_id;

   -- build dimension size table
   FOR dim IN dims_info LOOP
      l_dim_count := l_dim_count + 1;
      dim_size_table(l_dim_count) := dim.number_tier;
   END LOOP;

   -- each dimension must have at least one tier. otherwise, raise an exception
   FOR j IN 1..l_dim_count LOOP
      IF (dim_size_table(j) = 0) THEN
	 fnd_message.set_name('CN', 'CN_EMPTY_DIMENSION');
	 RAISE fnd_api.g_exc_error;
      END IF;
   END LOOP;

   -- initialize coordinates
   for d in 1..l_dim_count loop
      l_coords(d) := 1;
   end loop;

   -- note all arrays are 1-indexed
   for t in get_rate_tiers loop
      -- get coordinates of t
      l_seq := t.rate_sequence;

      for d in reverse 1..l_dim_count loop
	 -- get old coordinates of rate tier
	 if p_tier_sequence is null then
	    if d = p_rate_dim_sequence then
	       l_coords(d) := 1;
	     else
	       l_coords(d) := mod(l_seq-1, dim_size_table(d)) + 1;
	       l_seq := (l_seq - l_coords(d)) / dim_size_table(d) + 1;
	    end if;
	  else
	    l_coords(d) := mod(l_seq-1, dim_size_table(d)) + 1;
	    l_seq := (l_seq - l_coords(d)) / dim_size_table(d) + 1;
	    if d = p_rate_dim_sequence and l_coords(d) >= p_tier_sequence then
	       l_coords(d) := l_coords(d) + l_num_tiers;
	    end if;
	 end if;
      end loop;

      l_new_seq := 1;
      -- get new dimensions of rate tier
      for d in 1..l_dim_count loop
	 -- accomodate the expanded tier if creating rate tiers
	 if p_tier_sequence is not null and d = p_rate_dim_sequence then
	    l_new_seq := (l_new_seq - 1) *
	      (dim_size_table(d) + l_num_tiers) + l_coords(d);
	  else
	    l_new_seq := (l_new_seq - 1) * dim_size_table(d) + l_coords(d);
	 end if;
      end loop;

      -- update table
      update cn_rate_tiers set rate_sequence = l_new_seq
       where rate_tier_id = t.rate_tier_id;
   end loop;

   -- update cn_srp_rate_assigns.rate_sequence
   UPDATE cn_srp_rate_assigns sra
     SET rate_sequence = (SELECT rate_sequence
			  FROM cn_rate_tiers
			  WHERE rate_schedule_id = p_rate_schedule_id
			  AND rate_tier_id = sra.rate_tier_id)
     WHERE rate_schedule_id = p_rate_schedule_id;

END create_rate_tiers;

PROCEDURE delete_rate_tiers
  (p_rate_schedule_id                   CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dim_sequence                  CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   p_tier_sequence                      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE    := NULL,
   p_num_tiers                          NUMBER := 1) IS

   l_number_dim        CN_RATE_SCHEDULES.NUMBER_DIM%TYPE;
   l_coords            NUM_TBL_TYPE;
   l_seq               NUMBER;
   l_new_seq           NUMBER;
   l_dim_count         NUMBER := 0; -- number of dimensions in cn_rate_sch_dims for this rate table
   dim_size_table      num_tbl_type;
   l_num_tiers         number := nvl(p_num_tiers,1);
   delete_flag         boolean;

   CURSOR dims_info IS
      SELECT COUNT(*) number_tier
	FROM cn_rate_dim_tiers rdt,
	     cn_rate_sch_dims rsd
       WHERE rdt.rate_dimension_id = rsd.rate_dimension_id
	 AND rsd.rate_schedule_id = p_rate_schedule_id
       GROUP BY rsd.rate_dim_sequence
       ORDER BY rsd.rate_dim_sequence;

      CURSOR get_rate_tiers IS
      SELECT rate_tier_id, rate_sequence
	FROM cn_rate_tiers
       WHERE rate_schedule_id = p_rate_schedule_id;

BEGIN
   SELECT number_dim
     INTO l_number_dim
     FROM cn_rate_schedules
    WHERE rate_schedule_id = p_rate_schedule_id;

   -- build dimension size table
   FOR dim IN dims_info LOOP
      l_dim_count := l_dim_count + 1;
      dim_size_table(l_dim_count) := dim.number_tier;
   END LOOP;

   -- each dimension must have at least one tier. otherwise, raise an exception
   FOR j IN 1..l_dim_count LOOP
      IF (dim_size_table(j) = 0) THEN
	 fnd_message.set_name('CN', 'CN_EMPTY_DIMENSION');
	 RAISE fnd_api.g_exc_error;
      END IF;
   END LOOP;

   -- note all arrays are 1-indexed
   for t in get_rate_tiers loop
      -- get coordinates of t
      l_seq := t.rate_sequence;

      -- see if the tier needs to be deleted
      delete_flag := false;
      for d in reverse 1..l_dim_count loop
	 -- get old coordinates of rate tier
	 if p_tier_sequence is null then
	    l_coords(d) := mod(l_seq-1, dim_size_table(d)) + 1;
	    if d = p_rate_dim_sequence and l_coords(d) > 1 then
	       delete_flag := true;
	     else
	       l_seq := (l_seq - l_coords(d)) / dim_size_table(d) + 1;
	    end if;
	  else
	    l_coords(d) := mod(l_seq-1, dim_size_table(d)) + 1;
	    l_seq := (l_seq - l_coords(d)) / dim_size_table(d) + 1;
	    if d = p_rate_dim_sequence then
	       if l_coords(d) between
		 p_tier_sequence and p_tier_sequence + l_num_tiers - 1 then
		  delete_flag := true;
		elsif l_coords(d) >= p_tier_sequence + l_num_tiers then
		  l_coords(d) := l_coords(d) - l_num_tiers;
	       end if;
	    end if;
	 end if;
      end loop;

      if delete_flag = true then
	 delete from cn_rate_tiers
	   where rate_tier_id = t.rate_tier_id;
	 delete from cn_srp_rate_assigns
	   where rate_tier_id = t.rate_tier_id;
      else
	 l_new_seq := 1;
	 -- get new dimensions of rate tier
	 for d in 1..l_dim_count loop
	    -- accomodate the smaller tier if deleting rate tiers
	    if p_tier_sequence is not null and d = p_rate_dim_sequence then
	       l_new_seq := (l_new_seq - 1) *
		 (dim_size_table(d) - l_num_tiers) + l_coords(d);
	     elsif p_tier_sequence is not null or d <> p_rate_dim_sequence then
	       l_new_seq := (l_new_seq - 1) * dim_size_table(d) + l_coords(d);
	    end if;
	 end loop;

	 -- update table
	 update cn_rate_tiers set rate_sequence = l_new_seq
	  where rate_tier_id = t.rate_tier_id;
      end if;
   end loop;

   -- update cn_srp_rate_assigns.rate_sequence
   UPDATE cn_srp_rate_assigns sra
     SET rate_sequence = (SELECT rate_sequence
			    FROM cn_rate_tiers
			   WHERE rate_schedule_id = p_rate_schedule_id
			     AND rate_tier_id = sra.rate_tier_id)
     WHERE rate_schedule_id = p_rate_schedule_id;

END delete_rate_tiers;

PROCEDURE update_rate
  (p_rate_schedule_id           IN      CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_sequence              IN      CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   --R12 MOAC Changes--Start
   p_object_version_number      IN OUT NOCOPY CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE, --changed
   p_org_id                             CN_RATE_TIERS.ORG_ID%TYPE --new
   --R12 MOAC Changes--End
   ) IS


   x_return_status                    VARCHAR2(2000);
   x_msg_count                        NUMBER;
   x_msg_data                         VARCHAR2(2000);
   l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Rate';

      l_rate_tier_id             CN_RATE_TIERS.RATE_TIER_ID%TYPE;
      l_commission_amount        CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE;

     CURSOR rate_tier_info IS
	SELECT rate_tier_id, commission_amount
	  FROM cn_rate_tiers
	 WHERE rate_schedule_id = p_rate_schedule_id
	   AND rate_sequence = p_rate_sequence;

     CURSOR get_sqa IS
	select sqa.srp_plan_assign_id,
	       sqa.srp_quota_assign_id,
	       sqa.quota_id,
  	       rqa.rt_quota_asgn_id,
	       nvl(sqa.customized_flag, 'N') customized
	  from cn_srp_quota_assigns sqa, cn_rt_quota_asgns rqa
	 where rqa.rate_schedule_id = p_rate_schedule_id
       and sqa.quota_id = rqa.quota_id;

BEGIN

   SAVEPOINT   Update_rate;
    FND_MSG_PUB.initialize;

   OPEN rate_tier_info;
   FETCH rate_tier_info INTO l_rate_tier_id, l_commission_amount;
   IF (rate_tier_info%notfound) THEN
      -- record may have to be created
      CLOSE rate_tier_info;
      if p_commission_amount <> 0 then
	 cn_rate_tiers_pkg.insert_row
	   (X_RATE_TIER_ID          => l_rate_tier_id,
	    X_RATE_SCHEDULE_ID      => p_rate_schedule_id,
	    X_COMMISSION_AMOUNT     => p_commission_amount,
	    X_RATE_SEQUENCE         => p_rate_sequence,
          --R12 MOAC Changes--Start
          X_ORG_ID                => p_org_id);
          --R12 MOAC Changes--End

    --Fix for Bug 9401416
    create_note_bus_event (0,
                       0 ,
                       p_rate_sequence  ,
                       0,
                       p_commission_amount,
                       null ,
                       p_rate_schedule_id );

	 -- don't need to create sra...if customized, leave as 0 (don't create)
	 -- if non-customized, don't create (bug 3204833)
      end if;
    ELSE
      CLOSE rate_tier_info;

      -- see if amt changed
      if p_commission_amount <> l_commission_amount then

	 -- lock and update the record
	 cn_rate_tiers_pkg.lock_row
	   (X_RATE_TIER_ID           => l_rate_tier_id,
	    X_OBJECT_VERSION_NUMBER  => p_object_version_number);

	 cn_rate_tiers_pkg.update_row
	   (X_RATE_TIER_ID           => l_rate_tier_id,
	    X_RATE_SCHEDULE_ID       => p_rate_schedule_id,
	    X_COMMISSION_AMOUNT      => p_commission_amount,
	    X_RATE_SEQUENCE          => p_rate_sequence,
	    X_OBJECT_VERSION_NUMBER  => p_object_version_number);

      create_note_bus_event (0,
                          0 ,
                          p_rate_sequence  ,
                          l_commission_amount,
                          p_commission_amount,
                          null ,
                          p_rate_schedule_id );

	 -- sync up srp rate assignments where srps don't have customized rates
	 update cn_srp_rate_assigns r
	    set commission_amount = p_commission_amount
	  where rate_schedule_id  = p_rate_schedule_id
	    and rate_sequence     = p_rate_sequence
	    and exists
	   (select 1 from cn_srp_quota_assigns r2
	     where r.srp_quota_assign_id = r2.srp_quota_assign_id
               and nvl(r2.customized_flag, 'N') = 'N');
      end if;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_rate;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_rate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_rate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

END update_rate;

PROCEDURE update_srp_rate
  (p_srp_quota_assign_id        IN      CN_SRP_QUOTA_ASSIGNS.SRP_QUOTA_ASSIGN_ID%TYPE,
   p_rt_quota_asgn_id           IN      CN_SRP_RATE_ASSIGNS.RT_QUOTA_ASGN_ID%TYPE,
   p_rate_sequence              IN      CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   p_object_version_number      IN OUT NOCOPY CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE, -- changed
   --R12 MOAC Changes--Start
   p_org_id                             CN_RATE_TIERS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_loading_status     OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2

   ) IS

     l_srp_rate_assign_id    CN_SRP_RATE_ASSIGNS.SRP_RATE_ASSIGN_ID%TYPE;
     l_object_version_number CN_SRP_RATE_ASSIGNS.OBJECT_VERSION_NUMBER%TYPE;
     l_rate_schedule_id      CN_SRP_RATE_ASSIGNS.RATE_SCHEDULE_ID%TYPE;
     l_rate_tier_id          CN_SRP_RATE_ASSIGNS.RATE_TIER_ID%TYPE;
     l_commission_amount     CN_SRP_RATE_ASSIGNS.COMMISSION_AMOUNT%TYPE;
     l_srp_plan_assign_id    CN_SRP_RATE_ASSIGNS.SRP_PLAN_ASSIGN_ID%TYPE;
     l_quota_id              CN_SRP_RATE_ASSIGNS.QUOTA_ID%TYPE;
     l_api_name                 CONSTANT VARCHAR2(30) := 'update_srp_rate';

     CURSOR rate_tier_info IS
	SELECT srp_rate_assign_id, object_version_number, commission_amount
	  FROM cn_srp_rate_assigns
	 WHERE srp_quota_assign_id = p_srp_quota_assign_id
	   AND rt_quota_asgn_id = p_rt_quota_asgn_id
	   AND rate_sequence = p_rate_sequence
	   FOR UPDATE OF srp_rate_assign_id nowait;

     CURSOR get_rate_tier_id IS
	SELECT rate_tier_id
	  from cn_rate_tiers
	 where rate_schedule_id = l_rate_schedule_id
	   and rate_sequence    = p_rate_sequence;

     CURSOR get_sqa_info IS
	SELECT srp_plan_assign_id, quota_id
	  from CN_SRP_QUOTA_ASSIGNS
	 where srp_quota_assign_id = p_srp_quota_assign_id;

BEGIN
   -- this should only be called if rates are customized
   SAVEPOINT   update_srp_rate;
   FND_MSG_PUB.initialize;

   x_return_status := fnd_api.g_ret_sts_success;
   x_loading_status := 'CN_INSERTED';

   OPEN rate_tier_info;
   FETCH rate_tier_info INTO l_srp_rate_assign_id, l_object_version_number, l_commission_amount;
   IF (rate_tier_info%notfound) THEN
      close rate_tier_info;

      -- if updating to 0 then nothing to do
      if p_commission_amount = 0 then
	 return;
      end if;

      -- get rate schedule
      select rqa.rate_schedule_id into l_rate_schedule_id
	from cn_srp_quota_assigns sqa, cn_rt_quota_asgns rqa
       where rqa.rt_quota_asgn_id = p_rt_quota_asgn_id
	 and sqa.quota_id = rqa.quota_id
	 and sqa.srp_quota_assign_id = p_srp_quota_assign_id;

      -- see if rate tier already exists in main rate table
      OPEN  get_rate_tier_id;
      FETCH get_rate_tier_id into l_rate_tier_id;
      CLOSE get_rate_tier_id;
      if l_rate_tier_id is null then
	 -- insert rate tier into main rate table
	 cn_rate_tiers_pkg.insert_row
	   (X_RATE_TIER_ID          => l_rate_tier_id,
	    X_RATE_SCHEDULE_ID      => l_rate_schedule_id,
	    X_COMMISSION_AMOUNT     => 0,  -- place holder record
	    X_RATE_SEQUENCE         => p_rate_sequence,
          --R12 MOAC Changes--Start
          X_ORG_ID                => p_org_id);
          --R12 MOAC Changes--End
      end if;

      -- get srp_quota_assigns info
      OPEN  get_sqa_info;
      FETCH get_sqa_info into l_srp_plan_assign_id, l_quota_id;
      CLOSE get_sqa_info;

      -- we are assigning the rate for first time
      select cn_srp_rate_assigns_s.NEXTVAL into l_srp_rate_assign_id from dual;

      insert into cn_srp_rate_assigns
	(srp_plan_assign_id,
	 srp_quota_assign_id,
	 srp_rate_assign_id,
	 quota_id,
	 rate_schedule_id,
	 rt_quota_asgn_id,
	 rate_tier_id,
	 rate_sequence,
	 commission_amount,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 creation_date,
	 created_by,
	 org_id)
	values
	(l_srp_plan_assign_id,
	 p_srp_quota_assign_id,
	 l_srp_rate_assign_id,
	 l_quota_id,
	 l_rate_schedule_id,
	 p_rt_quota_asgn_id,
	 l_rate_tier_id,
	 p_rate_sequence,
	 p_commission_amount,
	 sysdate,
	 fnd_global.user_id,
	 fnd_global.login_id,
	 sysdate,
	 fnd_global.user_id,
	 p_org_id);

      create_note_bus_event
	(p_srp_quota_assign_id => p_srp_quota_assign_id,
	 p_rt_quota_asgn_id    => p_rt_quota_asgn_id,
	 p_rate_sequence       => p_rate_sequence,
	 p_old_amt             => 0,
	 p_new_amt             => p_commission_amount,
	 p_key                 => 'c' || l_srp_rate_assign_id);

      p_object_version_number := 1;
    else
      -- srp rate tier exists - update it
      close rate_tier_info;

      if (l_object_version_number <> p_object_version_number) then
	    fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
	    fnd_msg_pub.add;
	    x_loading_status := 'CN_RECORD_CHANGED';
	    raise fnd_api.g_exc_error;
      end if;

      -- if updating rate to 0, delete commission rate
      if p_commission_amount = 0 then
	 delete from cn_srp_rate_assigns
	  where srp_rate_assign_id = l_srp_rate_assign_id;

	 create_note_bus_event
	   (p_srp_quota_assign_id => p_srp_quota_assign_id,
	    p_rt_quota_asgn_id    => p_rt_quota_asgn_id,
	    p_rate_sequence       => p_rate_sequence,
	    p_old_amt             => l_commission_amount,
	    p_new_amt             => p_commission_amount,
	    p_key                 => 'd' || l_srp_rate_assign_id);

	 p_object_version_number := -1;
       else
	 update cn_srp_rate_assigns set
	   COMMISSION_AMOUNT      = p_commission_amount,
	   last_update_date       = sysdate,
	   last_updated_by        = fnd_global.user_id,
	   last_update_login      = fnd_global.login_id,
	   object_version_number  = object_version_number + 1
	   WHERE srp_rate_assign_id = l_srp_rate_assign_id;

	 p_object_version_number := p_object_version_number + 1;

	 create_note_bus_event
	   (p_srp_quota_assign_id => p_srp_quota_assign_id,
	    p_rt_quota_asgn_id    => p_rt_quota_asgn_id,
	    p_rate_sequence       => p_rate_sequence,
	    p_old_amt             => l_commission_amount,
	    p_new_amt             => p_commission_amount,
	    p_key                 => 'u' || l_srp_rate_assign_id || '-' ||
	                             p_object_version_number);
      end if;
   end if;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_srp_rate;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_srp_rate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO update_srp_rate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

END update_srp_rate;

-- utility function to get the rate_tier_id when given the tier combination
PROCEDURE get_rate_tier_info
  (p_rate_schedule_id           IN      CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dim_tier_id_tbl       IN      NUM_TBL_TYPE                     ,
   x_rate_tier_id               OUT NOCOPY     CN_RATE_TIERS.RATE_TIER_ID%TYPE,
   x_rate_sequence              OUT NOCOPY     CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   x_commission_amount          OUT NOCOPY     CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   x_object_version_number      OUT NOCOPY     CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE) IS

     l_base              NUMBER := 1;
     l_tier_sequence     CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE;
     l_rate_dimension_id CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
     l_rate_dim_sequence CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE;
     l_number_tier       CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE;
     l_number_dim        CN_RATE_SCHEDULES.NUMBER_DIM%TYPE;

     dim_size_table      num_tbl_type;
     current_tier_table  num_tbl_type;

     CURSOR dim_info(p_rate_dimension_id NUMBER) IS
	SELECT rsd.rate_dim_sequence, rd.number_tier
	  FROM cn_rate_sch_dims rsd,
	       cn_rate_dimensions rd
	  WHERE rsd.rate_schedule_id = p_rate_schedule_id
	  AND rsd.rate_dimension_id = p_rate_dimension_id
	  AND rd.rate_dimension_id = p_rate_dimension_id;

     CURSOR tier_info(p_rate_dim_tier_id NUMBER) IS
	SELECT tier_sequence, rate_dimension_id
	  FROM cn_rate_dim_tiers
	  WHERE rate_dim_tier_id = p_rate_dim_tier_id;

     CURSOR get_tier IS
	SELECT rate_tier_id, nvl(commission_amount,0), object_version_number
	  FROM cn_rate_tiers
	 WHERE rate_schedule_id = p_rate_schedule_id
	   AND rate_sequence = x_rate_sequence;

BEGIN
   FOR i IN p_rate_dim_tier_id_tbl.first..p_rate_dim_tier_id_tbl.last LOOP
      OPEN tier_info(p_rate_dim_tier_id_tbl(i));
      FETCH tier_info INTO l_tier_sequence, l_rate_dimension_id;
      IF (tier_info%notfound) THEN
	 CLOSE tier_info;
	 RAISE no_data_found;
      END IF;
      CLOSE tier_info;

      OPEN dim_info(l_rate_dimension_id);
      FETCH dim_info INTO l_rate_dim_sequence, l_number_tier;
      IF (dim_info%notfound) THEN
	 CLOSE dim_info;
	 RAISE no_data_found;
      END IF;
      CLOSE dim_info;

      current_tier_table(l_rate_dim_sequence) := l_tier_sequence;
      dim_size_table(l_rate_dim_sequence) := l_number_tier;
   END LOOP;

   l_number_dim := dim_size_table.COUNT;
   x_rate_sequence := 0;
   FOR i IN REVERSE 1..l_number_dim LOOP
      IF (i = l_number_dim) THEN
	 x_rate_sequence := x_rate_sequence + current_tier_table(i);
       ELSE
	 x_rate_sequence := x_rate_sequence + (current_tier_table(i) - 1) * l_base;
      END IF;

      l_base := l_base * dim_size_table(i);
   END LOOP;

   x_rate_tier_id := null;
   x_commission_amount := 0;
   x_object_version_number := 0;
   open  get_tier;
   fetch get_tier into x_rate_tier_id, x_commission_amount, x_object_version_number;
   close get_tier;

END get_rate_tier_info;


procedure tokenizer ( iStart IN NUMBER,
    sPattern in VARCHAR2,
    sBuffer in VARCHAR2,
    sResult OUT NOCOPY VARCHAR2,
    iNextPos OUT NOCOPY NUMBER)
    AS
    nPos1 number;
    nPos2 number;
    BEGIN
    nPos1 := Instr (sBuffer ,sPattern ,iStart);
    IF nPos1 = 0 then
    sResult := NULL ;
    ELSE
    nPos2 := Instr (sBuffer ,sPattern ,nPos1 + 1);
    IF nPos2 = 0 then
    sResult := Rtrim(Ltrim(Substr(sBuffer ,nPos1+1)));
    iNextPos := nPos2;
    else
    sResult := Substr(sBuffer ,nPos1 + 1 , nPos2 - nPos1 - 1);
    iNextPos := nPos2;
    END IF;
    END IF;
    END tokenizer ;


Function get_sequence(x_schedule_id
		      CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,sbuf varchar2) RETURN number
  is
     sepr varchar2(1);
     sres varchar2(200);
     pos number;
     istart number;

     x_rate_tier_id                   CN_RATE_TIERS.RATE_TIER_ID%TYPE;
     x_rate_sequence                  CN_RATE_TIERS.RATE_SEQUENCE%TYPE;
     x_commission_amount              CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE;
     x_object_version_number          CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE;
     l_number_dim                     NUMBER;

     --type tbl is table of number INDEX BY BINARY_INTEGER;
     l_tbl APPS.CN_MULTI_RATE_SCHEDULES_PVT.NUM_TBL_TYPE;

     begin
	-- if rate schedule is 1-dimensional, then don't need to do lot of fancy parsing
	select number_dim into l_number_dim from cn_rate_schedules
	 where rate_schedule_id = x_schedule_id;

	if l_number_dim = 1 then
	   -- strip off extra commas
	   sres := replace(sbuf, ',');
	   select rdt.tier_sequence into x_rate_sequence
	     from cn_rate_sch_dims rsd, cn_rate_dim_tiers rdt
	     where rsd.rate_schedule_id = x_schedule_id
	     and rsd.rate_dimension_id = rdt.rate_dimension_id
	     and rdt.rate_dim_tier_id = sres;
	   return x_rate_sequence;
	end if;

	--sbuf := ',10665,10667,10668';
	sepr := ',';
	istart := 1;
	tokenizer (istart ,sepr,sbuf,sres,pos);
	if (pos <> 0) then
	   l_tbl(l_tbl.count+1) := sres;
	   --   dbms_output.put_line (l_tbl(l_tbl.count));
	end if;
	while (pos <> 0)
	  loop
	     istart := pos;
	     tokenizer (istart ,sepr,sbuf,sres,pos );
	     --insert into l_tbl((sres));
	     l_tbl(l_tbl.count+1) := sres;
	     --   dbms_output.put_line (l_tbl(l_tbl.count));
	  end loop;

	  get_rate_tier_info(x_schedule_id,l_tbl,x_rate_tier_id,x_rate_sequence,x_commission_amount,x_object_version_number
			     );
	  return x_rate_sequence;
END get_sequence;

PROCEDURE  update_comm_rate(p_rate_schedule_id   IN  CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
                            x_result_tbl  IN  comm_tbl_type,
                            --R12 MOAC Changes--Start
                            p_org_id      IN  CN_RATE_TIERS.ORG_ID%TYPE --new
                            --R12 MOAC Changes--End
                            )
IS
x_ovn number;

BEGIN

FOR Lcntr IN  x_result_tbl.first..x_result_tbl.last
LOOP
 x_ovn := x_result_tbl(Lcntr).p_object_version_number;
 update_rate(p_rate_schedule_id ,x_result_tbl(Lcntr).p_rate_sequence,x_result_tbl(Lcntr).p_commission_amount,x_ovn,
             --R12 MOAC Changes--Start
             p_org_id);
             --R12 MOAC Changes--End
END LOOP;

END;


PROCEDURE duplicate_rate_Schedule
 (p_api_version                IN      NUMBER                          ,
  p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_name                       IN  OUT  NOCOPY  CN_RATE_SCHEDULES.NAME%TYPE ,
  p_org_id                     IN     CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
     --R12 MOAC Changes--End
  p_rate_schedule_id           IN  OUT  NOCOPY CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE, --changed
  p_number_dim                 IN      CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,
  p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
  x_return_status              OUT NOCOPY     VARCHAR2,
  x_msg_count                  OUT NOCOPY     NUMBER,
  x_msg_data                   OUT NOCOPY     VARCHAR2

  )
 IS

CURSOR rate_sch_dim IS
select * from cn_rate_sch_dims_all
where rate_schedule_id   = p_rate_schedule_id
and  org_id             =  p_org_id;

cursor rate_dim_info(l_dim_id CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE)
is
select * from cn_rate_dimensions_all
where rate_dimension_id = l_dim_id
and org_id = p_org_id;


CURSOR rate_sch_tiers_info(l_rate_schedule_id CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE) IS
select * from cn_rate_tiers_all
where rate_schedule_id   = l_rate_schedule_id
and  org_id             =  p_org_id;



l_new_name  CN_RATE_SCHEDULES.NAME%TYPE;
l_tbl_type  dims_tbl_type;
--l_rate_sch_rec  rate_sch_dim%ROWTYPE;
l_rate_dim_info_rec rate_dim_info%ROWTYPE;
l_rate_tier_rec   rate_sch_tiers_info%ROWTYPE ;
old_rate_schedule_id CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;



next_row NUMBER ;



begin




old_rate_schedule_id:=p_rate_schedule_id;
next_row:=1;


select name into p_name from cn_rate_schedules_all where rate_schedule_id   = p_rate_schedule_id
and  org_id             =  p_org_id;


l_new_name:=p_name;
CN_PLANCOPY_UTIL_PVT.get_unique_name_for_component(p_rate_schedule_id,
p_org_id,'RATETABLE',null,null,l_new_name,
x_return_status,x_msg_count,
x_msg_data);




--open rate_sch_dim;
for l_rate_sch_rec in rate_sch_dim


LOOP




l_tbl_type(next_row).rate_sch_dim_id := l_rate_sch_rec.rate_sch_dim_id;

l_tbl_type(next_row).rate_dimension_id := l_rate_sch_rec.rate_dimension_id;

l_tbl_type(next_row).rate_schedule_id := l_rate_sch_rec.rate_schedule_id;

l_tbl_type(next_row).rate_dim_sequence := l_rate_sch_rec.rate_dim_sequence;


open rate_dim_info(l_rate_sch_rec.rate_dimension_id);

fetch rate_dim_info into l_rate_dim_info_rec;

l_tbl_type(next_row).rate_dim_name := l_rate_dim_info_rec.name;

l_tbl_type(next_row).number_tier := l_rate_dim_info_rec.number_tier;

l_tbl_type(next_row).dim_unit_code := l_rate_dim_info_rec.dim_unit_code;

l_tbl_type(next_row).object_version_number := 1;


close rate_dim_info;

next_row:=next_row+1;




END LOOP;




p_rate_schedule_id := null;
Create_Schedule (

  p_api_version,
  p_init_msg_list ,
  p_commit ,
  p_validation_level ,
  l_new_name ,
  p_commission_unit_code  ,
  p_number_dim ,  -- not used
  l_tbl_type ,
  --R12 MOAC Changes--Start
  p_org_id  ,   --new
  p_rate_schedule_id , --changed
  x_return_status,
  x_msg_count,
  x_msg_data
  --R12 MOAC Changes--End
  );



p_name:= l_new_name;




for l_rate_tier in rate_sch_tiers_info(old_rate_schedule_id)
LOOP

update_rate(p_rate_schedule_id ,l_rate_tier.rate_sequence,l_rate_tier.commission_amount,l_rate_tier.object_version_number,
             --R12 MOAC Changes--Start
             p_org_id);

end loop;

commit;

END duplicate_rate_Schedule;



END CN_MULTI_RATE_SCHEDULES_PVT;

/
