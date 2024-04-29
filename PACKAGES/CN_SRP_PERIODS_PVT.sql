--------------------------------------------------------
--  DDL for Package CN_SRP_PERIODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PERIODS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvsprds.pls 120.2 2005/08/02 11:09:41 mblum noship $ */

-- Global variable for the translatable name for all Plan Assign objects.
TYPE pay_period_rec_type IS RECORD
  (period_id   cn_period_statuses.period_id%TYPE,
   org_id      cn_period_statuses.org_id%TYPE,
   start_date  cn_period_statuses.start_date%TYPE,
   end_date    cn_period_statuses.end_date%TYPE);

TYPE pay_period_rec_tbl_type IS TABLE OF pay_period_rec_type
  INDEX BY BINARY_INTEGER ;

TYPE delta_srp_period_rec_type IS RECORD
  (srp_period_id   cn_srp_periods.srp_period_id%TYPE,
   salesrep_id     cn_srp_periods.salesrep_id%TYPE  := NULL ,
   org_id          cn_srp_periods.org_id%TYPE       := NULL ,
   period_id       cn_srp_periods.period_id%TYPE    := NULL ,
   start_date      cn_srp_periods.start_date%TYPE   := NULL ,
   end_date        cn_srp_periods.end_date%TYPE     := NULL ,
   credit_type_id  cn_srp_periods.credit_type_id%TYPE := NULL ,
   role_id         cn_srp_periods.role_id%TYPE      := NULL ,
   quota_id        cn_srp_periods.quota_id%TYPE     := NULL ,
   pay_group_id    cn_srp_periods.pay_group_id%TYPE := NULL ,
   del_balance1_bbc    cn_srp_periods.balance1_bbc%TYPE := 0,
   del_balance1_bbd    cn_srp_periods.balance1_bbd%TYPE := 0,
   del_balance1_ctd    cn_srp_periods.balance1_ctd%TYPE := 0,
   del_balance1_dtd    cn_srp_periods.balance1_dtd%TYPE := 0,
   del_balance2_bbc    cn_srp_periods.balance2_bbc%TYPE := 0,
   del_balance2_bbd    cn_srp_periods.balance2_bbd%TYPE := 0,
   del_balance2_ctd    cn_srp_periods.balance2_ctd%TYPE := 0,
   del_balance2_dtd    cn_srp_periods.balance2_dtd%TYPE := 0,
   del_balance3_bbc    cn_srp_periods.balance3_bbc%TYPE := 0,
   del_balance3_bbd    cn_srp_periods.balance3_bbd%TYPE := 0,
   del_balance3_ctd    cn_srp_periods.balance3_ctd%TYPE := 0,
   del_balance3_dtd    cn_srp_periods.balance3_dtd%TYPE := 0,
   del_balance4_bbc    cn_srp_periods.balance4_bbc%TYPE := 0,
   del_balance4_bbd    cn_srp_periods.balance4_bbd%TYPE := 0,
   del_balance4_ctd    cn_srp_periods.balance4_ctd%TYPE := 0,
   del_balance4_dtd    cn_srp_periods.balance4_dtd%TYPE := 0,
   del_balance5_bbc    cn_srp_periods.balance5_bbc%TYPE := 0,
   del_balance5_bbd    cn_srp_periods.balance5_bbd%TYPE := 0,
   del_balance5_ctd    cn_srp_periods.balance5_ctd%TYPE := 0,
   del_balance5_dtd    cn_srp_periods.balance5_dtd%TYPE := 0,
   del_balance6_bbc    cn_srp_periods.balance6_bbc%TYPE := 0,
   del_balance6_bbd    cn_srp_periods.balance6_bbd%TYPE := 0,
   del_balance6_ctd    cn_srp_periods.balance6_ctd%TYPE := 0,
   del_balance6_dtd    cn_srp_periods.balance6_dtd%TYPE := 0,
   del_balance7_bbc    cn_srp_periods.balance7_bbc%TYPE := 0,
  del_balance7_bbd    cn_srp_periods.balance7_bbd%TYPE := 0,
  del_balance7_ctd    cn_srp_periods.balance7_ctd%TYPE := 0,
  del_balance7_dtd    cn_srp_periods.balance7_dtd%TYPE := 0,
  del_balance8_bbc    cn_srp_periods.balance8_bbc%TYPE := 0,
  del_balance8_bbd    cn_srp_periods.balance8_bbd%TYPE := 0,
  del_balance8_ctd    cn_srp_periods.balance8_ctd%TYPE := 0,
  del_balance8_dtd    cn_srp_periods.balance8_dtd%TYPE := 0,
  del_balance9_bbc    cn_srp_periods.balance9_bbc%TYPE := 0,
  del_balance9_bbd    cn_srp_periods.balance9_bbd%TYPE := 0,
  del_balance9_ctd    cn_srp_periods.balance9_ctd%TYPE := 0,
  del_balance9_dtd    cn_srp_periods.balance9_dtd%TYPE := 0,
  del_balance10_bbc    cn_srp_periods.balance10_bbc%TYPE := 0,
  del_balance10_bbd    cn_srp_periods.balance10_bbd%TYPE := 0,
  del_balance10_ctd    cn_srp_periods.balance10_ctd%TYPE := 0,
  del_balance10_dtd    cn_srp_periods.balance10_dtd%TYPE := 0,
  del_balance11_bbc    cn_srp_periods.balance11_bbc%TYPE := 0,
  del_balance11_bbd    cn_srp_periods.balance11_bbd%TYPE := 0,
  del_balance11_ctd    cn_srp_periods.balance11_ctd%TYPE := 0,
  del_balance11_dtd    cn_srp_periods.balance11_dtd%TYPE := 0,
  del_balance12_bbc    cn_srp_periods.balance12_bbc%TYPE := 0,
  del_balance12_bbd    cn_srp_periods.balance12_bbd%TYPE := 0,
  del_balance12_ctd    cn_srp_periods.balance12_ctd%TYPE := 0,
  del_balance12_dtd    cn_srp_periods.balance12_dtd%TYPE := 0,
  del_balance13_bbc    cn_srp_periods.balance13_bbc%TYPE := 0,
  del_balance13_bbd    cn_srp_periods.balance13_bbd%TYPE := 0,
  del_balance13_ctd    cn_srp_periods.balance13_ctd%TYPE := 0,
  del_balance13_dtd    cn_srp_periods.balance13_dtd%TYPE := 0,
  del_balance14_bbc    cn_srp_periods.balance14_bbc%TYPE := 0,
  del_balance14_bbd    cn_srp_periods.balance14_bbd%TYPE := 0,
  del_balance14_ctd    cn_srp_periods.balance14_ctd%TYPE := 0,
  del_balance14_dtd    cn_srp_periods.balance14_dtd%TYPE := 0,
  del_balance15_bbc    cn_srp_periods.balance15_bbc%TYPE := 0,
  del_balance15_bbd    cn_srp_periods.balance15_bbd%TYPE := 0,
  del_balance15_ctd    cn_srp_periods.balance15_ctd%TYPE := 0,
  del_balance15_dtd    cn_srp_periods.balance15_dtd%TYPE := 0,
  del_balance16_bbc    cn_srp_periods.balance16_bbc%TYPE := 0,
  del_balance16_bbd    cn_srp_periods.balance16_bbd%TYPE := 0,
  del_balance16_ctd    cn_srp_periods.balance16_ctd%TYPE := 0,
  del_balance16_dtd    cn_srp_periods.balance16_dtd%TYPE := 0,
  del_balance17_bbc    cn_srp_periods.balance17_bbc%TYPE := 0,
  del_balance17_bbd    cn_srp_periods.balance17_bbd%TYPE := 0,
  del_balance17_ctd    cn_srp_periods.balance17_ctd%TYPE := 0,
  del_balance17_dtd    cn_srp_periods.balance17_dtd%TYPE := 0,
  del_balance18_bbc    cn_srp_periods.balance18_bbc%TYPE := 0,
  del_balance18_bbd    cn_srp_periods.balance18_bbd%TYPE := 0,
  del_balance18_ctd    cn_srp_periods.balance18_ctd%TYPE := 0,
  del_balance18_dtd    cn_srp_periods.balance18_dtd%TYPE := 0,
  del_balance19_bbc    cn_srp_periods.balance19_bbc%TYPE := 0,
  del_balance19_bbd    cn_srp_periods.balance19_bbd%TYPE := 0,
  del_balance19_ctd    cn_srp_periods.balance19_ctd%TYPE := 0,
  del_balance19_dtd    cn_srp_periods.balance19_dtd%TYPE := 0,
  del_balance20_bbc    cn_srp_periods.balance20_bbc%TYPE := 0,
  del_balance20_bbd    cn_srp_periods.balance20_bbd%TYPE := 0,
  del_balance20_ctd    cn_srp_periods.balance20_ctd%TYPE := 0,
  del_balance20_dtd    cn_srp_periods.balance20_dtd%TYPE := 0,
  del_balance21_bbc    cn_srp_periods.balance21_bbc%TYPE := 0,
  del_balance21_bbd    cn_srp_periods.balance21_bbd%TYPE := 0,
  del_balance21_ctd    cn_srp_periods.balance21_ctd%TYPE := 0,
  del_balance21_dtd    cn_srp_periods.balance21_dtd%TYPE := 0,
  del_balance22_bbc    cn_srp_periods.balance22_bbc%TYPE := 0,
  del_balance22_bbd    cn_srp_periods.balance22_bbd%TYPE := 0,
  del_balance22_ctd    cn_srp_periods.balance22_ctd%TYPE := 0,
  del_balance22_dtd    cn_srp_periods.balance22_dtd%TYPE := 0,
  del_balance23_bbc    cn_srp_periods.balance23_bbc%TYPE := 0,
  del_balance23_bbd    cn_srp_periods.balance23_bbd%TYPE := 0,
  del_balance23_ctd    cn_srp_periods.balance23_ctd%TYPE := 0,
  del_balance23_dtd    cn_srp_periods.balance23_dtd%TYPE := 0,
  del_balance24_bbc    cn_srp_periods.balance24_bbc%TYPE := 0,
  del_balance24_bbd    cn_srp_periods.balance24_bbd%TYPE := 0,
  del_balance24_ctd    cn_srp_periods.balance24_ctd%TYPE := 0,
  del_balance24_dtd    cn_srp_periods.balance24_dtd%TYPE := 0,
  del_balance25_bbc    cn_srp_periods.balance25_bbc%TYPE := 0,
  del_balance25_bbd    cn_srp_periods.balance25_bbd%TYPE := 0,
  del_balance25_ctd    cn_srp_periods.balance25_ctd%TYPE := 0,
  del_balance25_dtd    cn_srp_periods.balance25_dtd%TYPE := 0,
  del_balance26_bbc    cn_srp_periods.balance26_bbc%TYPE := 0,
  del_balance26_bbd    cn_srp_periods.balance26_bbd%TYPE := 0,
  del_balance26_ctd    cn_srp_periods.balance26_ctd%TYPE := 0,
  del_balance26_dtd    cn_srp_periods.balance26_dtd%TYPE := 0,
  del_balance27_bbc    cn_srp_periods.balance27_bbc%TYPE := 0,
  del_balance27_bbd    cn_srp_periods.balance27_bbd%TYPE := 0,
  del_balance27_ctd    cn_srp_periods.balance27_ctd%TYPE := 0,
  del_balance27_dtd    cn_srp_periods.balance27_dtd%TYPE := 0,
  del_balance28_bbc    cn_srp_periods.balance28_bbc%TYPE := 0,
  del_balance28_bbd    cn_srp_periods.balance28_bbd%TYPE := 0,
  del_balance28_ctd    cn_srp_periods.balance28_ctd%TYPE := 0,
  del_balance28_dtd    cn_srp_periods.balance28_dtd%TYPE := 0,
  del_balance29_bbc    cn_srp_periods.balance29_bbc%TYPE := 0,
  del_balance29_bbd    cn_srp_periods.balance29_bbd%TYPE := 0,
  del_balance29_ctd    cn_srp_periods.balance29_ctd%TYPE := 0,
  del_balance29_dtd    cn_srp_periods.balance29_dtd%TYPE := 0,
  del_balance30_bbc    cn_srp_periods.balance30_bbc%TYPE := 0,
  del_balance30_bbd    cn_srp_periods.balance30_bbd%TYPE := 0,
  del_balance30_ctd    cn_srp_periods.balance30_ctd%TYPE := 0,
  del_balance30_dtd    cn_srp_periods.balance30_dtd%TYPE := 0,
  del_balance31_bbc    cn_srp_periods.balance31_bbc%TYPE := 0,
  del_balance31_bbd    cn_srp_periods.balance31_bbd%TYPE := 0,
  del_balance31_ctd    cn_srp_periods.balance31_ctd%TYPE := 0,
  del_balance31_dtd    cn_srp_periods.balance31_dtd%TYPE := 0,
  del_balance32_bbc    cn_srp_periods.balance32_bbc%TYPE := 0,
  del_balance32_bbd    cn_srp_periods.balance32_bbd%TYPE := 0,
  del_balance32_ctd    cn_srp_periods.balance32_ctd%TYPE := 0,
  del_balance32_dtd    cn_srp_periods.balance32_dtd%TYPE := 0,
  del_balance33_bbc    cn_srp_periods.balance33_bbc%TYPE := 0,
  del_balance33_bbd    cn_srp_periods.balance33_bbd%TYPE := 0,
  del_balance33_ctd    cn_srp_periods.balance33_ctd%TYPE := 0,
  del_balance33_dtd    cn_srp_periods.balance33_dtd%TYPE := 0
  );

G_MISS_DELTA_SRP_PERIOD_REC delta_srp_period_rec_type;

-- Start of comments
-- API name 	: Create_Srp_Periods
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new record in cn_srp_periods
-- Desc 	: Procedure to create a new record in cn_srp_periods
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_salesrep_id       IN    NUMBER,
--                 p_period_id         IN    NUMBER,
--                 p_srp_plan_assign_id IN   NUMBER,
--                 p_credit_type_id    IN    NUMBER,
--                 p_role_id           IN    NUMBER
-- OUT		:  x_srp_period_id     OUT   NUMBER
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE Create_Srp_Periods
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_salesrep_id        IN    NUMBER,
   p_role_id            IN    NUMBER,
   p_comp_plan_id       IN    NUMBER,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_sync_flag          IN    VARCHAR2 := FND_API.G_TRUE,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );

-- same as Create_Srp_Periods but only for one plan element
PROCEDURE Create_Srp_Periods_Per_Quota
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count          OUT   NOCOPY NUMBER,
   x_msg_data           OUT   NOCOPY VARCHAR2,
   p_salesrep_id        IN    NUMBER,
   p_role_id            IN    NUMBER,
   p_comp_plan_id       IN    NUMBER,
   p_quota_id           IN    NUMBER,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_sync_flag          IN    VARCHAR2 := FND_API.G_TRUE,
   x_loading_status     OUT   NOCOPY VARCHAR2
   );

-- Start of comments
-- API name 	: Update_Delta_Srp_Periods
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new record in cn_srp_periods
-- Desc 	: Procedure to create a new record in cn_srp_periods
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:
--                 p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE Update_Delta_Srp_Periods
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );

-- same as Update_Delta_Srp_Periods but without syncing
-- balances after update
-- *** CAUTION *** if you use this, make sure you sync the balances
-- afterward, so balances do not mismatch.
PROCEDURE Update_Delta_Srp_Pds_No_Sync
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );

-- Start of comments
-- API name 	: Update_Pmt_Delta_Srp_Periods
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new record in cn_srp_periods
-- Desc 	: Procedure to create a new record in cn_srp_periods
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:
--                 p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE Update_Pmt_Delta_Srp_Periods
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );


-- sync balances in cn_srp_periods for all periods
-- update the begin balance columns and update summary record
PROCEDURE Sync_Accum_Balances
  (p_salesrep_id            IN NUMBER,
   p_org_id                 IN NUMBER,
   p_credit_type_id         IN NUMBER,
   p_role_id                IN NUMBER);

-- sync balances for all periods starting with p_start_period_id
PROCEDURE Sync_Accum_Balances_Start_Pd
  (p_salesrep_id            IN NUMBER,
   p_org_id                 IN NUMBER,
   p_credit_type_id         IN NUMBER,
   p_role_id                IN NUMBER,
   p_start_period_id        IN NUMBER);

END CN_SRP_PERIODS_PVT ;
 

/
