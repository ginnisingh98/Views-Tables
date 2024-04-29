--------------------------------------------------------
--  DDL for Package Body PSB_POSITIONS_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITIONS_I_PVT" AS
/* $Header: PSBWPOIB.pls 120.7.12010000.3 2009/03/03 08:49:21 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_POSITIONS_I_PVT';
  G_DBUG              VARCHAR2(2000) := 'start';

PROCEDURE Initialize_View ( p_worksheet_id IN NUMBER,
			    p_start_date   IN DATE,
			    p_end_date     IN DATE,
			    p_select_date   IN DATE := fnd_api.g_miss_date
			  ) IS


BEGIN

     PSB_POSITIONS_PVT.Initialize_View(
			       p_worksheet_id     => p_worksheet_id,
			       p_start_date       => p_start_date,
			       p_end_date         => p_end_date,
			       p_select_date      => p_select_date
			       );


END Initialize_View ;

PROCEDURE Define_Worksheet_Values (
	    p_api_version              in number,
	    p_init_msg_list            in varchar2 := fnd_api.g_false,
	    p_commit                   in varchar2 := fnd_api.g_false,
	    p_validation_level         in number   := fnd_api.g_valid_level_full,
	    p_return_status            OUT  NOCOPY varchar2,
	    p_msg_count                OUT  NOCOPY number,
	    p_msg_data                 OUT  NOCOPY varchar2,
	    p_worksheet_id             in number,
	    p_position_id              in number,
	    p_pos_effective_start_date in date  := FND_API.G_MISS_DATE,
	    p_pos_effective_end_date   in date  := FND_API.G_MISS_DATE,
	    p_budget_source             in varchar2:= FND_API.G_MISS_CHAR,
	    p_out_worksheet_id         OUT  NOCOPY number,
	    p_out_start_date           OUT  NOCOPY date,
	    p_out_end_date             OUT  NOCOPY date) IS

BEGIN

     PSB_POSITIONS_PVT.Define_Worksheet_Values (
		    p_api_version     => p_api_version,
		    p_init_msg_list   => p_init_msg_list,
		    p_commit          => p_commit,
		    p_validation_level=> p_validation_level,
		    p_return_status   => p_return_status,
		    p_msg_count       => p_msg_count,
		    p_msg_data        => p_msg_data,
		    p_worksheet_id    => p_worksheet_id,
		    p_position_id     => p_position_id ,
		    p_pos_effective_start_date => p_pos_effective_start_date ,
		    p_pos_effective_end_date => p_pos_effective_end_date,
		    p_budget_source    => p_budget_source,
		    p_out_worksheet_id => p_out_worksheet_id ,
		    p_out_start_date   => p_out_start_date,
		    p_out_end_date     => p_out_end_date
			       );

     --
END Define_Worksheet_Values ;


-- modify_assignment used for insert/modify assignments

PROCEDURE Modify_Assignment (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_position_assignment_id  in OUT  NOCOPY  number,
  p_data_extract_id      in number,
  p_worksheet_id         in number,
  p_position_id         in number,
  p_assignment_type in varchar2,
  p_attribute_id          in number,
  p_attribute_value_id    in number,
  p_attribute_value       in varchar2,
  p_pay_element_id        in number,
  p_pay_element_option_id in number,
  p_effective_start_date  in date,
  p_effective_end_date    in date,
  p_element_value_type   in varchar2,
  p_element_value         in number,
  p_currency_code         in varchar2,
  p_pay_basis             in varchar2,
  p_employee_id           in number,
  p_primary_employee_flag in varchar2,
  p_global_default_flag   in varchar2,
  p_assignment_default_rule_id in number,
  p_modify_flag           in varchar2,
  p_rowid                 in OUT  NOCOPY varchar2,
  p_mode                  in varchar2
 )  IS

BEGIN

  PSB_POSITIONS_PVT.Modify_Assignment (
     p_api_version              => p_api_version,
     p_init_msg_list            => p_init_msg_list,
     p_commit                   => p_commit,
     p_validation_level         => p_validation_level,
     p_return_status            => p_return_status,
     p_msg_count                => p_msg_count,
     p_msg_data                 => p_msg_data,
     p_position_assignment_id   => p_position_assignment_id,
     p_data_extract_id          => p_data_extract_id,
     p_worksheet_id             => p_worksheet_id,
     p_position_id              => p_position_id,
     p_assignment_type       => p_assignment_type,
     p_attribute_id          => p_attribute_id,
     p_attribute_value_id    => p_attribute_value_id,
     p_attribute_value       => p_attribute_value ,
     p_pay_element_id        => p_pay_element_id ,
     p_pay_element_option_id => p_pay_element_option_id,
     p_effective_start_date  => p_effective_start_date,
     p_effective_end_date    => p_effective_end_date,
     p_element_value_type       => p_element_value_type,
     p_element_value         => p_element_value,
     p_currency_code         => p_currency_code ,
     p_pay_basis             => p_pay_basis ,
     p_employee_id           => p_employee_id ,
     p_primary_employee_flag => p_primary_employee_flag ,
     p_global_default_flag   => p_global_default_flag,
     p_assignment_default_rule_id => p_assignment_default_rule_id,
     p_modify_flag           => p_modify_flag     ,
     p_rowid                 => p_rowid,
     p_mode                  => p_mode
     );

END Modify_Assignment;


PROCEDURE Create_Default_Assignments(
  p_api_version          in   number,
  p_init_msg_list        in   varchar2 := FND_API.G_FALSE,
  p_commit               in   varchar2 := FND_API.G_FALSE,
  p_validation_level     in   number   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  varchar2,
  p_msg_count            OUT  NOCOPY  number,
  p_msg_data             OUT  NOCOPY  varchar2,
  p_worksheet_id         in   number   := FND_API.G_MISS_NUM,
  p_data_extract_id      in   number,
  p_position_id          in   number   := FND_API.G_MISS_NUM,
  p_position_start_date  in   date     := FND_API.G_MISS_DATE,
  p_position_end_date    in   date     := FND_API.G_MISS_DATE) IS

  -- bug 4559919
  -- reverted back the changes done for bug#4151746 as the
  -- behavior will be as per MPA for R12 across patch levels

  /* Bug 4273099 start */
  l_default_rule_id       NUMBER;

  -- Bug 5040737 used order by 2 clause in the following cursor
  CURSOR c_Assignment_Ruleset IS
    SELECT a.default_rule_id,
	   f.priority priority,
	   b.global_default_flag,
           b.overwrite,
	   a.assignment_type,
	   a.attribute_id,
	   a.attribute_value_id,
	   a.attribute_value,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code
      FROM psb_default_assignments a,
	   psb_defaults b,
	   psb_set_relations c,
	   psb_budget_positions d,
           psb_entity_set e,
           psb_entity_assignment f
     WHERE a.default_rule_id = b.default_rule_id
       AND b.default_rule_id = c.default_rule_id
       AND c.account_position_set_id = d.account_position_set_id
       AND d.data_extract_id = p_data_extract_id
       AND d.position_id     = p_position_id
       AND e.entity_set_id   = f.entity_set_id
       AND f.entity_id       = b.default_rule_id
       AND e.data_extract_id = p_data_extract_id
       AND e.entity_type     = 'DEFAULT_RULE'
       AND NVL(e.executable_from_position, 'N') = 'Y'
     UNION
    SELECT a.default_rule_id,
           d.priority priority,
           b.global_default_flag,
           b.overwrite,
	   a.assignment_type,
	   a.attribute_id,
	   a.attribute_value_id,
	   a.attribute_value,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code
      FROM psb_default_assignments a,
	   psb_defaults b,
           psb_entity_set c,
           psb_entity_assignment d
     WHERE a.default_rule_id     = b.default_rule_id
       AND b.global_default_flag = 'Y'
       AND b.data_extract_id     = p_data_extract_id
       AND c.entity_set_id       = d.entity_set_id
       AND b.default_rule_id     = d.entity_id
       AND c.data_extract_id     = p_data_extract_id
       AND c.entity_type         = 'DEFAULT_RULE'
       AND NVL(c.executable_from_position, 'N') = 'Y'
       ORDER BY 2;

  CURSOR c_Position IS
    SELECT effective_start_date,
	   effective_end_date
      FROM psb_positions
     WHERE position_id = p_position_id ;

  -- Bug 5040737 used order by 2 clause in the following cursor
  CURSOR c_Priority_ruleset IS
    SELECT a.default_rule_id,
	   f.priority priority,
	   a.global_default_flag,
           a.overwrite
      FROM psb_defaults a,
	   psb_set_relations b,
	   psb_budget_positions c,
           psb_entity_set e,
           psb_entity_assignment f
     WHERE EXISTS
           (SELECT 1
	      FROM PSB_DEFAULT_ACCOUNT_DISTRS d
	     WHERE d.default_rule_id = a.default_rule_id)
       AND a.default_rule_id = b.default_rule_id
       AND b.account_position_set_id = c.account_position_set_id
       AND c.data_extract_id = p_data_extract_id
       AND c.position_id     = p_position_id
       AND e.entity_set_id   = f.entity_set_id
       AND f.entity_id       = a.default_rule_id
       AND e.data_extract_id = p_data_extract_id
       AND e.entity_type     = 'DEFAULT_RULE'
       AND NVL(e.executable_from_position, 'N') = 'Y'
     UNION
    SELECT a.default_rule_id,
	   c.priority priority,
           a.global_default_flag,
           a.overwrite
      FROM psb_defaults a,
           psb_entity_set b,
           psb_entity_assignment c
     WHERE EXISTS (SELECT 1
      FROM PSB_DEFAULT_ACCOUNT_DISTRS d
     WHERE d.default_rule_id = a.default_rule_id)
       AND a.global_default_flag = 'Y'
       AND a.data_extract_id     = p_data_extract_id
       AND b.entity_set_id       = c.entity_set_id
       AND a.default_rule_id     = c.entity_id
       AND b.data_extract_id     = p_data_extract_id
       AND b.entity_type         = 'DEFAULT_RULE'
       AND NVL(b.executable_from_position, 'N') = 'Y'
       ORDER BY 2;

  CURSOR c_Global_Dist IS
    SELECT 'Exists'
      FROM dual
     WHERE EXISTS
	  (SELECT 1
	     FROM PSB_DEFAULT_ACCOUNT_DISTRS a,
		  PSB_DEFAULTS b
            WHERE a.default_rule_id     = b.default_rule_id
	      AND b.global_default_flag = 'Y'
	      AND b.data_extract_id     = p_data_extract_id
              AND a.default_rule_id     = l_default_rule_id
             );

  CURSOR c_Dist IS
    SELECT chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent
      FROM PSB_DEFAULT_ACCOUNT_DISTRS
     WHERE default_rule_id = l_default_rule_id;

  CURSOR l_distribution_id_csr
    IS
    SELECT *
    FROM PSB_POSITION_PAY_DISTRIBUTIONS
    WHERE (((p_position_end_date IS NOT NULL)
	   AND (((effective_start_date <= p_position_end_date)
	   AND (effective_end_date IS NULL))
	   OR ((effective_start_date BETWEEN p_position_start_date AND p_position_end_date)
	   OR (effective_end_date BETWEEN p_position_start_date AND p_position_end_date)
	   OR ((effective_start_date < p_position_start_date)
	   AND (effective_end_date > p_position_end_date)))))
	   OR ((p_position_end_date IS NULL)
	   AND (NVL(effective_end_date, p_position_start_date) >= p_position_start_date)))
           AND data_extract_id = p_data_extract_id
           AND position_id     = p_position_id
           AND ((worksheet_id IS NULL AND NOT EXISTS
           /* Bug 4545909 Start */
           (SELECT 1 FROM psb_position_pay_distributions
            WHERE worksheet_id = p_worksheet_id
              AND position_id  = p_position_id))
               OR worksheet_id = p_worksheet_id
               OR (worksheet_id IS NULL AND p_worksheet_id IS NULL));
           /* Bug 4545909 End */

  l_position_start_date   DATE;
  l_position_end_date     DATE;
  l_return_status         VARCHAR2(1);
  l_posasgn_id            NUMBER;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_priority              NUMBER;
  l_global_default_flag   VARCHAR2(1);
  l_local_dist_exists     VARCHAR2(1) := FND_API.G_FALSE;
  l_global_dist_exists    VARCHAR2(1) := FND_API.G_FALSE;
  l_distribution_id       NUMBER;
  l_rowid                 VARCHAR2(100);
  l_overwrite_flag        VARCHAR2(1);
  l_worksheet_id          NUMBER;

  /* Bug 4273099 end */

BEGIN

    /* Bug 4545909 Start */
    IF p_worksheet_id = FND_API.G_MISS_NUM THEN
      l_worksheet_id := NULL;
    ELSE
      l_worksheet_id := p_worksheet_id;
    END IF;
    /* Bug 4545909 End */

    /* Bug 4545909 Start */

    DELETE FROM psb_budget_positions
     WHERE position_id     = p_position_id
       AND data_extract_id = p_data_extract_id;

     /*Bug:5450510: Added parameter p_data_extract_id to the following api*/
    PSB_Budget_Position_Pvt.Add_Position_To_Position_Sets
      (
         p_api_version       =>  1.0                         ,
         p_init_msg_list     =>  FND_API.G_TRUE              ,
         p_commit            =>  FND_API.G_FALSE             ,
         p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL  ,
         p_return_status     =>  l_return_status             ,
         p_msg_count         =>  l_msg_count                 ,
         p_msg_data          =>  l_msg_data                  ,
         p_position_id       =>  p_position_id,
         p_worksheet_id      =>  l_worksheet_id,
         p_data_extract_id   =>  p_data_extract_id
      );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    END IF;

    /* Bug 4545909 End */

    /* Bug 4273099 start */
    IF ((p_position_start_date = FND_API.G_MISS_DATE) OR
	(p_position_end_date = FND_API.G_MISS_DATE))
    THEN

      FOR c_Position_Rec in c_Position LOOP
	l_position_start_date := c_Position_Rec.effective_start_date;
	l_position_end_date   := c_Position_Rec.effective_end_date;
      END LOOP;

    END IF;

    IF p_position_start_date <> FND_API.G_MISS_DATE THEN
      l_position_start_date := p_position_start_date;
    END IF;

    IF p_position_end_date <> FND_API.G_MISS_DATE THEN
      l_position_end_date := p_position_end_date;
    END IF;

    FOR c_Assignments_Rec in c_Assignment_Ruleset
    LOOP

      psb_positions_pvt.Apply_Position_Default_Rules
          (p_api_version => 1.0,
           x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   p_position_assignment_id => l_posasgn_id,
	   p_data_extract_id => p_data_extract_id,
	   p_position_id => p_position_id,
	   p_assignment_type => c_Assignments_Rec.assignment_type,
	   p_attribute_id => c_Assignments_Rec.attribute_id,
	   p_attribute_value_id => c_Assignments_Rec.attribute_value_id,
	   p_attribute_value => c_Assignments_Rec.attribute_value,
	   p_pay_element_id => c_Assignments_Rec.pay_element_id,
	   p_pay_element_option_id => c_Assignments_Rec.pay_element_option_id,
           p_effective_start_date => l_position_start_date,
	   p_effective_end_date => l_position_end_date,
	   p_element_value_type => c_Assignments_Rec.element_value_type,
	   p_element_value => c_Assignments_Rec.element_value,
	   p_currency_code => c_Assignments_Rec.currency_code,
	   p_pay_basis => c_Assignments_Rec.pay_basis,
	   p_employee_id => null,
	   p_primary_employee_flag => null,
	   p_global_default_flag => c_Assignments_Rec.global_default_flag,
	   p_assignment_default_rule_id => c_Assignments_Rec.default_rule_id,
	   p_modify_flag => c_Assignments_Rec.overwrite,
           p_worksheet_id => l_worksheet_id );
    END LOOP;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    END IF;

    FOR c_Priority_Rec in c_Priority_ruleset LOOP

      l_default_rule_id     := c_Priority_Rec.default_rule_id;
      l_priority            := c_Priority_Rec.priority;
      l_global_default_flag := c_Priority_Rec.global_default_flag;

    IF NVL(c_priority_rec.global_default_flag,'N') = 'N' THEN
      l_local_dist_exists := FND_API.G_TRUE;
    END IF;

    l_overwrite_flag    := c_priority_rec.overwrite;

    IF l_overwrite_flag IS NULL THEN
      l_overwrite_flag    := 'N';
    END IF;

    FOR c_Global_Dist_Rec in c_Global_Dist LOOP
      l_global_dist_exists := FND_API.G_TRUE;
    END LOOP;

    IF l_overwrite_flag <> 'N' THEN

      IF ((FND_API.to_Boolean(l_local_dist_exists)) OR
        (FND_API.to_Boolean(l_global_dist_exists))) THEN
      BEGIN

      PSB_POSITION_PAY_DISTR_PVT.Delete_Distributions_Position
         (p_api_version => 1.0,
          p_return_status => l_return_status,
          p_msg_count => l_msg_count,
          p_msg_data => l_msg_data,
          p_position_id => p_position_id,
          p_worksheet_id => l_worksheet_id);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      END IF;
      END;
      END IF;
    END IF;

    PSB_POSITIONS_PVT.g_distr_percent_total:= 0;

    FOR l_distribution_id_csr_rec IN l_distribution_id_csr
    LOOP
      PSB_POSITIONS_PVT.g_distr_percent_total
        := PSB_POSITIONS_PVT.g_distr_percent_total + l_distribution_id_csr_rec.distribution_percent;
    END LOOP;


    FOR c_Dist_Rec in c_Dist LOOP

        PSB_POSITION_PAY_DISTR_PVT.Apply_Position_Pay_Distr
	  (p_api_version => 1.0,
	   x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   p_distribution_id => l_distribution_id,
	   p_position_id => p_position_id,
	   p_data_extract_id => p_data_extract_id,
	   p_worksheet_id => l_worksheet_id,
	   p_effective_start_date => l_position_start_date,
	   p_effective_end_date => l_position_end_date,
           p_modify_flag => l_overwrite_flag,
	   p_chart_of_accounts_id => c_Dist_Rec.chart_of_accounts_id,
	   p_code_combination_id => c_Dist_Rec.code_combination_id,
	   p_distribution_percent => c_Dist_Rec.distribution_percent,
	   p_global_default_flag => l_global_default_flag,
	   p_distribution_default_rule_id => l_default_rule_id,
	   p_rowid => l_rowid);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   raise FND_API.G_EXC_ERROR;
        END IF;

      END LOOP;

    END LOOP;

  /* Bug 4273099 End */

END Create_Default_Assignments;

FUNCTION Get_Select_Date RETURN DATE IS
  BEGIN
     Return PSB_POSITIONS_PVT.Get_Select_Date ;
  END Get_Select_Date;


FUNCTION Check_Allowed
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_position_budget_group_id  IN   NUMBER
) RETURN VARCHAR2 IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Check_Allowed';
  l_api_version               CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  RETURN PSB_WS_POS1.Check_Allowed
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_worksheet_id => p_worksheet_id,
      p_position_budget_group_id => p_position_budget_group_id);


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     return FND_API.G_FALSE;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     return FND_API.G_FALSE;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     return FND_API.G_FALSE;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Check_Allowed;

FUNCTION Rev_Check_Allowed
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_startdate_pp              IN      DATE,
  p_enddate_cy                IN      DATE,
  p_worksheet_id              IN   NUMBER,
  p_position_budget_group_id  IN   NUMBER
) RETURN VARCHAR2 IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Rev_Check_Allowed';
  l_api_version               CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  RETURN PSB_POSITIONS_PVT.Rev_Check_Allowed
     (p_api_version => p_api_version,
      p_validation_level => p_validation_level,
      p_startdate_pp     => p_startdate_pp,
      p_enddate_cy       => p_enddate_cy,
      p_worksheet_id     => p_worksheet_id,
      p_position_budget_group_id => p_position_budget_group_id);


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     return FND_API.G_FALSE;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     return FND_API.G_FALSE;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     return FND_API.G_FALSE;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Rev_Check_Allowed;

PROCEDURE Modify_Distribution_WS
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_msg_count                     OUT  NOCOPY     NUMBER,
  p_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_worksheet_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_budget_revision_pos_line_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_mode                          IN      VARCHAR2
  ) IS
BEGIN
  PSB_POSITION_PAY_DISTR_PVT.MODIFY_DISTRIBUTION_WS (

      p_api_version                   =>     p_api_version,
      p_init_msg_list                 =>     p_init_msg_list,
      p_commit                        =>     p_commit,
      p_validation_level              =>     p_validation_level,
      p_return_status                 =>     p_return_status,
      p_msg_count                     =>     p_msg_count,
      p_msg_data                      =>     p_msg_data,
      p_distribution_id               =>     p_distribution_id,
      p_worksheet_id                  =>     p_worksheet_id,
      p_position_id                   =>     p_position_id,
      p_data_extract_id               =>     p_data_extract_id,
      p_effective_start_date          =>     p_effective_start_date,
      p_effective_end_date            =>     p_effective_end_date,
      p_chart_of_accounts_id          =>     p_chart_of_accounts_id,
      p_code_combination_id           =>     p_code_combination_id,
      p_distribution_percent          =>     p_distribution_percent,
      p_global_default_flag           =>     p_global_default_flag,
      p_distribution_default_rule_id  =>     p_distribution_default_rule_id,
      p_rowid                         =>     p_rowid,
      p_budget_revision_pos_line_id   =>     p_budget_revision_pos_line_id,
      p_mode                          =>     p_mode
			     );

END Modify_Distribution_WS;

PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_distribution_id     in number
)
IS

BEGIN
  PSB_POSITION_PAY_DISTR_PVT.DELETE_ROW (
	 p_api_version          => p_api_version,
	 p_init_msg_list        => p_init_msg_list,
	 p_commit               => p_commit,
	 p_validation_level     => p_validation_level,
	 p_return_status        => p_return_status,
	 p_msg_count            => p_msg_count,
	 p_msg_data             => p_msg_data,
	 p_distribution_id      => p_distribution_id
  );
END DELETE_ROW;
--

PROCEDURE LOCK_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_row_locked          OUT  NOCOPY varchar2,
  p_distribution_id      in number,
  p_position_id          in number,
  p_data_extract_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date  in date,
  p_chart_of_accounts_id     in number,
  p_code_combination_id in number,
  p_distribution_percent     in number,
  p_global_default_flag in varchar2,
  p_distribution_default_rule_id     in number
) IS

BEGIN
  PSB_POSITION_PAY_DISTR_PVT.LOCK_ROW (
  p_api_version              => p_api_version,
  p_init_msg_list            =>  p_init_msg_list,
  p_commit                   => p_commit,
  p_validation_level         => p_validation_level,
  p_return_status            => p_return_status,
  p_msg_count                => p_msg_count,
  p_msg_data                 => p_msg_data,
  p_row_locked               => p_row_locked,
  p_distribution_id          => p_distribution_id,
  p_position_id              => p_position_id,
  p_data_extract_id          => p_data_extract_id,
  p_effective_start_date     => p_effective_start_date,
  p_effective_end_date       => p_effective_end_date,
  p_chart_of_accounts_id     => p_chart_of_accounts_id,
  p_code_combination_id      => p_code_combination_id,
  p_distribution_percent     => p_distribution_percent,
  p_global_default_flag      => p_global_default_flag,
  p_distribution_default_rule_id     => p_distribution_default_rule_id
  );
END LOCK_ROW;


/* ----------------------------------------------------------------------- */

END PSB_POSITIONS_I_PVT;

/
