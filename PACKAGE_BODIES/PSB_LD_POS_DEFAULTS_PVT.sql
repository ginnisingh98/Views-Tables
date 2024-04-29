--------------------------------------------------------
--  DDL for Package Body PSB_LD_POS_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_LD_POS_DEFAULTS_PVT" AS
/* $Header: PSBVLDRB.pls 120.2 2004/12/08 06:30:36 maniskum ship $ */

--
-- Global Variables

  g_pkg_name       CONSTANT VARCHAR2(30):= 'PSB_LD_POS_DEFAULTS_PVT';
  g_debug          VARCHAR2(2000);

/*----------------------- Table HANDler Procedures ----------------------- */

PROCEDURE Create_LD_Default_Assignments
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id      IN   NUMBER

) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Create_Default_LD_Assignments';
  l_api_version          CONSTANT NUMBER         := 1.0;
  --
  l_position_id               NUMBER;
  l_position_start_date       DATE;
  l_position_end_date         DATE;
  l_distr_start_date          DATE;
  l_distr_end_date            DATE;
  l_worksheet_id              NUMBER;
  l_default_rule_id           NUMBER;
  l_distribution_id           NUMBER;
  l_percentage                NUMBER := 0;
  l_distribution_percentage   NUMBER := 0;
  l_count                     NUMBER;
  --
  l_rowid                     VARCHAR2(100);
  l_msg_data                  VARCHAR2(2000);
  l_msg_count                 NUMBER;
  l_return_status             VARCHAR2(1);
  --

  CURSOR l_positions_csr is
    SELECT position_id,
	   business_group_id,
	   vacant_position_flag,
	   effective_start_date,
	   effective_end_date
      FROM PSB_POSITIONS
     WHERE data_extract_id = p_data_extract_id
       AND (vacant_position_flag is NULL
	or vacant_position_flag = 'N');

  CURSOR l_dates_csr is
    SELECT effective_start_date,
	   effective_END_date
      FROM PSB_POSITIONS
     WHERE position_id = l_position_id;


  --to check what rules were already applied AND the total distribution
  --percentage is 100 or less

  CURSOR l_dist_csr is
    SELECT distribution_id,
	   position_id,
	   data_extract_id,
	   effective_start_date,
	   effective_END_date,
	   chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent,
	   distribution_default_rule_id
      FROM PSB_POSITION_PAY_DISTRIBUTIONS
     WHERE data_extract_id = p_data_extract_id
       AND (((l_position_END_date is not NULL)
       AND (((effective_start_date <= l_position_end_date)
       AND (effective_END_date is NULL))
	OR ((effective_start_date between l_position_start_date
       AND l_position_END_date)
	OR (effective_END_date between l_position_start_date
       AND l_position_END_date)
	OR ((effective_start_date < l_position_start_date)
       AND (effective_END_date > l_position_END_date)))))
	OR ((l_position_END_date is NULL)
       AND (nvl(effective_END_date, l_position_start_date)
	   >= l_position_start_date)))
       AND position_id = l_position_id
       AND code_combination_id IS NOT NULL;

  -- pick the effective start date and end date for the local default rule which
  -- will be applied
  CURSOR l_eff_dates_csr is
    SELECT effective_start_date, effective_end_date
    FROM   PSB_POSITION_PAY_DISTRIBUTIONS
    WHERE  position_id=l_position_id
    AND    project_id IS NOT NULL
    AND    code_combination_id IS NULL;

  --pick local default rule to apply LD salary distribution
  CURSOR l_priority_csr is
    SELECT a.default_rule_id,
	   a.priority
      FROM PSB_DEFAULTS a,
	   PSB_SET_RELATIONS b,
	   PSB_BUDGET_POSITIONS c
     WHERE exists
	  (SELECT 1
	     FROM PSB_DEFAULT_ACCOUNT_DISTRS d
	    WHERE d.default_rule_id = a.default_rule_id)
       AND a.priority is not NULL
       AND (a.global_default_flag = 'N'
	   or a.global_default_flag IS NULL)
       AND a.default_rule_id = b.default_rule_id
       AND b.account_position_set_id = c.account_position_set_id
       AND c.data_extract_id = p_data_extract_id
       AND c.position_id = l_position_id
     ORDER BY a.priority;

  CURSOR l_ld_dist_csr is
    SELECT chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent
      FROM PSB_DEFAULT_ACCOUNT_DISTRS
     WHERE default_rule_id = l_default_rule_id
     AND   code_combination_id IS NOT NULL;


BEGIN

  -- Standard call to check FOR call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SAVEPOINT LD_Default_Assignments;

  FOR l_positions_rec IN l_positions_csr
  LOOP

    --check what positions have pay distribution percentage less than 100
    l_position_id := l_positions_rec.position_id;

    FOR l_dates_rec in l_dates_csr
    LOOP
      l_position_start_date := l_dates_rec.effective_start_date;
      l_position_end_date := l_dates_rec.effective_end_date;
    END LOOP;--end of l_dates_rec

    l_distribution_percentage := 0;
    l_percentage := 0;

    --effective dates for the distribution

    l_distr_start_date := null;
    l_distr_end_date   := null;

    FOR l_eff_dates_rec in l_eff_dates_csr
    LOOP
      l_distr_start_date := l_eff_dates_rec.effective_start_date;
      l_distr_end_date   := l_eff_dates_rec.effective_end_date;
    END LOOP;--end of l_eff_dates csr

    FOR l_dist_rec in l_dist_csr
    LOOP

      l_distribution_percentage :=
	   l_dist_rec.distribution_percent+l_distribution_percentage;

      if (l_distr_start_date is null) then
	 l_distr_start_date := l_dist_rec.effective_start_date;
	 l_distr_end_date   := l_dist_rec.effective_end_date;
      end if;

    END LOOP;--end of l_dist_rec

    if (l_distr_start_date is null) then
       l_distr_start_date := l_position_start_date;
       l_distr_end_date   := l_position_end_date;
    end if;

    IF l_distribution_percentage <100 THEN
      l_percentage := 100-l_distribution_percentage;

    BEGIN

      IF p_worksheet_id = FND_API.G_MISS_NUM THEN
	l_worksheet_id := NULL;
      ELSE
	l_worksheet_id := p_worksheet_id;
      END IF;

      FOR l_priority_rec in l_priority_csr
      LOOP

      --The default rule with least priority is applied FOR
      --remaining percentage of salary distribution
      --initializing the count;

      l_count := 1;

      IF l_count = 1 THEN

	l_default_rule_id := l_priority_rec.default_rule_id;


	FOR l_ld_dist_rec in l_ld_dist_csr
	LOOP

	  --Apply this default rule FOR only the distribution percent which
	  --is not accounted FOR

	  l_distribution_percentage :=
		      l_percentage *0.01*l_ld_dist_rec.distribution_percent;
	  PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution
	  (p_api_version => 1.0,
	   p_init_msg_list => FND_API.G_FALSE,
	   p_commit        => FND_API.G_FALSE,
	   p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	   p_return_status => l_return_status,
	   p_msg_count => l_msg_count,
	   p_msg_data => l_msg_data,
	   p_distribution_id => l_distribution_id,
	   p_position_id => l_position_id,
	   p_data_extract_id => p_data_extract_id,
	   p_effective_start_date => l_distr_start_date,
	   p_effective_end_date => l_distr_end_date,
	   p_chart_of_accounts_id => l_ld_dist_rec.chart_of_accounts_id,
	   p_code_combination_id => l_ld_dist_rec.code_combination_id,
	   p_distribution_percent => l_distribution_percentage,
	   p_global_default_flag => 'N',
	   p_distribution_default_rule_id => l_default_rule_id,
	   p_rowid => l_rowid,
	   p_mode  => 'R');

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;

	END LOOP;--end of l_ld_dist_rec

	l_count := l_count+1;

      END IF;
      END LOOP;--end of l_priority_rec

    END;

    END IF; --end of check for percentage

  END LOOP; --end of l_positions_rec

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- StANDard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    commit work;
  END IF;

  -- StANDard call to get message count AND IF count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK to LD_Default_Assignments;

    p_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK to LD_Default_Assignments;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

  WHEN OTHERS THEN

    ROLLBACK to LD_Default_Assignments;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level
      (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN FND_MSG_PUB.Add_Exc_Msg
      (p_pkg_name => G_PKG_NAME,p_procedure_name => l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_LD_Default_Assignments;


/*===========================================================================+
 |                   PROCEDURE Assign_LD_Pos_Defaults_CP                   |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Assign LD Position
-- Defaults'
--
PROCEDURE Assign_LD_Pos_Defaults_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_data_extract_id            IN      NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Assign_LD_Pos_Defaults_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_data_extract_name       VARCHAR2(30);
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;

BEGIN

  Select data_extract_name
    into l_data_extract_name
    from psb_data_extracts
   where data_extract_id = p_data_extract_id;

  FND_FILE.Put_Line( FND_FILE.OUTPUT,
			 'Assigning position defaults for data extract id : ' ||
			  p_data_extract_id );

  PSB_BUDGET_POSITION_PVT.Populate_Budget_Positions
     (p_api_version       =>  1.0,
      p_commit            =>  FND_API.G_TRUE,
      p_return_status     =>  l_return_status,
      p_msg_count         =>  l_msg_count,
      p_msg_data          =>  l_msg_data,
      p_data_extract_id   =>  p_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_CONCURRENCY_CONTROL_PUB.Enforce_Concurrency_Control
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_msg_count         => l_msg_count,
      p_msg_data          => l_msg_data,
      p_concurrency_class => 'MAINTENANCE',
      p_concurrency_entity_name => 'DATA_EXTRACT',
      p_concurrency_entity_id => p_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_LD_POS_DEFAULTS_PVT.Create_LD_Default_Assignments(
	p_api_version           => 1.0,
	p_init_msg_list         => FND_API.G_TRUE,
	p_commit                => FND_API.G_TRUE,
	p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
	p_return_status         => l_return_status,
	p_msg_count             => l_msg_count,
	p_msg_data              => l_msg_data,
	p_data_extract_id       => p_data_extract_id) ;

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;
  --

  -- This is the execution file for the concurrent program 'Release Concurrency
  -- Control '

  PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_msg_count         => l_msg_count,
      p_msg_data          => l_msg_data,
      p_concurrency_class => 'MAINTENANCE',
      p_concurrency_entity_name => 'DATA_EXTRACT',
      p_concurrency_entity_id => p_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
  retcode := 0 ;
  --
  COMMIT WORK;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    --
    PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
    (p_api_version => 1.0,
     p_return_status => l_return_status,
     p_msg_count => l_msg_count,
     p_msg_data => l_msg_data,
     p_concurrency_class => 'MAINTENANCE',
     p_concurrency_entity_name => 'DATA_EXTRACT',
     p_concurrency_entity_id => p_data_extract_id);

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
    (p_api_version => 1.0,
     p_return_status => l_return_status,
     p_msg_count => l_msg_count,
     p_msg_data => l_msg_data,
     p_concurrency_class => 'MAINTENANCE',
     p_concurrency_entity_name => 'DATA_EXTRACT',
     p_concurrency_entity_id => p_data_extract_id);

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN OTHERS THEN

    PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
    (p_api_version => 1.0,
     p_return_status => l_return_status,
     p_msg_count => l_msg_count,
     p_msg_data => l_msg_data,
     p_concurrency_class => 'MAINTENANCE',
     p_concurrency_entity_name => 'DATA_EXTRACT',
     p_concurrency_entity_id => p_data_extract_id);

    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;
    --
END Assign_LD_Pos_Defaults_CP;

/* ----------------------------------------------------------------------- */

-- Get Debug Information

-- This Module is used to retrieve Debug Information FOR Funds Checker. It
-- prints Debug InFORmation WHEN run as a Batch Process FROM SQL*Plus. For
-- the Debug InFORmation to be printed on the Screen, the SQL*Plus parameter
-- 'Serveroutput' should be set to 'ON'

FUNCTION get_debug RETURN VARCHAR2 IS

BEGIN

    return(g_debug);

END get_debug;


END PSB_LD_POS_DEFAULTS_PVT;

/
