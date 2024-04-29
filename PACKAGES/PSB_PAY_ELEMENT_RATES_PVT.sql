--------------------------------------------------------
--  DDL for Package PSB_PAY_ELEMENT_RATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PAY_ELEMENT_RATES_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVRTSS.pls 120.2 2005/07/13 11:29:31 shtripat ship $ */


PROCEDURE INSERT_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_EFFECTIVE_START_DATE             in      DATE,
  P_EFFECTIVE_END_DATE               in      DATE,
  P_WORKSHEET_ID                     in      NUMBER,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_ELEMENT_VALUE                    in      NUMBER,
  P_PAY_BASIS                        in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_MAXIMUM_VALUE                    in      NUMBER,
  P_MID_VALUE                        in      NUMBER,
  P_MINIMUM_VALUE                    in      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  P_CREATED_BY                       in      NUMBER,
  P_CREATION_DATE                    in      DATE
);

PROCEDURE UPDATE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER,
  P_EFFECTIVE_START_DATE             in      DATE := FND_API.G_MISS_DATE,
  P_EFFECTIVE_END_DATE               in      DATE := FND_API.G_MISS_DATE,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_ELEMENT_VALUE                    in      NUMBER,
  P_PAY_BASIS                        in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_MAXIMUM_VALUE                    in      NUMBER,
  P_MID_VALUE                        in      NUMBER,
  P_MINIMUM_VALUE                    in      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER
);

PROCEDURE DELETE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER
);

PROCEDURE LOCK_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_row_locked                       OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_EFFECTIVE_START_DATE             in      DATE,
  P_EFFECTIVE_END_DATE               in      DATE,
  P_WORKSHEET_ID                     in      NUMBER,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_ELEMENT_VALUE                    in      NUMBER,
  P_PAY_BASIS                        in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_MAXIMUM_VALUE                    in      NUMBER,
  P_MID_VALUE                        in      NUMBER,
  P_MINIMUM_VALUE                    in      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2
 );

PROCEDURE Delete_Element_Rates
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

PROCEDURE Modify_Element_Rates
( p_api_version            IN   NUMBER,
  p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_pay_element_id         IN   NUMBER,
  p_pay_element_option_id  IN   NUMBER,
  p_effective_start_date   IN   DATE,
  p_effective_end_date     IN   DATE,
  p_worksheet_id           IN   NUMBER,
  p_element_value_type     IN   VARCHAR2,
  p_element_value          IN   NUMBER,
  p_pay_basis              IN   VARCHAR2,
  p_formula_id             IN   NUMBER,
  p_maximum_value          IN   NUMBER,
  p_mid_value              IN   NUMBER,
  p_minimum_value          IN   NUMBER,
  p_currency_code          IN   VARCHAR2
);


PROCEDURE Check_Date_Range_Overlap
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_pay_element_id            IN       NUMBER,
  p_pay_element_option_id     IN       NUMBER,
  p_overlap_found_flag        OUT  NOCOPY      VARCHAR2
);

END PSB_PAY_ELEMENT_RATES_PVT;

 

/
