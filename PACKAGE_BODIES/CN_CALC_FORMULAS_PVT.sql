--------------------------------------------------------
--  DDL for Package Body CN_CALC_FORMULAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_FORMULAS_PVT" AS
/*$Header: cnvformb.pls 120.17 2006/06/20 01:02:42 jxsingh noship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'CN_CALC_FORMULAS_PVT';
g_end_of_time      CONSTANT DATE         := to_date('12-31-9999','MM-DD-YYYY');

-- validate formula name and the flag combinations
PROCEDURE validate_name_flags
  (p_calc_formula_id            IN      CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE := NULL,
   p_name                       IN      CN_CALC_FORMULAS.NAME%TYPE,
   p_formula_type               IN      CN_CALC_FORMULAS.FORMULA_TYPE%TYPE,
   p_trx_group_code             IN      CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE,
   p_number_dim                 IN      CN_CALC_FORMULAS.NUMBER_DIM%TYPE,
   p_cumulative_flag            IN      CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE,
   p_itd_flag                   IN      CN_CALC_FORMULAS.ITD_FLAG%TYPE,
   p_split_flag                 IN      CN_CALC_FORMULAS.SPLIT_FLAG%TYPE,
   p_threshold_all_tier_flag    IN      CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE,
   p_perf_measure_id            IN      CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_CALC_FORMULAS.ORG_ID%TYPE
   --R12 MOAC Changes--End
) IS

     l_prompt                  cn_lookups.meaning%TYPE;
     l_dummy                   NUMBER;

     CURSOR formula_exists IS
	SELECT 1
	  FROM cn_calc_formulas
	  WHERE name = p_name
	    AND (p_calc_formula_id IS NULL OR p_calc_formula_id <> calc_formula_id)
          --R12 MOAC Changes--Start
          AND org_id = p_org_id;
          --R12 MOAC Changes--End

BEGIN
   IF (p_name IS NULL) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 l_prompt := cn_api.get_lkup_meaning('FORMULA_NAME', 'CN_PROMPTS');
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', l_prompt);
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   OPEN formula_exists;
   FETCH formula_exists INTO l_dummy;
   CLOSE formula_exists;

   IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_NAME_NOT_UNIQUE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- validate the combination of flags
   /****
   -- 1. make sure splitting across multiple inputs is not allowed
   IF (p_split_flag IN ('Y', 'P') AND p_number_dim > 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_SPLIT_ONE_INPUT');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- 2. make sure accumulation along multiple dimensions is not allowed
   IF (p_cumulative_flag = 'Y' AND p_number_dim > 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_CUMULATE_ONE_INPUT');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;
   ***/

   -- 3. make sure group by always goes with cumulative = 'Y' and itd_flag = 'N'
   IF (p_trx_group_code = 'GROUP' AND (p_cumulative_flag = 'N' OR p_itd_flag = 'Y')) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_GROUP_CONSTRAINT');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- 4. make sure itd_flag = 'Y' always goes with cumulative_flag = 'Y'
   IF (p_itd_flag = 'Y' AND p_cumulative_flag = 'N') THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_ITD_CUMULATIVE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- 5. make sure BONUS type formulas always have trx_group_code =
   -- 'INDIVIDUAL' amd cumulative_flag = 'N' and itd_flag = 'N'
   IF (p_formula_type = 'B' AND (p_trx_group_code = 'GROUP' OR
				 p_itd_flag = 'Y' OR p_cumulative_flag = 'Y')) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_BONUS_CONSTRAINT');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- 6. make sure THRESHOLD formulas have the following flag setting:
   --    trx_group_code = 'INDIVIDUAL' and cumulative_flag = 'Y',
   --    itd_flag = 'N' and split_flag = 'N'
   IF (p_threshold_all_tier_flag = 'Y' AND
       (p_trx_group_code = 'GROUP' or p_cumulative_flag = 'N' or
	p_split_flag = 'Y' OR p_formula_type = 'B')) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_THRESHOLD_CONSTRAINT');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   /*
   -- 7. make sure that perf_measure_id is not null ... not required anymore
   IF (p_perf_measure_id IS NULL) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_PERF_CANT_NULL');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;
     */

END validate_name_flags;

PROCEDURE check_planning_exp (p_calc_sql_exp_id IN CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE) IS
   CURSOR get_sql_select is
   select dbms_lob.substr(sql_select)
     from cn_calc_sql_exps
    where calc_sql_exp_id = p_calc_sql_exp_id;

   l_sql  varchar2(2000);
   l_pos  number := 1;
BEGIN
   IF p_calc_sql_exp_id IS NULL THEN
      RETURN;
   END IF;

   -- make sure only variables that exist in exps are:
   --     CH.TRANSACTION_AMOUNT
   --     CH.QUANTITY
   --     CSQA.TARGET
   --     CSQA.PAYMENT_AMOUNT.

   -- grab SQL select clause... look through each component.
   -- for each '.' (indicating variable), see if following character is not a number
   -- then make sure the '.' is included in one of the four legal variables.
   OPEN  get_sql_select;
   FETCH get_sql_select INTO l_sql;
   CLOSE get_sql_select;

   while (l_pos > 0) loop
      l_pos := instr(l_sql, '.', l_pos);
      if l_pos > 0 then
	 if (substr(l_sql, l_pos+1,  1) not between '0' and '9'    ) AND
	    (substr(l_sql, l_pos-2, 21) <> 'CH.TRANSACTION_AMOUNT' ) AND
	    (substr(l_sql, l_pos-2, 11) <> 'CH.QUANTITY'           ) AND
	    (substr(l_sql, l_pos-4, 11) <> 'CSQA.TARGET'           ) AND
	    (substr(l_sql, l_pos-4, 19) <> 'CSQA.PAYMENT_AMOUNT'   ) THEN
	    FND_MESSAGE.SET_NAME('CN', 'CN_ILLEGAL_EXP_COMPONENT');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;
	 l_pos := l_pos + 1;
      end if;
   end loop;
end check_planning_exp;

PROCEDURE check_modeling (p_calc_formula_id IN CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
			  p_cumulative_flag IN CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE,
			  p_output_exp_id   IN CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE,
			  p_f_output_exp_id IN CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE) IS
   cursor rt_asgns is
   select s.number_dim, d.dim_unit_code
     from cn_rt_formula_asgns a, cn_rate_schedules s,
          cn_rate_sch_dims r, cn_rate_dimensions d
    where a.rate_schedule_id  = s.rate_schedule_id
      and s.rate_schedule_id  = r.rate_schedule_id
      and r.rate_dimension_id = d.rate_dimension_id
      and a.calc_formula_id   = p_calc_formula_id;

   cursor inputs is
   select calc_sql_exp_id, f_calc_sql_exp_id
     from cn_formula_inputs where calc_formula_id = p_calc_formula_id;
BEGIN

   --  1. Formula should have only a single dimension rate table (no rate table is also allowed)
   --  2. The rate table can only have AMOUNT or PERCENT based tiers.
   --  3. The cumulative flag for the formula should be checked.
   --  4. Restricted set of variables that can appear in an input or output expression can be

   for r in rt_asgns loop
      IF r.dim_unit_code not in ('AMOUNT', 'PERCENT') OR
	 r.number_dim <> 1 THEN
	 -- condition 1 or 2 fails
	 FND_MESSAGE.SET_NAME('CN', 'CN_FORMULA_PLAN_RATE');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   end loop;

   IF p_cumulative_flag = 'N' THEN
      -- condition 3 fails
      FND_MESSAGE.SET_NAME('CN', 'CN_FORMULA_PLAN_CUM_FLAG');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

/*
   -- condition 4
   check_planning_exp (p_output_exp_id);
   check_planning_exp (p_f_output_exp_id);
   for e in inputs loop
      check_planning_exp (e.calc_sql_exp_id);
      check_planning_exp (e.f_calc_sql_exp_id);
   end loop;
*/
   -- if we made it through, then no error
END check_modeling;

--    Notes    : Create calculation formula and generate formula packages
PROCEDURE Create_Formula
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_generate_packages          IN      VARCHAR2 := FND_API.G_TRUE      ,
   p_name                       IN      CN_CALC_FORMULAS.NAME%TYPE,
   p_description                IN      CN_CALC_FORMULAS.DESCRIPTION%TYPE
                                        := null,
   p_formula_type               IN      CN_CALC_FORMULAS.FORMULA_TYPE%TYPE,
   p_trx_group_code             IN      CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE,
   p_number_dim                 IN      CN_CALC_FORMULAS.NUMBER_DIM%TYPE,
   p_cumulative_flag            IN      CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE,
   p_itd_flag                   IN      CN_CALC_FORMULAS.ITD_FLAG%TYPE,
   p_split_flag                 IN      CN_CALC_FORMULAS.SPLIT_FLAG%TYPE,
   p_threshold_all_tier_flag    IN      CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE,
   p_modeling_flag              IN      CN_CALC_FORMULAS.MODELING_FLAG%TYPE,
   p_perf_measure_id            IN      CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE,
   p_output_exp_id              IN      CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE,
   p_f_output_exp_id            IN      CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE
                                        := NULL,
   p_input_tbl                  IN      input_tbl_type     := g_miss_input_tbl,
   p_rt_assign_tbl              IN      rt_assign_tbl_type := g_miss_rt_assign_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_CALC_FORMULAS.ORG_ID%TYPE,   --new
   x_calc_formula_id            IN OUT NOCOPY     CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_formula_status             OUT NOCOPY     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Create_Formula';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_temp_id                 NUMBER;

     /* Start - R12 Notes History */
     l_formula_name             VARCHAR2(30);
     l_note_msg                 VARCHAR2(240);
     l_note_id                  NUMBER;
     l_output_exp_name          VARCHAR2(30);
     l_f_output_exp_name        VARCHAR2(30);
     l_perf_measure_name        VARCHAR2(30);
     l_consolidated_note    VARCHAR2(2000);
     /* End - R12 Notes History */
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Formula;
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
   validate_name_flags(NULL,
		       p_name,
		       p_formula_type,
		       p_trx_group_code,
		       p_number_dim,
		       p_cumulative_flag,
		       p_itd_flag,
		       p_split_flag,
		       p_threshold_all_tier_flag,
		       p_perf_measure_id,
                   --R12 MOAC Changes--Start
                   p_org_id
                   --R12 MOAC Changes--End
                   );

   -- call table handler to create the formula record in cn_calc_formulas
   cn_calc_formulas_pkg.insert_row
     (x_calc_formula_id         => x_calc_formula_id,
      x_name                    => p_name,
      x_description             => p_description,
      x_formula_type            => p_formula_type,
      x_trx_group_code          => p_trx_group_code,
      x_number_dim              => p_number_dim,
      x_cumulative_flag         => p_cumulative_flag,
      x_itd_flag                => p_itd_flag,
      x_split_flag              => p_split_flag,
      x_threshold_all_tier_flag => p_threshold_all_tier_flag,
      x_modeling_flag           => p_modeling_flag,
      x_perf_measure_id         => p_perf_measure_id,
      x_output_exp_id           => p_output_exp_id,
      x_f_output_exp_id         => p_f_output_exp_id,
      --R12 MOAC Changes--Start
      x_org_id                  => p_org_id
      --R12 MOAC Changes--End
      );

      /* Start - R12 Notes History */

      l_consolidated_note := '';

      select name into l_formula_name
      from   cn_calc_formulas
      where  calc_formula_id = x_calc_formula_id;

      fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_CREATE');
      fnd_message.set_token('FORMULA_NAME', l_formula_name);
      l_note_msg := fnd_message.get;

      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

       IF p_output_exp_id IS NOT NULL THEN
          select name INTO l_output_exp_name
          from   cn_calc_sql_exps
          where  calc_sql_exp_id = p_output_exp_id;

          fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPEXPR_CRE');
          fnd_message.set_token('EXPR', l_output_exp_name);
          l_note_msg := fnd_message.get;

          l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
          /*
          jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
          */
        END IF;

        IF p_f_output_exp_id IS NOT NULL THEN
          select name INTO l_f_output_exp_name
          from   cn_calc_sql_exps
          where  calc_sql_exp_id = p_f_output_exp_id;

          fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPFORE_CRE');
          fnd_message.set_token('EXPR', l_f_output_exp_name);
          l_note_msg := fnd_message.get;

          l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
          /*
          jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
           */
        END IF;

        -- Consolidated all Formula Details changes notes in one Note
        IF LENGTH(l_consolidated_note) > 1 THEN
          jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_consolidated_note,
                            p_notes_detail            => l_consolidated_note,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

        END IF;

        IF p_perf_measure_id IS NOT NULL THEN
          select name INTO l_perf_measure_name
          from   cn_calc_sql_exps
          where  calc_sql_exp_id = p_perf_measure_id;

          fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_PERF_CREATE');
          fnd_message.set_token('PERF_MEASURE', l_perf_measure_name);
          l_note_msg := fnd_message.get;

          jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        END IF;

       /* End - R12 Notes History */

   -- call table handler to create the input records in cn_formula_inputs
   IF (p_input_tbl.COUNT > 0) THEN
      FOR i IN p_input_tbl.first..p_input_tbl.last LOOP
	  l_temp_id := NULL;
	  cn_formula_inputs_pkg.insert_row
	   (x_formula_input_id    => l_temp_id,
	    x_calc_formula_id     => x_calc_formula_id,
	    x_calc_sql_exp_id     => p_input_tbl(i).calc_sql_exp_id,
	    x_f_calc_sql_exp_id   => p_input_tbl(i).f_calc_sql_exp_id,
	    x_rate_dim_sequence   => p_input_tbl(i).rate_dim_sequence,
          x_cumulative_flag     => p_input_tbl(i).cumulative_flag,
          x_split_flag          => p_input_tbl(i).split_flag,
          --R12 MOAC Changes--Start
          x_org_id              => p_org_id
          --R12 MOAC Changes--End
        );
      END LOOP;
   END IF;

   -- call table handler to create the rate table assignment records
   -- in cn_rt_formula_asgns
   IF (p_rt_assign_tbl.COUNT > 0) THEN
      FOR i IN p_rt_assign_tbl.first..p_rt_assign_tbl.last LOOP
	 -- make sure no date ranges overlap and start_date <= end_date
	 for j in p_rt_assign_tbl.first..i-1 loop
	    if greatest(p_rt_assign_tbl(i).start_date, p_rt_assign_tbl(j).start_date) <=
 	      least(nvl(p_rt_assign_tbl(i).end_date,g_end_of_time),
		    nvl(p_rt_assign_tbl(j).end_date,g_end_of_time)) then
	       FND_MESSAGE.SET_NAME('CN', 'CN_DATE_OVERLAP');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    end if;
	 end loop;

	 if p_rt_assign_tbl(i).start_date > nvl(p_rt_assign_tbl(i).end_date, g_end_of_time) then
	    FND_MESSAGE.SET_NAME('CN', 'ALL_INVALID_PERIOD_RANGE');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;

	 l_temp_id := NULL;
	 cn_rt_formula_asgns_pkg.insert_row
	   (x_rt_formula_asgn_id  => l_temp_id,
	    x_calc_formula_id     => x_calc_formula_id,
	    x_rate_schedule_id    => p_rt_assign_tbl(i).rate_schedule_id,
	    x_start_date          => p_rt_assign_tbl(i).start_date,
	    x_end_date            => p_rt_assign_tbl(i).end_date,
          --R12 MOAC Changes--Start
          x_org_id              => p_org_id
          --R12 MOAC Changes--End
         );
      END LOOP;
   END IF;

   -- easier to check modeling after the fact since data would already be in tables
   if p_modeling_flag = 'Y' then
      check_modeling(x_calc_formula_id, p_cumulative_flag, p_output_exp_id, p_f_output_exp_id);
   end if;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- this runs on its own separate commit cycle
   IF fnd_api.to_boolean(p_generate_packages) THEN
      generate_formula(p_api_version             => 1.0,
		       p_calc_formula_id         => x_calc_formula_id,
		       p_formula_type            => p_formula_type,
		       p_trx_group_code          => p_trx_group_code,
		       p_number_dim              => p_number_dim,
		       p_itd_flag                => p_itd_flag,
		       p_perf_measure_id         => p_perf_measure_id,
		       p_output_exp_id           => p_output_exp_id,
		       p_f_output_exp_id         => p_f_output_exp_id,
		       x_formula_status          => x_formula_status,
		       --R12 MOAC Changes--Start
               p_org_id                  => p_org_id,
               --R12 MOAC Changes--End
		       x_return_status           => x_return_status,
		       x_msg_count               => x_msg_count,
		       x_msg_data                => x_msg_data);
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Formula;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Formula;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Formula;
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
END Create_Formula;

--    Notes           : Update calculation formula and generate formula packages
PROCEDURE Update_Formula
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_generate_packages          IN      VARCHAR2 := FND_API.G_TRUE      ,
   p_calc_formula_id            IN      CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   p_name                       IN      CN_CALC_FORMULAS.NAME%TYPE,
   p_description                IN      CN_CALC_FORMULAS.DESCRIPTION%TYPE
                                        := null,
   p_formula_type               IN      CN_CALC_FORMULAS.FORMULA_TYPE%TYPE,
   p_formula_status             IN      CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   p_trx_group_code             IN      CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE,
   p_number_dim                 IN      CN_CALC_FORMULAS.NUMBER_DIM%TYPE,
   p_cumulative_flag            IN      CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE,
   p_itd_flag                   IN      CN_CALC_FORMULAS.ITD_FLAG%TYPE,
   p_split_flag                 IN      CN_CALC_FORMULAS.SPLIT_FLAG%TYPE,
   p_threshold_all_tier_flag    IN      CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE,
   p_modeling_flag              IN      CN_CALC_FORMULAS.MODELING_FLAG%TYPE,
   p_perf_measure_id            IN      CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE,
   p_output_exp_id              IN      CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE,
   p_f_output_exp_id            IN      CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE := NULL,
   p_input_tbl                  IN      input_tbl_type     := g_miss_input_tbl,
   p_rt_assign_tbl              IN      rt_assign_tbl_type := g_miss_rt_assign_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_CALC_FORMULAS.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY  CN_CALC_FORMULAS.OBJECT_VERSION_NUMBER%TYPE, --Changed
   --R12 MOAC Changes--End
   x_formula_status             OUT NOCOPY     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

  l_api_name                CONSTANT VARCHAR2(30) := 'Update_Formula';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_temp_id                 NUMBER;
  l_update_count            NUMBER := 0;
  l_srp_prd_quota_ext_id    cn_srp_period_quotas_ext.srp_period_quota_ext_id%TYPE;
  l_num_dim                 CN_CALC_FORMULAS.NUMBER_DIM%TYPE;
  l_count_formula_input     NUMBER := 0;
  l_plan_elt_tbl            CN_CALC_SQL_EXPS_PVT.NUM_TBL_TYPE;

  /* Start - R12 Notes History */
  l_formula_name            VARCHAR2(30);
  l_old_formula_name        VARCHAR2(30);
  l_meaning                 VARCHAR2(80);
  l_note_msg                VARCHAR2(240);
  l_note_id                 NUMBER;
  l_output_exp_name         VARCHAR2(30);
  l_f_output_exp_name       VARCHAR2(30);
  l_perf_measure_name       VARCHAR2(30);
  l_output_exp_name_old     VARCHAR2(30);
  l_f_output_exp_name_old   VARCHAR2(30);
  l_perf_measure_name_old   VARCHAR2(30);
  l_new_meaning             VARCHAR2(30);
  l_old_meaning             VARCHAR2(30);
  l_consolidated_note       VARCHAR2(2000);
  l_consolidated_exp_note   VARCHAR2(2000);
  /* End - R12 Notes History */

  CURSOR  get_old_formula_rec(l_calc_formula_id number) IS
  SELECT  cf.calc_formula_id, cf.NAME, cf.FORMULA_TYPE, cf.TRX_GROUP_CODE,
          cf.SPLIT_FLAG, cf.CUMULATIVE_FLAG, cf.ITD_FLAG, cf.MODELING_FLAG, cl.MEANING,
          cf.output_exp_id, cf.f_output_exp_id, cf.perf_measure_id, cs1.name oname,
          cs2.name fname, cs3.name pname
   FROM   cn_calc_formulas cf, cn_lookups cl,
          cn_calc_sql_exps cs1, cn_calc_sql_exps cs2, cn_calc_sql_exps cs3
   WHERE  cl.lookup_code = cf.FORMULA_TYPE
   AND    cl.lookup_type = 'FORMULA_TYPE'
   AND    cf.OUTPUT_EXP_ID   = cs1.CALC_SQL_EXP_ID (+)
   AND    cf.F_OUTPUT_EXP_ID = cs2.CALC_SQL_EXP_ID (+)
   AND    cf.PERF_MEASURE_ID = cs3.CALC_SQL_EXP_ID (+)
   AND    calc_formula_id = l_calc_formula_id;


   l_old_rec                 get_old_formula_rec%ROWTYPE;
   /* End - R12 Notes History */

  CURSOR c_next_srp_qut_id IS
   SELECT cn_srp_period_quotas_ext_s.NEXTVAL
   FROM dual;

   CURSOR c_srp_quota_detail IS
    select spq.srp_period_quota_id
    from cn_quotas_v qut, cn_srp_period_quotas spq
    where qut.quota_id = spq.quota_id
    and qut.calc_formula_id = p_calc_formula_id;

  CURSOR c1 IS
	SELECT
	  formula_type,
	  trx_group_code,
	  number_dim,
	  cumulative_flag,
	  itd_flag,
	  split_flag,
	  threshold_all_tier_flag,
	  modeling_flag,
	  perf_measure_id,
	  output_exp_id,
	  f_output_exp_id,
	  formula_status
	  FROM cn_calc_formulas
	  WHERE calc_formula_id = p_calc_formula_id;
  rec_info c1%ROWTYPE;

  cursor get_plans is
   select distinct qa.comp_plan_id from cn_quota_assigns qa, cn_quotas_v q
    where qa.quota_id       = q.quota_id
      and q.calc_formula_id = p_calc_formula_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Formula;
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

   -- validate name and flag combinations
   validate_name_flags(p_calc_formula_id,
		       p_name,
		       p_formula_type,
		       p_trx_group_code,
		       p_number_dim,
		       p_cumulative_flag,
		       p_itd_flag,
		       p_split_flag,
		       p_threshold_all_tier_flag,
		       p_perf_measure_id,
                   --R12 MOAC Changes--Start
                   p_org_id
                   --R12 MOAC Changes--End
                   );

   OPEN c1;
   FETCH c1 INTO rec_info;
   IF (c1%notfound) THEN
      CLOSE c1;
      RAISE no_data_found;
   END IF;
   CLOSE c1;

   l_num_dim := p_number_dim;
   x_formula_status := p_formula_status;
   IF (rec_info.formula_type            <> p_formula_type            OR
       rec_info.trx_group_code          <> p_trx_group_code          OR
       rec_info.number_dim              <> p_number_dim              OR
       rec_info.cumulative_flag         <> p_cumulative_flag         OR
       rec_info.itd_flag                <> p_itd_flag                OR
       rec_info.threshold_all_tier_flag <> p_threshold_all_tier_flag OR
       rec_info.modeling_flag           <> p_modeling_flag           OR
       rec_info.perf_measure_id         <> p_perf_measure_id         OR
       rec_info.output_exp_id           <> p_output_exp_id           OR
       rec_info.split_flag              <> p_split_flag              OR
       rec_info.f_output_exp_id         <> p_f_output_exp_id)
     THEN
      x_formula_status := 'INCOMPLETE';
   END IF;

   -- *********************************************************************
   -- ************ Start - This code is not required in R12 ***************
   -- *********************************************************************
   /*
   -- call table handler to insert/update/delete the input records in cn_formula_inputs
   IF (p_input_tbl.COUNT > 0) THEN
      x_formula_status := 'INCOMPLETE';
      FOR i IN p_input_tbl.first..p_input_tbl.last LOOP
	  IF (p_input_tbl(i).formula_input_id IS NULL) THEN
	    l_temp_id := NULL;
	    cn_formula_inputs_pkg.insert_row
	      (x_formula_input_id    => l_temp_id,
	       x_calc_formula_id     => p_calc_formula_id,
	       x_calc_sql_exp_id     => p_input_tbl(i).calc_sql_exp_id,
	       x_f_calc_sql_exp_id   => p_input_tbl(i).f_calc_sql_exp_id,
	       x_rate_dim_sequence   => p_input_tbl(i).rate_dim_sequence,
           x_cumulative_flag     => p_input_tbl(i).cumulative_flag,
           x_split_flag          => p_input_tbl(i).split_flag,
           --R12 MOAC Changes--Start
           x_org_id              => p_org_id
           --R12 MOAC Changes--End
           );

        l_update_count := l_update_count + 1;
	  ELSIF (p_input_tbl(i).calc_sql_exp_id IS NULL) THEN
	    cn_formula_inputs_pkg.delete_row(p_input_tbl(i).formula_input_id);
        l_num_dim := l_num_dim - 1;
	  ELSE
	    cn_formula_inputs_pkg.lock_row
         (x_formula_input_id      => p_input_tbl(i).formula_input_id,
	      x_object_version_number => p_input_tbl(i).object_version_number);

	    cn_formula_inputs_pkg.update_row
	      (x_formula_input_id      => p_input_tbl(i).formula_input_id,
	       x_calc_formula_id       => p_calc_formula_id,
	       x_calc_sql_exp_id       => p_input_tbl(i).calc_sql_exp_id,
	       x_f_calc_sql_exp_id     => p_input_tbl(i).f_calc_sql_exp_id,
	       x_rate_dim_sequence     => p_input_tbl(i).rate_dim_sequence,
             x_cumulative_flag       => p_input_tbl(i).cumulative_flag,
             x_split_flag            => p_input_tbl(i).split_flag,
	       x_object_version_number => p_input_tbl(i).object_version_number);

           l_update_count := l_update_count + 1;
      END IF;
    END LOOP;

    -- this is required to support accumulation along multiple dimensions
    -- for each rec in cn_srp_period_quotas, add p_input_tbl.COUNT - 1 rows into the ext table
    FOR form_rec IN c_srp_quota_detail LOOP
      delete from cn_srp_period_quotas_ext where srp_period_quota_id = form_rec.srp_period_quota_id;
      FOR i in 2.. l_update_count  LOOP
       OPEN c_next_srp_qut_id;
        FETCH c_next_srp_qut_id INTO l_srp_prd_quota_ext_id;
        IF (c_next_srp_qut_id%notfound) THEN
	     CLOSE c_next_srp_qut_id;
	     RAISE no_data_found;
        END IF;
       CLOSE c_next_srp_qut_id;

       insert into cn_srp_period_quotas_ext
       (srp_period_quota_ext_id,
        srp_period_quota_id,
        input_sequence,
        input_achieved_ptd,
        input_achieved_itd
       ) values
       (l_srp_prd_quota_ext_id,
        form_rec.srp_period_quota_id,
        i,
        null,
        null);
       END LOOP;
     END LOOP;
   END IF;
   */
   -- *********************************************************************
   -- ************ End - This code is not required in R12 *****************
   -- *********************************************************************

   /* Start - R12 Notes History */
   OPEN  get_old_formula_rec(p_calc_formula_id);
   FETCH get_old_formula_rec INTO l_old_rec;
   CLOSE get_old_formula_rec;
   /* End - R12 Notes History */

   -- call table handler to update the formula record in cn_calc_formulas
   cn_calc_formulas_pkg.lock_row
     (x_calc_formula_id         => p_calc_formula_id,
      x_object_version_number   => p_object_version_number);
   cn_calc_formulas_pkg.update_row
     (x_calc_formula_id         => p_calc_formula_id,
      x_name                    => p_name,
      x_description             => p_description,
      x_formula_status          => x_formula_status,
      x_formula_type            => p_formula_type,
      x_trx_group_code          => p_trx_group_code,
      x_number_dim              => l_num_dim,
      x_cumulative_flag         => p_cumulative_flag,
      x_itd_flag                => p_itd_flag,
      x_split_flag              => p_split_flag,
      x_threshold_all_tier_flag => p_threshold_all_tier_flag,
      x_modeling_flag           => p_modeling_flag,
      x_perf_measure_id         => p_perf_measure_id,
      x_output_exp_id           => p_output_exp_id,
      x_f_output_exp_id         => p_f_output_exp_id,
      x_object_version_number   => p_object_version_number);

     /* Start - R12 Notes History */

     l_consolidated_note := '';
     l_consolidated_exp_note := '';

     IF (l_old_rec.name <> p_name) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_NAME_CREATE');
        fnd_message.set_token('FORMULA_OLD', l_old_rec.name);
        fnd_message.set_token('FORMULA_NEW', p_name);
        l_note_msg := fnd_message.get;

        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
        /*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        */
     END IF;

     IF (l_old_rec.formula_type <> p_formula_type) THEN
        SELECT meaning into l_meaning
        FROM   cn_calc_formulas cf, cn_lookups cl
        WHERE  cl.lookup_code  = cf.FORMULA_TYPE
        AND    cl.lookup_type  = 'FORMULA_TYPE'
        AND    calc_formula_id = p_calc_formula_id;

        fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_TYPE_UPDATE');
        fnd_message.set_token('OLD_TYPE', l_old_rec.meaning);
        fnd_message.set_token('NEW_TYPE', l_meaning);
        l_note_msg := fnd_message.get;

        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
        /*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        */
     END IF;

     IF (l_old_rec.TRX_GROUP_CODE <> p_trx_group_code) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_FOR_PROTYPE_UPD');
        fnd_message.set_token('OLD_OPTION', l_old_rec.TRX_GROUP_CODE);
        fnd_message.set_token('NEW_OPTION', p_trx_group_code);
        l_note_msg := fnd_message.get;

        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
        /*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        */
     END IF;

     IF (l_old_rec.split_flag <> p_split_flag) THEN

        SELECT meaning  into l_new_meaning
        FROM   cn_lookups
        WHERE  lookup_type = 'SPLIT_FLAG'
        AND    lookup_code = p_split_flag;

        SELECT meaning  into l_old_meaning
        FROM   cn_lookups
        WHERE  lookup_type = 'SPLIT_FLAG'
        AND    lookup_code = l_old_rec.split_flag;

        fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_SPLIT_UPD');
        fnd_message.set_token('OLD_OPTION', l_old_meaning);
        fnd_message.set_token('NEW_OPTION', l_new_meaning);
        l_note_msg := fnd_message.get;

        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
        /*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        */
     END IF;

     IF (l_old_rec.cumulative_flag <> p_cumulative_flag) THEN
        IF (p_cumulative_flag = 'Y') THEN
          fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_ACC1_UPDATE');
        ELSE
          fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_ACC2_UPDATE');
        END IF;

        l_note_msg := fnd_message.get;

        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
        /*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        */
     END IF;

     IF (l_old_rec.itd_flag <> p_itd_flag) THEN
        IF (p_itd_flag = 'Y') THEN
          fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_ITD1_UPDATE');
        ELSE
          fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_ITD2_UPDATE');
        END IF;

        l_note_msg := fnd_message.get;

        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
        /*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        */
     END IF;

     IF (l_old_rec.modeling_flag <> p_modeling_flag) THEN
        IF (p_modeling_flag = 'Y') THEN
          fnd_message.set_name('CN', 'CNR12_NOTE_FOR_PLANFL1_UPD');
        ELSE
          fnd_message.set_name('CN', 'CNR12_NOTE_FOR_PLANFL2_UPD');
        END IF;

        l_note_msg := fnd_message.get;

        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
        /*
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        */
     END IF;
     -- Consolidated all Formula Details changes notes in one Note
     IF LENGTH(l_consolidated_note) > 1 THEN
         jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_consolidated_note,
                            p_notes_detail            => l_consolidated_note,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

     END IF;
     IF (((p_output_exp_id IS NOT NULL AND l_old_rec.output_exp_id IS NOT NULL) AND
          (l_old_rec.output_exp_id <> p_output_exp_id)) OR
          (p_output_exp_id IS NOT NULL AND l_old_rec.output_exp_id IS NULL))THEN

          select name INTO l_output_exp_name
          from   cn_calc_sql_exps
          where  calc_sql_exp_id = p_output_exp_id;

          IF l_old_rec.output_exp_id IS NOT NULL THEN
              l_output_exp_name_old := l_old_rec.oname;
              fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPEXPR_UPD');
              fnd_message.set_token('EXPR', l_output_exp_name_old);
              fnd_message.set_token('NEW_EXPR', l_output_exp_name);
              l_note_msg := fnd_message.get;
           ELSE
              fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPEXPR_CRE');
              fnd_message.set_token('EXPR', l_output_exp_name);
              l_note_msg := fnd_message.get;
           END IF;
           l_consolidated_exp_note := l_consolidated_exp_note || l_note_msg || fnd_global.local_chr(10);
           /*
           jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
           */
     END IF;

     IF (p_output_exp_id IS NULL AND l_old_rec.output_exp_id IS NOT NULL) THEN
            l_output_exp_name_old := l_old_rec.oname;
            fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPEXPR_DEL');
            fnd_message.set_token('EXPR', l_output_exp_name_old);
            l_note_msg := fnd_message.get;

            l_consolidated_exp_note := l_consolidated_exp_note || l_note_msg || fnd_global.local_chr(10);
            /*
            jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
            */
     END IF;

     IF (((p_f_output_exp_id IS NOT NULL AND l_old_rec.f_output_exp_id IS NOT NULL) AND
             (l_old_rec.f_output_exp_id <> p_f_output_exp_id)) OR
            (p_f_output_exp_id IS NOT NULL AND l_old_rec.f_output_exp_id IS NULL))THEN

           select name INTO l_f_output_exp_name
           from   cn_calc_sql_exps
           where  calc_sql_exp_id = p_f_output_exp_id;

           IF l_old_rec.f_output_exp_id IS NOT NULL THEN
              l_f_output_exp_name_old := l_old_rec.fname;
              fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPFORE_UPD');
              fnd_message.set_token('OLD_EXPR', l_f_output_exp_name_old);
              fnd_message.set_token('NEW_EXPR', l_f_output_exp_name);
              l_note_msg := fnd_message.get;

           ELSE
              fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPFORE_CRE');
              fnd_message.set_token('EXPR', l_f_output_exp_name);
              l_note_msg := fnd_message.get;
           END IF;

           l_consolidated_exp_note := l_consolidated_exp_note || l_note_msg || fnd_global.local_chr(10);
           /*
           jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
           */
         END IF;

         IF (p_f_output_exp_id IS NULL AND l_old_rec.f_output_exp_id IS NOT NULL) THEN
            l_f_output_exp_name_old := l_old_rec.fname;
            fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_OPFORE_DEL');
            fnd_message.set_token('EXPR_NAME', l_f_output_exp_name_old);
            l_note_msg := fnd_message.get;

            l_consolidated_exp_note := l_consolidated_exp_note || l_note_msg || fnd_global.local_chr(10);
            /*
            jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
            */
        END IF;

        -- Consolidated all Output Expressions in one Note.
        IF LENGTH(l_consolidated_exp_note) > 1 THEN
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_consolidated_exp_note,
                            p_notes_detail            => l_consolidated_exp_note,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

        END IF;

        IF (((p_perf_measure_id IS NOT NULL AND l_old_rec.perf_measure_id IS NOT NULL) AND
             (l_old_rec.perf_measure_id <> p_perf_measure_id)) OR
            (p_perf_measure_id IS NOT NULL AND l_old_rec.perf_measure_id IS NULL))THEN

           select name INTO l_perf_measure_name
           from   cn_calc_sql_exps
           where  calc_sql_exp_id = p_perf_measure_id;

           IF l_old_rec.perf_measure_id IS NOT NULL THEN
               l_perf_measure_name_old := l_old_rec.pname;
               fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_PERF_UPDATE');
               fnd_message.set_token('OLD_PERF_MEASURE', l_perf_measure_name_old);
               fnd_message.set_token('NEW_PERF_MEASURE', l_perf_measure_name);
               l_note_msg := fnd_message.get;
           ELSE
               fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_PERF_CREATE');
               fnd_message.set_token('PERF_MEASURE', l_perf_measure_name);
               l_note_msg := fnd_message.get;
           END IF;

          jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        END IF;
        IF (p_perf_measure_id IS NULL AND l_old_rec.perf_measure_id IS NOT NULL) THEN
            l_perf_measure_name_old := l_old_rec.pname;
            fnd_message.set_name('CN', 'CNR12_NOTE_FORMULA_PERF_DELETE');
            fnd_message.set_token('PERF_MEASURE', l_perf_measure_name_old);
            l_note_msg := fnd_message.get;

            jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_calc_formula_id,
                            p_source_object_code      => 'CN_CALC_FORMULAS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
        END IF;

    /* End - R12 Notes History */

   -- if th cumulative flag or the split flag has been set to "N", then set the corros flags in the input table to "N"
   IF p_cumulative_flag = 'N' THEN
      update cn_formula_inputs set cumulative_flag = 'N' where calc_formula_id = p_calc_formula_id;
   END IF;

   IF p_split_flag = 'N' THEN
      update cn_formula_inputs set split_flag = 'N' where calc_formula_id = p_calc_formula_id;
   END IF;

   -- IF the split is changed, the changes has to be reflected
   IF rec_info.split_flag <> p_split_flag THEN
      update cn_formula_inputs set split_flag = p_split_flag
	where calc_formula_id = p_calc_formula_id and split_flag <> 'N' ;

      -- changes for BUG#2797926
      IF (p_split_flag = 'Y') AND (p_split_flag IS NOT NULL )THEN
      -- check whether there is only one row in the
      -- formula inputs
      	 SELECT count(*)
      	 INTO l_count_formula_input
      	 FROM   cn_formula_inputs
      	 WHERE calc_formula_id = p_calc_formula_id ;

      	 -- if only one formula input is there
      	 -- update the split flag to 'Y'
      	 IF (l_count_formula_input = 1) THEN
      	    update cn_formula_inputs set split_flag = p_split_flag
	    where calc_formula_id = p_calc_formula_id ;
	 END IF;
       END IF;
   END IF;


   -- If the change made the formula invalid, change comp plans using
   -- this formula to incomplete
   if x_formula_status = 'INCOMPLETE' then
      for p in get_plans loop
	 -- invalidate plans using this formula
	 cn_comp_plans_pkg.set_status
	   ( x_comp_plan_id        => p.comp_plan_id
	    ,x_quota_id            => null
	    ,x_rate_schedule_id    => null
	    ,x_status_code         => 'INCOMPLETE'
	    ,x_event               => null);
      end loop;
   end if;

   -- *********************************************************************
   -- ************ Start - This code is not required in R12 ***************
   -- *********************************************************************
   /*
   -- call table handler to insert/update/delete the rate table assignment
   -- records in cn_rt_formula_asgns
   IF (p_rt_assign_tbl.COUNT > 0) THEN
      FOR i IN p_rt_assign_tbl.first..p_rt_assign_tbl.last LOOP
	 -- make sure no date ranges overlap and start_date <= end_date
	 for j in p_rt_assign_tbl.first..i-1 loop
	    if greatest(p_rt_assign_tbl(i).start_date, p_rt_assign_tbl(j).start_date) <=
 	      least(nvl(p_rt_assign_tbl(i).end_date,g_end_of_time),
		    nvl(p_rt_assign_tbl(j).end_date,g_end_of_time)) then
	       FND_MESSAGE.SET_NAME('CN', 'CN_DATE_OVERLAP');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    end if;
	 end loop;

	 if p_rt_assign_tbl(i).start_date > nvl(p_rt_assign_tbl(i).end_date, g_end_of_time) then
	    FND_MESSAGE.SET_NAME('CN', 'ALL_INVALID_PERIOD_RANGE');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;

	 IF (p_rt_assign_tbl(i).rt_formula_asgn_id IS NULL) then
	    l_temp_id := NULL;
	    cn_rt_formula_asgns_pkg.insert_row
	      (x_rt_formula_asgn_id  => l_temp_id,
	       x_calc_formula_id     => p_calc_formula_id,
	       x_rate_schedule_id    => p_rt_assign_tbl(i).rate_schedule_id,
	       x_start_date          => p_rt_assign_tbl(i).start_date,
	       x_end_date            => p_rt_assign_tbl(i).end_date,
             --R12 MOAC Changes--Start
             x_org_id              => p_org_id
             --R12 MOAC Changes--End
            );
	  ELSIF (p_rt_assign_tbl(i).rate_schedule_id IS NULL) THEN
	    cn_rt_formula_asgns_pkg.delete_row
	      (p_rt_assign_tbl(i).rt_formula_asgn_id);
	  ELSE
	    cn_rt_formula_asgns_pkg.lock_row
	      (x_rt_formula_asgn_id    => p_rt_assign_tbl(i).rt_formula_asgn_id,
	       x_object_version_number => p_rt_assign_tbl(i).object_version_number);

         cn_rt_formula_asgns_pkg.update_row
	      (x_rt_formula_asgn_id    => p_rt_assign_tbl(i).rt_formula_asgn_id,
	       x_calc_formula_id       => p_calc_formula_id,
	       x_rate_schedule_id      => p_rt_assign_tbl(i).rate_schedule_id,
	       x_start_date            => p_rt_assign_tbl(i).start_date,
	       x_end_date              => p_rt_assign_tbl(i).end_date,
	       x_object_version_number => p_rt_assign_tbl(i).object_version_number);
	 END IF;
    END LOOP;
   END IF;
   */
   -- *********************************************************************
   -- ************ End - This code is not required in R12 *****************
   -- *********************************************************************

   -- easier to check modeling after the fact since data would already be in tables
   if p_modeling_flag = 'Y' then
      check_modeling(p_calc_formula_id, p_cumulative_flag, p_output_exp_id, p_f_output_exp_id);
   end if;

   -- make sure this formula wouldn't be involved in a cycle
   cn_calc_sql_exps_pvt.get_dependent_plan_elts
     (p_api_version               => 1.0,
      p_node_type                 => 'F',
      p_node_id                   => p_calc_formula_id,
      x_plan_elt_id_tbl           => l_plan_elt_tbl,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- this runs on its own separate commit cycle
   IF fnd_api.to_boolean(p_generate_packages) THEN
      generate_formula(p_api_version             => 1.0,
		       p_calc_formula_id         => p_calc_formula_id,
		       p_formula_type            => p_formula_type,
		       p_trx_group_code          => p_trx_group_code,
		       p_number_dim              => l_num_dim,
		       p_itd_flag                => p_itd_flag,
		       p_perf_measure_id         => p_perf_measure_id,
		       p_output_exp_id           => p_output_exp_id,
		       p_f_output_exp_id         => p_f_output_exp_id,
		       x_formula_status          => x_formula_status,
		       --R12 MOAC Changes--Start
               p_org_id                  => p_org_id,
               --R12 MOAC Changes--End
		       x_return_status           => x_return_status,
		       x_msg_count               => x_msg_count,
		       x_msg_data                => x_msg_data);
   END IF;
   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Formula;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Formula;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Formula;
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
END Update_Formula;

--      Notes           : Delete a formula
PROCEDURE Delete_Formula
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                       IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level             IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL ,
   p_calc_formula_id              IN      CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   p_org_id                       IN      CN_CALC_FORMULAS.ORG_ID%TYPE,  --SFP related change
   --R12 MOAC Changes--Start
   p_object_version_number        IN      CN_CALC_FORMULAS.OBJECT_VERSION_NUMBER%TYPE, --new
   --R12 MOAC Changes--End
   x_return_status                OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                    OUT NOCOPY     NUMBER                          ,
   x_msg_data                     OUT NOCOPY     VARCHAR2                        ) IS

     l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Formula';
     l_api_version               CONSTANT NUMBER       := 1.0;
     l_dummy                     pls_integer;
   /* Start - R12 Notes History */
   l_formula_name  VARCHAR2(30);
   l_org_id        NUMBER := -999;
   l_note_msg                VARCHAR2(240);
   l_note_id                 NUMBER;
   /* End - R12 Notes History */

     CURSOR parent_exist IS
	SELECT 1
	  FROM dual
	  WHERE exists (SELECT 1 FROM cn_calc_edges
			WHERE child_id = p_calc_formula_id
			AND edge_type = 'FE');
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Formula;
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

   -- make sure:
   -- 1) the formula is not used in cn_calc_edges
   -- 2) the formula is not assigned to a plan element or role
   -- 3) the formula is not used in modeling

   OPEN  parent_exist;
   FETCH parent_exist INTO l_dummy;
   CLOSE parent_exist;

   IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_FORMULA_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   select count(1) into l_dummy
     from cn_quotas_v where calc_formula_id = p_calc_formula_id;
   if l_dummy > 0 THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_FORMULA_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   select count(1) into l_dummy
     from cn_calc_formulas f, cn_role_quota_cates r
    where f.calc_formula_id = p_calc_formula_id
      and f.calc_formula_id = r.calc_formula_id
      and f.modeling_flag = 'Y';
   if l_dummy > 0 THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_DEL_PLANNING_FORM');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   /* Start - R12 Notes History */
   --SELECT org_id, name INTO l_org_id, l_formula_name
   --FROM   cn_calc_formulas
   --WHERE  calc_formula_id = p_calc_formula_id;

   SELECT name INTO l_formula_name
   FROM   cn_calc_formulas
   WHERE  calc_formula_id = p_calc_formula_id
   AND    org_id          = p_org_id;

   /* End - R12 Notes History */

   cn_calc_formulas_pkg.delete_row(p_calc_formula_id, p_org_id);

   /* Start - R12 Notes History */
   IF (p_org_id <> -999) THEN
      fnd_message.set_name ('CN', 'CNR12_NOTE_FORMULA_DELETE');
      fnd_message.set_token ('FORMULA', l_formula_name);
      l_note_msg := fnd_message.get;
      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_org_id,
                            p_source_object_code      => 'CN_DELETED_OBJECTS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
   END IF;
  /* End - R12 Notes History */

   -- delete formula inputs and rate table assignments
   DELETE FROM cn_formula_inputs WHERE calc_formula_id = p_calc_formula_id AND org_id = p_org_id;
   DELETE FROM cn_rt_formula_asgns WHERE calc_formula_id = p_calc_formula_id AND org_id = p_org_id;

   -- delete formula packages and the records in cn_objects if they exist.

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
      ROLLBACK TO Delete_Formula;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Formula;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Formula;
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
END Delete_Formula;


--      Notes           : Generate the PL/SQL packages for the given formula
PROCEDURE generate_formula
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_calc_formula_id            IN      CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   p_formula_type               IN      CN_CALC_FORMULAS.FORMULA_TYPE%TYPE,
   p_trx_group_code             IN      CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE,
   p_number_dim                 IN      CN_CALC_FORMULAS.NUMBER_DIM%TYPE,
   p_itd_flag                   IN      CN_CALC_FORMULAS.ITD_FLAG%TYPE,
   p_perf_measure_id            IN      CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE,
   p_output_exp_id              IN      CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE,
   p_f_output_exp_id            IN      CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE,
   x_formula_status             OUT NOCOPY     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_CALC_FORMULAS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        ) IS

     l_api_name                CONSTANT VARCHAR2(30) := 'Generate_Formula';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_process_audit_id           NUMBER;
     l_input_count                pls_integer := 0;
     l_dummy                      pls_integer;
     l_ii_flag                    VARCHAR2(30) := 'N';
     l_status                     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE;
     l_f_status                   CN_CALC_FORMULAS.FORMULA_STATUS%TYPE;
     l_exp_type_code              CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE;
     l_f_exp_type_code            CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE;
     l_formula_type               CN_CALC_FORMULAS.FORMULA_TYPE%TYPE;
     l_trx_group_code             CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE;
     l_number_dim                 CN_CALC_FORMULAS.NUMBER_DIM%TYPE;
     l_itd_flag                   CN_CALC_FORMULAS.ITD_FLAG%TYPE;
     l_perf_measure_id            CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE;
     l_output_exp_id              CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE;
     l_f_output_exp_id            CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE;
     l_count_formula_input        NUMBER := 0;
     l_split_flag                 CN_CALC_FORMULAS.SPLIT_FLAG%TYPE;

     --clku
     l_name                       CN_CALC_FORMULAS.NAME%TYPE;


     CURSOR formula_info IS
	SELECT
	  formula_type,
	  trx_group_code,
	  number_dim,
	  itd_flag,
	  perf_measure_id,
	  output_exp_id,
	  f_output_exp_id
	  FROM cn_calc_formulas
	  WHERE calc_formula_id = p_calc_formula_id;

     CURSOR formula_split_info IS
	SELECT
	  split_flag
	  FROM cn_calc_formulas
	  WHERE calc_formula_id = p_calc_formula_id;


     CURSOR perf_measure IS
	SELECT status, exp_type_code
	  FROM cn_calc_sql_exps
	  WHERE calc_sql_exp_id = l_perf_measure_id;

     CURSOR inputs IS
	SELECT a.status, a.exp_type_code, b.status f_status,
	       b.exp_type_code f_exp_type_code
	  FROM cn_calc_sql_exps a,
               cn_calc_sql_exps b,
	       cn_formula_inputs c
	  WHERE a.calc_sql_exp_id = c.calc_sql_exp_id
	  AND b.calc_sql_exp_id(+) = c.f_calc_sql_exp_id
	  AND c.calc_formula_id = p_calc_formula_id;

     CURSOR output IS
	SELECT status, exp_type_code
	  FROM cn_calc_sql_exps
	  WHERE calc_sql_exp_id = l_output_exp_id;

     CURSOR f_output IS
	SELECT status, exp_type_code
	  FROM cn_calc_sql_exps
	  WHERE calc_sql_exp_id = l_f_output_exp_id;

     CURSOR check_dimensions IS
	SELECT 1
	  FROM cn_rate_schedules
	  WHERE number_dim <> l_number_dim
	  AND rate_schedule_id IN (SELECT rate_schedule_id
				     FROM cn_rt_formula_asgns
				     WHERE calc_formula_id = p_calc_formula_id);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Generate_Formula;
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

   -- get formula info if not provided by caller
   IF (p_formula_type = fnd_api.g_miss_char OR
       p_trx_group_code = fnd_api.g_miss_char OR
       p_number_dim = fnd_api.g_miss_num OR
       p_itd_flag = fnd_api.g_miss_char OR
       p_perf_measure_id = fnd_api.g_miss_num OR
       p_output_exp_id = fnd_api.g_miss_num OR
       p_f_output_exp_id = fnd_api.g_miss_num)
     THEN
      OPEN formula_info;
      FETCH formula_info INTO
	l_formula_type,
	l_trx_group_code,
	l_number_dim,
	l_itd_flag,
	l_perf_measure_id,
	l_output_exp_id,
	l_f_output_exp_id;
      CLOSE formula_info;
    ELSE
      l_formula_type := p_formula_type;
      l_trx_group_code := p_trx_group_code;
      l_number_dim := p_number_dim;
      l_itd_flag := p_itd_flag;
      l_perf_measure_id := p_perf_measure_id;
      l_output_exp_id := p_output_exp_id;
      l_f_output_exp_id := p_f_output_exp_id;
   END IF;

   if l_perf_measure_id is not null then
      -- if a perf measure is assigned then make sure that the
      -- perf_measure assigned matches this formula
      OPEN  perf_measure;
      FETCH perf_measure INTO l_status, l_exp_type_code;
      CLOSE perf_measure;

      IF (l_status <> 'VALID') THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_INVALID_PERF');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
       ELSE
	 IF (l_formula_type = 'C') THEN
	    IF (l_exp_type_code NOT IN ('IIIOIPGP', 'IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT')) THEN
	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		  fnd_message.set_name('CN', 'CN_UNMATCHED_PERF');
		  fnd_msg_pub.ADD;
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	  ELSIF (l_formula_type = 'B') THEN
	    IF (l_exp_type_code NOT IN ('IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT', 'IIIOIPGOGPBIBOBP')) THEN
	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		  fnd_message.set_name('CN', 'CN_UNMATCHED_PERF');
		  fnd_msg_pub.ADD;
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;
      END IF;
   END IF;

   -- check and make sure that the output expression matches this formula
   l_status := NULL;
   l_exp_type_code := NULL;
   OPEN output;
   FETCH output INTO l_status, l_exp_type_code;
   CLOSE output;

   OPEN f_output;
   FETCH f_output INTO l_f_status, l_f_exp_type_code;
   CLOSE f_output;

   IF (l_status <> 'VALID' OR
       l_exp_type_code IS NULL OR
       (l_f_output_exp_id IS NOT NULL AND (l_f_status <> 'VALID' OR l_f_exp_type_code IS NULL))) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_INVALID_OUTPUT');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF (l_formula_type = 'C' AND l_trx_group_code = 'INDIVIDUAL' AND l_itd_flag = 'Y') THEN
	 IF (l_exp_type_code NOT IN ('IO', 'IIIO', 'IOGOBOFO', 'IIIOIPGP', 'IOGOBO', 'IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT', 'IIIOIPGOGPBIBOBP')) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_UNMATCHED_OUTPUT');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;
       ELSIF (l_formula_type = 'C' AND l_trx_group_code = 'INDIVIDUAL' AND l_itd_flag = 'N') THEN
	 IF (l_exp_type_code NOT IN ('IO', 'IO_ITDN', 'IIIO', 'IIIOIPGP', 'IOGOBOFO', 'IOGOBO', 'IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT', 'IIIOIPGOGPBIBOBP')) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_UNMATCHED_OUTPUT');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;
       ELSIF (l_formula_type = 'C' AND l_trx_group_code = 'GROUP') THEN
	 IF (l_exp_type_code NOT IN ('GO', 'GIGO', 'IOGOBOFO', 'IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT', 'IOGOBO', 'IIIOIPGOGPBIBOBP')) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_UNMATCHED_OUTPUT');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;
       ELSIF (l_formula_type = 'B') THEN
	 IF (l_exp_type_code NOT IN ('IOGOBOFO', 'IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT', 'IOGOBO', 'IIIOIPGOGPBIBOBP')) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_UNMATCHED_OUTPUT');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;
   END IF;

   -- check and make sure that number_dim is correct and input expressions match this formula
   FOR input IN inputs LOOP
      IF (input.status <> 'VALID' OR input.exp_type_code IS NULL) THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_INVALID_INPUT');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
       ELSE
	 IF (l_formula_type = 'C' AND l_trx_group_code = 'INDIVIDUAL') THEN
	    IF (input.exp_type_code NOT IN ('IIIOIPGP', 'IIIO', 'IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT', 'IIIOIPGOGPBIBOBP')) THEN
	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		  fnd_message.set_name('CN', 'CN_UNMATCHED_INPUT');
		  fnd_msg_pub.ADD;
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    IF (input.exp_type_code IN ('IIIOIPGP', 'IIIO', 'IIIOIPGOGPBIBOBP')) THEN
	       l_ii_flag := 'Y';
	    END IF;
	  ELSIF (l_formula_type = 'C' AND l_trx_group_code = 'GROUP') THEN
	    IF (input.exp_type_code <> 'GIGO') THEN
	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		  fnd_message.set_name('CN', 'CN_UNMATCHED_INPUT');
		  fnd_msg_pub.ADD;
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    l_ii_flag := 'Y';
	  ELSIF (l_formula_type = 'B') THEN
	    IF (input.exp_type_code NOT IN ('IRIOIPGOGPBIBOBPFRFO', 'IRIOIPGOGPBIBOBPFRFODDT', 'IIIOIPGOGPBIBOBP')) THEN
	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		  fnd_message.set_name('CN', 'CN_UNMATCHED_INPUT');
		  fnd_msg_pub.ADD;
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    l_ii_flag := 'Y';
	 END IF;
      END IF;

      l_input_count := l_input_count + 1;
   END LOOP;

   -- Commission type formulas with trx_group_code = 'INDIVIDUAL' must have at
   -- least one column from cn_commission_lines/headers
   -- in one of its input definition
   IF (l_ii_flag <> 'Y') THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_NO_LINE_HEADER');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

  -- changes for BUG#2797926
   OPEN formula_split_info;
   FETCH formula_split_info INTO l_split_flag;
   CLOSE formula_split_info;
   IF (l_split_flag = 'Y') THEN

         SELECT count(*)
         INTO l_count_formula_input
         FROM   cn_formula_inputs
      	 WHERE calc_formula_id = p_calc_formula_id
      	 AND split_flag = 'Y';

         IF l_count_formula_input = 0 THEN
	      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		 fnd_message.set_name('CN', 'CN_NO_SPLIT_INPUT_EXP');
		 fnd_msg_pub.ADD;
	      END IF;
	      RAISE fnd_api.g_exc_error;
         END IF;
   END IF;

   IF (l_input_count <> l_number_dim) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_WRONG_NUMBER_DIM');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- check and make sure that the number of inputs matches the number of
   -- dimensions in the assigned rate tables.
   OPEN check_dimensions;
   FETCH check_dimensions INTO l_dummy;
   CLOSE check_dimensions;
   IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_RT_NOT_MATCH');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   cn_formula_gen_pkg.generate_formula
     (p_api_version       => 1.0,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_formula_id        => p_calc_formula_id,
      --R12 MOAC Changes--Start
      p_org_id            => p_org_id,
      --R12 MOAC Changes--End
      x_process_audit_id  => l_process_audit_id);

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      x_formula_status := 'COMPLETE';

      -- clku, bug 2805095, call mark event here instead of call in table trigger
        select name into
        l_name
        from cn_calc_formulas
        where calc_formula_id = p_calc_formula_id;

        cn_mark_events_pkg.mark_event_formula
                 (p_event_name       => 'CHANGE_FORMULA',
				  p_object_name      => l_name,
				  p_object_id        => p_calc_formula_id,
				  p_start_date       => NULL,
				  p_start_date_old   => NULL,
				  p_end_date         => NULL,
				  p_end_date_old     => NULL,
				  --R12 MOAC Changes--Start
                  p_org_id           => p_org_id
                  --R12 MOAC Changes--End
				  );

    ELSE
      x_formula_status := 'INCOMPLETE';
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
      ROLLBACK TO Generate_Formula;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Generate_Formula;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Generate_Formula;
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
END generate_formula;

END CN_CALC_FORMULAS_PVT;

/
