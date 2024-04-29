--------------------------------------------------------
--  DDL for Package Body PSB_WS_LINE_YEAR_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_LINE_YEAR_O_PVT" AS
/* $Header: PSBWLYOB.pls 120.3.12010000.3 2009/12/17 09:47:38 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_LINE_YEAR_O_PVT';

/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/

-- Bug#4571412.
-- Added p_year_name_C1..12 parameters to
-- pass Budget Year name to Create_Notes API.

PROCEDURE Update_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id                IN      NUMBER,
  p_position_line_id            IN      NUMBER,
  p_element_set_id              IN      NUMBER,
  p_salary_account_line         IN      VARCHAR2,
  p_budget_group_id             IN      NUMBER,
  p_service_package_id          IN      NUMBER,
  p_flex_code                   IN      NUMBER,
  p_concatenated_segments       IN      VARCHAR2,
  p_currency_code               IN      VARCHAR2,
  p_note                        IN      VARCHAR2,
  p_sbi_year_option_year_id     IN      NUMBER,
  p_column_count                IN      NUMBER,
  --
  p_wal_id_C1                   IN      NUMBER,
  p_year_id_C1                  IN      NUMBER,
  p_year_name_C1                IN      VARCHAR2,
  p_balance_type_C1             IN      VARCHAR2,
  p_ytd_amount_C1               IN      NUMBER,
  p_wal_id_C2                   IN      NUMBER,
  p_year_id_C2                  IN      NUMBER,
  p_year_name_C2                IN      VARCHAR2,
  p_balance_type_C2             IN      VARCHAR2,
  p_ytd_amount_C2               IN      NUMBER,
  p_wal_id_C3                   IN      NUMBER,
  p_year_id_C3                  IN      NUMBER,
  p_year_name_C3                IN      VARCHAR2,
  p_balance_type_C3             IN      VARCHAR2,
  p_ytd_amount_C3               IN      NUMBER,
  p_wal_id_C4                   IN      NUMBER,
  p_year_id_C4                  IN      NUMBER,
  p_year_name_C4                IN      VARCHAR2,
  p_balance_type_C4             IN      VARCHAR2,
  p_ytd_amount_C4               IN      NUMBER,
  p_wal_id_C5                   IN      NUMBER,
  p_year_id_C5                  IN      NUMBER,
  p_year_name_C5                IN      VARCHAR2,
  p_balance_type_C5             IN      VARCHAR2,
  p_ytd_amount_C5               IN      NUMBER,
  p_wal_id_C6                   IN      NUMBER,
  p_year_id_C6                  IN      NUMBER,
  p_year_name_C6                IN      VARCHAR2,
  p_balance_type_C6             IN      VARCHAR2,
  p_ytd_amount_C6               IN      NUMBER,
  p_wal_id_C7                   IN      NUMBER,
  p_year_id_C7                  IN      NUMBER,
  p_year_name_C7                IN      VARCHAR2,
  p_balance_type_C7             IN      VARCHAR2,
  p_ytd_amount_C7               IN      NUMBER,
  p_wal_id_C8                   IN      NUMBER,
  p_year_id_C8                  IN      NUMBER,
  p_year_name_C8                IN      VARCHAR2,
  p_balance_type_C8             IN      VARCHAR2,
  p_ytd_amount_C8               IN      NUMBER,
  p_wal_id_C9                   IN      NUMBER,
  p_year_id_C9                  IN      NUMBER,
  p_year_name_C9                IN      VARCHAR2,
  p_balance_type_C9             IN      VARCHAR2,
  p_ytd_amount_C9               IN      NUMBER,
  p_wal_id_C10                  IN      NUMBER,
  p_year_id_C10                 IN      NUMBER,
  p_year_name_C10               IN      VARCHAR2,
  p_balance_type_C10            IN      VARCHAR2,
  p_ytd_amount_C10              IN      NUMBER,
  p_wal_id_C11                  IN      NUMBER,
  p_year_id_C11                 IN      NUMBER,
  p_year_name_C11               IN      VARCHAR2,
  p_balance_type_C11            IN      VARCHAR2,
  p_ytd_amount_C11              IN      NUMBER,
  p_wal_id_C12                  IN      NUMBER,
  p_year_id_C12                 IN      NUMBER,
  p_year_name_C12               IN      VARCHAR2,
  p_balance_type_C12            IN      VARCHAR2,
  p_ytd_amount_C12              IN      NUMBER
 )
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  --
  l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_index             BINARY_INTEGER;


  --
  l_wal_id              NUMBER;
  l_budget_year_id      NUMBER;
  l_year_type           VARCHAR2(2);
  l_balance_type        VARCHAR2(1);
  l_ytd_amount              NUMBER;
  --
  l_return_status       VARCHAR2(1);
  --
  l_account_line_id     NUMBER;

  l_budget_year_name    VARCHAR2(100);

BEGIN
  --
  SAVEPOINT Update_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  --

  -- Bug#4571412.
  -- Get Budget Year Name.
  FOR i in 1..p_column_count LOOP
    IF i = 1 THEN
      l_wal_id           :=   p_wal_id_C1;
      l_budget_year_id   :=   p_year_id_C1;
      l_budget_year_name :=   p_year_name_C1;
      l_balance_type     :=   p_balance_type_C1;
      l_ytd_amount       :=   p_ytd_amount_C1;
    ELSIF i =2 THEN
      l_wal_id           :=   p_wal_id_C2;
      l_budget_year_id   :=   p_year_id_C2;
      l_budget_year_name :=   p_year_name_C2;
      l_balance_type     :=   p_balance_type_C2;
      l_ytd_amount       :=   p_ytd_amount_C2;
    ELSIF i =3 THEN
      l_wal_id           :=   p_wal_id_C3;
      l_budget_year_id   :=   p_year_id_C3;
      l_budget_year_name :=   p_year_name_C3;
      l_balance_type     :=   p_balance_type_C3;
      l_ytd_amount       :=   p_ytd_amount_C3;
    ELSIF i =4 THEN
      l_wal_id           :=   p_wal_id_C4;
      l_budget_year_id   :=   p_year_id_C4;
      l_budget_year_name :=   p_year_name_C4;
      l_balance_type     :=   p_balance_type_C4;
      l_ytd_amount       :=   p_ytd_amount_C4;
    ELSIF i =5 THEN
      l_wal_id           :=   p_wal_id_C5;
      l_budget_year_id   :=   p_year_id_C5;
      l_budget_year_name :=   p_year_name_C5;
      l_balance_type     :=   p_balance_type_C5;
      l_ytd_amount       :=   p_ytd_amount_C5;
    ELSIF i =6 THEN
      l_wal_id           :=   p_wal_id_C6;
      l_budget_year_id   :=   p_year_id_C6;
      l_budget_year_name :=   p_year_name_C6;
      l_balance_type     :=   p_balance_type_C6;
      l_ytd_amount       :=   p_ytd_amount_C6;
    ELSIF i =7 THEN
      l_wal_id           :=   p_wal_id_C7;
      l_budget_year_id   :=   p_year_id_C7;
      l_budget_year_name :=   p_year_name_C7;
      l_balance_type     :=   p_balance_type_C7;
      l_ytd_amount       :=   p_ytd_amount_C7;
    ELSIF i =8 THEN
      l_wal_id           :=   p_wal_id_C8;
      l_budget_year_id   :=   p_year_id_C8;
      l_budget_year_name :=   p_year_name_C8;
      l_balance_type     :=   p_balance_type_C8;
      l_ytd_amount       :=   p_ytd_amount_C8;
    ELSIF i =9 THEN
      l_wal_id           :=   p_wal_id_C9;
      l_budget_year_id   :=   p_year_id_C9;
      l_budget_year_name :=   p_year_name_C9;
      l_balance_type     :=   p_balance_type_C9;
      l_ytd_amount       :=   p_ytd_amount_C9;
    ELSIF i =10 THEN
      l_wal_id           :=   p_wal_id_C10;
      l_budget_year_id   :=   p_year_id_C10;
      l_budget_year_name :=   p_year_name_C10;
      l_balance_type     :=   p_balance_type_C10;
      l_ytd_amount       :=   p_ytd_amount_C10;
    ELSIF i =11 THEN
      l_wal_id           :=   p_wal_id_C11;
      l_budget_year_id   :=   p_year_id_C11;
      l_budget_year_name :=   p_year_name_C11;
      l_balance_type     :=   p_balance_type_C11;
      l_ytd_amount       :=   p_ytd_amount_C11;
    ELSIF i =12 THEN
      l_wal_id           :=   p_wal_id_C12;
      l_budget_year_id   :=   p_year_id_C12;
      l_budget_year_name :=   p_year_name_C12;
      l_balance_type     :=   p_balance_type_C12;
      l_ytd_amount       :=   p_ytd_amount_C12;
    END IF;

  -- Initialize the table
  FOR l_index in 1..PSB_WS_ACCT1.G_MAX_NUM_AMOUNTS LOOP
     l_period_amount(l_index) := NULL;
  END LOOP;

   -- amount types can be B-Budget, A-Actuals, E- Estimate, F -FTE
   -- Update rows only for current and proposed years
   -- and only when amount type is not FTE
   IF l_balance_type = 'E'  THEN

      -- user enters a value for an year for which no row currently exists
      -- create row
      IF nvl(l_wal_id,0) = 0  and nvl(l_ytd_amount,0) <> 0 then

	IF  p_position_line_id IS NULL THEN

	  PSB_WS_ACCT_PVT.Create_Account_Dist
	  (
	  p_api_version                 => 1.0,
	  p_init_msg_list               => FND_API.G_FALSE,
	  p_commit                      => FND_API.G_FALSE,
	  p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	  p_return_status               => l_return_status,
	  p_msg_count                   => p_msg_count,
	  p_msg_data                    => p_msg_data,
	  p_account_line_id             => l_account_line_id,
	  p_worksheet_id                => p_worksheet_id,
	  p_map_accounts                => TRUE,
	  p_budget_year_id              => l_budget_year_id,
	  p_budget_group_id             => p_budget_group_id,
	  p_flex_code                   => p_flex_code,
	  p_concatenated_segments       => p_concatenated_segments,
	  p_currency_code               => p_currency_code,
	  p_balance_type                => 'E',
	  p_ytd_amount                  => l_ytd_amount,
	  p_distribute_flag             => FND_API.G_TRUE,
	  p_period_amount               => l_period_amount,
	  p_service_package_id          => p_service_package_id
	  );


	 IF NVL(p_sbi_year_option_year_id,l_budget_year_id) = l_budget_year_id
	 THEN
	   if p_note is not null then
	   begin
             -- Bug#4571412
             -- Adding parameters to the call to make it sync
             -- with it's definiiton.
	     PSB_WS_ACCT1.Create_Note
             (p_return_status         => l_return_status,
	      p_account_line_id       => l_account_line_id,
              p_note                  => p_note,
              p_chart_of_accounts_id  => NULL,
              p_budget_year           => l_budget_year_name,
              p_cc_id                 => NULL,
              p_concatenated_segments => p_concatenated_segments
             );
	   end;
	   end if;
	 END IF ;

	ELSE
	  PSB_WS_ACCT_PVT.Create_Account_Dist
	  (
	  p_api_version                 => 1.0,
	  p_init_msg_list               => FND_API.G_FALSE,
	  p_commit                      => FND_API.G_FALSE,
	  p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	  p_return_status               => l_return_status,
	  p_msg_count                   => p_msg_count,
	  p_msg_data                    => p_msg_data,
	  p_account_line_id             => l_account_line_id,
	  p_worksheet_id                => p_worksheet_id,
	  p_map_accounts                => TRUE,
	  p_budget_year_id              => l_budget_year_id,
	  p_budget_group_id             => p_budget_group_id,
	  p_flex_code                   => p_flex_code,
	  p_concatenated_segments       => p_concatenated_segments,
	  p_currency_code               => p_currency_code,
	  p_balance_type                => 'E',
	  p_ytd_amount                  => l_ytd_amount,
	  p_distribute_flag             => FND_API.G_TRUE,
	  p_period_amount               => l_period_amount,
	  p_position_line_id            => p_position_line_id,
	  p_element_set_id              => p_element_set_id,
	  p_salary_account_line         => p_salary_account_line,
	  p_service_package_id          => p_service_package_id
	  );
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;


      ELSIF nvl(l_wal_id,0) <> 0   THEN  --update row

	PSB_WS_ACCT_PVT.Create_Account_Dist
	(
	  p_api_version                 => 1.0,
	  p_init_msg_list               => FND_API.G_FALSE,
	  p_commit                      => FND_API.G_FALSE,
	  p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	  p_return_status               => l_return_status,
	  p_msg_count                   => p_msg_count,
	  p_msg_data                    => p_msg_data,
	  p_distribute_flag             => FND_API.G_TRUE,
	  p_worksheet_id                => p_worksheet_id,
	  p_account_line_id             => l_wal_id,
	  p_service_package_id          => p_service_package_id,
	  p_ytd_amount                  => l_ytd_amount,
	  p_period_amount               => l_period_amount
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;

	IF NVL(p_sbi_year_option_year_id,l_budget_year_id) = l_budget_year_id
	THEN
	  if p_note is not null then
	  begin
            -- Bug#4571412
            -- Adding parameters to the call to make it sync
            -- with it's definiiton.
	    PSB_WS_ACCT1.Create_Note
            (p_return_status         => l_return_status,
	     p_account_line_id       => l_wal_id,       --bug:9107577:passed l_wal_id instead of l_account_line_id
             p_note                  => p_note,
             p_chart_of_accounts_id  => NULL,
             p_budget_year           => l_budget_year_name,
             p_cc_id                 => NULL,
             p_concatenated_segments => p_concatenated_segments
            );
	  end;
	  end if;
	END IF;

      END IF;

    END IF;

  END LOOP;
  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Update_Row;
/* ----------------------------------------------------------------------- */


END PSB_WS_LINE_YEAR_O_PVT;

/
