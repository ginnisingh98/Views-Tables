--------------------------------------------------------
--  DDL for Package Body CN_SRP_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PERIODS_PKG" AS
/* $Header: cnsrprdb.pls 120.0 2005/06/06 17:53:12 appldev noship $ */
--
-- Package Name
-- CN_SRP_PERIODS_PKG
-- Purpose
--  Table Handler for CN_SRP_PERIODS
-- History
-- 26-Jun-99	Angela Chung	Created
-- 02-Nov-99    Angela Chung    remove proc : mark_event, raise_status

g_unclassified CONSTANT VARCHAR2(30) := 'UNCLASSIFIED';
g_classified   CONSTANT VARCHAR2(30) := 'CLASSIFIED'  ;
g_rolled_up    CONSTANT VARCHAR2(30) := 'ROLLED_UP'   ;
g_populated    CONSTANT VARCHAR2(30) := 'POPULATED'   ;
g_calculated   CONSTANT VARCHAR2(30) := 'CALCULATED'  ;

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--    Get_Previous_Balances
-- Purpose
--    To get the previous record in cn_srp_periods so can inherit the balance
--    from previous record
-- *-------------------------------------------------------------------------*/
PROCEDURE  Get_Previous_Balances
  (p_salesrep_id      IN  NUMBER,
   p_org_id           IN  NUMBER,
   p_role_id          IN  NUMBER,
   p_quota_id         IN  NUMBER,
   p_credit_type_id   IN  NUMBER,
   p_start_date       IN  DATE,
   p_period_id        IN  NUMBER,
   x_srp_prd_row      OUT NOCOPY cn_srp_periods%rowtype) IS

      l_max_end_date cn_srp_periods.end_date%TYPE;
      l_pre_period_year  cn_period_statuses.period_year%TYPE;
      l_cur_period_year  cn_period_statuses.period_year%TYPE;


BEGIN
   -- Find closest previous record
   SELECT MAX(end_date)
     INTO l_max_end_date
     FROM cn_srp_periods_all srp
     WHERE salesrep_id    = p_salesrep_id
     AND   org_id         = p_org_id
     AND   role_id        = p_role_id
     AND   quota_id       = p_quota_id
     AND   credit_type_id = p_credit_type_id
     AND   end_date < p_start_date;
   -- Get all data from previous record
   SELECT *
     INTO x_srp_prd_row
     FROM cn_srp_periods_all
     WHERE salesrep_id    = p_salesrep_id
     AND   org_id         = p_org_id
     AND   role_id        = p_role_id
     AND   quota_id       = p_quota_id
     AND   credit_type_id = p_credit_type_id
     AND   end_date = l_max_end_date;

   -- Get previous record's period_year
   SELECT period_year INTO l_pre_period_year
     FROM cn_period_statuses_all
     WHERE period_id = x_srp_prd_row.period_id
     AND org_id = p_org_id;
   -- Get current record's period_year
   SELECT period_year INTO l_cur_period_year
     FROM cn_period_statuses_all
     WHERE period_id = p_period_id
     AND org_id = p_org_id;
   -- Check if changing the period_year, if so, reset the value, do not
   -- carry over
   IF l_pre_period_year <> l_cur_period_year THEN
      x_srp_prd_row := NULL;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_srp_prd_row := NULL;

END  Get_Previous_Balances;

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
-- Note : Will not inherit previous record's balance for balance account
--        5,8,27,30,32
-- *-------------------------------------------------------------------------*/

PROCEDURE INSERT_ROW
  (X_SRP_PERIOD_ID IN OUT NOCOPY NUMBER,
   X_SALESREP_ID IN NUMBER,
   x_org_id IN NUMBER,
   X_PERIOD_ID IN NUMBER,
   X_START_DATE IN DATE,
   X_END_DATE   IN DATE,
   X_SRP_PLAN_ASSIGN_ID IN NUMBER := NULL,
   X_CREDIT_TYPE_ID IN NUMBER,
   X_ROLE_ID IN NUMBER,
   X_QUOTA_ID IN NUMBER,
   X_PAY_GROUP_ID IN NUMBER,
   X_BALANCE1_DTD IN NUMBER := 0,
   X_BALANCE1_CTD IN NUMBER := 0,
   X_BALANCE1_BBD IN NUMBER := 0,
   X_BALANCE1_BBC IN NUMBER := 0,
   X_BALANCE2_DTD IN NUMBER := 0,
   X_BALANCE2_CTD IN NUMBER := 0,
   X_BALANCE2_BBD IN NUMBER := 0,
   X_BALANCE2_BBC IN NUMBER := 0,
   X_BALANCE3_DTD IN NUMBER := 0,
   X_BALANCE3_CTD IN NUMBER := 0,
   X_BALANCE3_BBD IN NUMBER := 0,
   X_BALANCE3_BBC IN NUMBER := 0,
   X_BALANCE4_DTD IN NUMBER := 0,
   X_BALANCE4_CTD IN NUMBER := 0,
   X_BALANCE4_BBD IN NUMBER := 0,
   X_BALANCE4_BBC IN NUMBER := 0,
   X_BALANCE5_DTD IN NUMBER := 0,
   X_BALANCE5_CTD IN NUMBER := 0,
   X_BALANCE5_BBD IN NUMBER := 0,
   X_BALANCE5_BBC IN NUMBER := 0,
   X_BALANCE6_DTD IN NUMBER := 0,
   X_BALANCE6_CTD IN NUMBER := 0,
   X_BALANCE6_BBD IN NUMBER := 0,
   X_BALANCE6_BBC IN NUMBER := 0,
   X_BALANCE7_DTD IN NUMBER := 0,
  X_BALANCE7_CTD IN NUMBER := 0,
  X_BALANCE7_BBD IN NUMBER := 0,
  X_BALANCE7_BBC IN NUMBER := 0,
  X_BALANCE8_DTD IN NUMBER := 0,
  X_BALANCE8_CTD IN NUMBER := 0,
  X_BALANCE8_BBD IN NUMBER := 0,
  X_BALANCE8_BBC IN NUMBER := 0,
  X_BALANCE9_DTD IN NUMBER := 0,
  X_BALANCE9_CTD IN NUMBER := 0,
  X_BALANCE9_BBD IN NUMBER := 0,
  X_BALANCE9_BBC IN NUMBER := 0,
  X_BALANCE10_DTD IN NUMBER := 0,
  X_BALANCE10_CTD IN NUMBER := 0,
  X_BALANCE10_BBD IN NUMBER := 0,
  X_BALANCE10_BBC IN NUMBER := 0,
  X_BALANCE11_DTD IN NUMBER := 0,
  X_BALANCE11_CTD IN NUMBER := 0,
  X_BALANCE11_BBD IN NUMBER := 0,
  X_BALANCE11_BBC IN NUMBER := 0,
  X_BALANCE12_DTD IN NUMBER := 0,
  X_BALANCE12_CTD IN NUMBER := 0,
  X_BALANCE12_BBD IN NUMBER := 0,
  X_BALANCE12_BBC IN NUMBER := 0,
  X_BALANCE13_DTD IN NUMBER := 0,
  X_BALANCE13_CTD IN NUMBER := 0,
  X_BALANCE13_BBD IN NUMBER := 0,
  X_BALANCE13_BBC IN NUMBER := 0,
  X_BALANCE14_DTD IN NUMBER := 0,
  X_BALANCE14_CTD IN NUMBER := 0,
  X_BALANCE14_BBD IN NUMBER := 0,
  X_BALANCE14_BBC IN NUMBER := 0,
  X_BALANCE15_DTD IN NUMBER := 0,
  X_BALANCE15_CTD IN NUMBER := 0,
  X_BALANCE15_BBD IN NUMBER := 0,
  X_BALANCE15_BBC IN NUMBER := 0,
  X_BALANCE16_DTD IN NUMBER := 0,
  X_BALANCE16_CTD IN NUMBER := 0,
  X_BALANCE16_BBD IN NUMBER := 0,
  X_BALANCE16_BBC IN NUMBER := 0,
  X_BALANCE17_DTD IN NUMBER := 0,
  X_BALANCE17_CTD IN NUMBER := 0,
  X_BALANCE17_BBD IN NUMBER := 0,
  X_BALANCE17_BBC IN NUMBER := 0,
  X_BALANCE18_DTD IN NUMBER := 0,
  X_BALANCE18_CTD IN NUMBER := 0,
  X_BALANCE18_BBD IN NUMBER := 0,
  X_BALANCE18_BBC IN NUMBER := 0,
  X_BALANCE19_DTD IN NUMBER := 0,
  X_BALANCE19_CTD IN NUMBER := 0,
  X_BALANCE19_BBD IN NUMBER := 0,
  X_BALANCE19_BBC IN NUMBER := 0,
  X_BALANCE20_DTD IN NUMBER := 0,
  X_BALANCE20_CTD IN NUMBER := 0,
  X_BALANCE20_BBD IN NUMBER := 0,
  X_BALANCE20_BBC IN NUMBER := 0,
  X_BALANCE21_DTD IN NUMBER := 0,
  X_BALANCE21_CTD IN NUMBER := 0,
  X_BALANCE21_BBD IN NUMBER := 0,
  X_BALANCE21_BBC IN NUMBER := 0,
  X_BALANCE22_DTD IN NUMBER := 0,
  X_BALANCE22_CTD IN NUMBER := 0,
  X_BALANCE22_BBD IN NUMBER := 0,
  X_BALANCE22_BBC IN NUMBER := 0,
  X_BALANCE23_DTD IN NUMBER := 0,
  X_BALANCE23_CTD IN NUMBER := 0,
  X_BALANCE23_BBD IN NUMBER := 0,
  X_BALANCE23_BBC IN NUMBER := 0,
  X_BALANCE24_DTD IN NUMBER := 0,
  X_BALANCE24_CTD IN NUMBER := 0,
  X_BALANCE24_BBD IN NUMBER := 0,
  X_BALANCE24_BBC IN NUMBER := 0,
  X_BALANCE25_DTD IN NUMBER := 0,
  X_BALANCE25_CTD IN NUMBER := 0,
  X_BALANCE25_BBD IN NUMBER := 0,
  X_BALANCE25_BBC IN NUMBER := 0,
  X_BALANCE26_DTD IN NUMBER := 0,
  X_BALANCE26_CTD IN NUMBER := 0,
  X_BALANCE26_BBD IN NUMBER := 0,
  X_BALANCE26_BBC IN NUMBER := 0,
  X_BALANCE27_DTD IN NUMBER := 0,
  X_BALANCE27_CTD IN NUMBER := 0,
  X_BALANCE27_BBD IN NUMBER := 0,
  X_BALANCE27_BBC IN NUMBER := 0,
  X_BALANCE28_DTD IN NUMBER := 0,
  X_BALANCE28_CTD IN NUMBER := 0,
  X_BALANCE28_BBD IN NUMBER := 0,
  X_BALANCE28_BBC IN NUMBER := 0,
  X_BALANCE29_DTD IN NUMBER := 0,
  X_BALANCE29_CTD IN NUMBER := 0,
  X_BALANCE29_BBD IN NUMBER := 0,
  X_BALANCE29_BBC IN NUMBER := 0,
  X_BALANCE30_DTD IN NUMBER := 0,
  X_BALANCE30_CTD IN NUMBER := 0,
  X_BALANCE30_BBD IN NUMBER := 0,
  X_BALANCE30_BBC IN NUMBER := 0,
  X_BALANCE31_DTD IN NUMBER := 0,
  X_BALANCE31_CTD IN NUMBER := 0,
  X_BALANCE31_BBD IN NUMBER := 0,
  X_BALANCE31_BBC IN NUMBER := 0,
  X_BALANCE32_DTD IN NUMBER := 0,
  X_BALANCE32_CTD IN NUMBER := 0,
  X_BALANCE32_BBD IN NUMBER := 0,
  X_BALANCE32_BBC IN NUMBER := 0,
  X_BALANCE33_DTD IN NUMBER := 0,
  X_BALANCE33_CTD IN NUMBER := 0,
  X_BALANCE33_BBD IN NUMBER := 0,
  X_BALANCE33_BBC IN NUMBER := 0,
  X_CONSISTENCY_FLAG IN VARCHAR2 := 'Y',
  X_PAID_FLAG IN  VARCHAR2 := 'N',
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
  ) IS
     l_dummy NUMBER;
     l_srp_prd_row cn_srp_periods%ROWTYPE := Null;

BEGIN
   SELECT cn_srp_periods_s.NEXTVAL
     INTO   X_SRP_PERIOD_ID
     FROM   dual;

   INSERT INTO cn_srp_periods_all
     (SRP_PERIOD_ID ,
      SALESREP_ID ,
      org_id,
      PERIOD_ID ,
      START_DATE,
      END_DATE,
      SRP_PLAN_ASSIGN_ID ,
      CREDIT_TYPE_ID ,
      ROLE_ID ,
      QUOTA_ID,
      PAY_GROUP_ID ,
      BALANCE1_DTD ,
      BALANCE1_CTD ,
      BALANCE1_BBD ,
      BALANCE1_BBC ,
      BALANCE2_DTD ,
      BALANCE2_CTD ,
      BALANCE2_BBD ,
      BALANCE2_BBC ,
      BALANCE3_DTD ,
      BALANCE3_CTD ,
      BALANCE3_BBD ,
      BALANCE3_BBC ,
      BALANCE4_DTD ,
      BALANCE4_CTD ,
      BALANCE4_BBD ,
      BALANCE4_BBC ,
      BALANCE5_DTD ,
      BALANCE5_CTD ,
      BALANCE5_BBD ,
      BALANCE5_BBC ,
      BALANCE6_DTD ,
      BALANCE6_CTD ,
      BALANCE6_BBD ,
      BALANCE6_BBC ,
      BALANCE7_DTD ,
      BALANCE7_CTD ,
      BALANCE7_BBD ,
      BALANCE7_BBC ,
      BALANCE8_DTD ,
      BALANCE8_CTD ,
      BALANCE8_BBD ,
      BALANCE8_BBC ,
      BALANCE9_DTD ,
      BALANCE9_CTD ,
      BALANCE9_BBD ,
      BALANCE9_BBC ,
      BALANCE10_DTD ,
      BALANCE10_CTD ,
      BALANCE10_BBD ,
      BALANCE10_BBC ,
      BALANCE11_DTD ,
      BALANCE11_CTD ,
     BALANCE11_BBD ,
     BALANCE11_BBC ,
     BALANCE12_DTD ,
     BALANCE12_CTD ,
     BALANCE12_BBD ,
     BALANCE12_BBC ,
     BALANCE13_DTD ,
     BALANCE13_CTD ,
     BALANCE13_BBD ,
     BALANCE13_BBC ,
     BALANCE14_DTD ,
     BALANCE14_CTD ,
     BALANCE14_BBD ,
     BALANCE14_BBC ,
     BALANCE15_DTD ,
     BALANCE15_CTD ,
     BALANCE15_BBD ,
     BALANCE15_BBC ,
     BALANCE16_DTD ,
     BALANCE16_CTD ,
     BALANCE16_BBD ,
     BALANCE16_BBC ,
     BALANCE17_DTD ,
     BALANCE17_CTD ,
     BALANCE17_BBD ,
     BALANCE17_BBC ,
     BALANCE18_DTD ,
     BALANCE18_CTD ,
     BALANCE18_BBD ,
     BALANCE18_BBC ,
     BALANCE19_DTD ,
     BALANCE19_CTD ,
     BALANCE19_BBD ,
     BALANCE19_BBC ,
     BALANCE20_DTD ,
     BALANCE20_CTD ,
     BALANCE20_BBD ,
     BALANCE20_BBC ,
     BALANCE21_DTD ,
     BALANCE21_CTD ,
     BALANCE21_BBD ,
     BALANCE21_BBC ,
     BALANCE22_DTD ,
     BALANCE22_CTD ,
     BALANCE22_BBD ,
     BALANCE22_BBC ,
     BALANCE23_DTD ,
     BALANCE23_CTD ,
     BALANCE23_BBD ,
     BALANCE23_BBC ,
     BALANCE24_DTD ,
     BALANCE24_CTD ,
     BALANCE24_BBD ,
     BALANCE24_BBC ,
     BALANCE25_DTD ,
     BALANCE25_CTD ,
     BALANCE25_BBD ,
     BALANCE25_BBC ,
     BALANCE26_DTD ,
     BALANCE26_CTD ,
     BALANCE26_BBD ,
     BALANCE26_BBC ,
     BALANCE27_DTD ,
     BALANCE27_CTD ,
     BALANCE27_BBD ,
     BALANCE27_BBC ,
     BALANCE28_DTD ,
     BALANCE28_CTD ,
     BALANCE28_BBD ,
     BALANCE28_BBC ,
     BALANCE29_DTD ,
     BALANCE29_CTD ,
     BALANCE29_BBD ,
     BALANCE29_BBC ,
     BALANCE30_DTD ,
     BALANCE30_CTD ,
     BALANCE30_BBD ,
     BALANCE30_BBC ,
     BALANCE31_DTD ,
     BALANCE31_CTD ,
     BALANCE31_BBD ,
     BALANCE31_BBC ,
     BALANCE32_DTD ,
     BALANCE32_CTD ,
     BALANCE32_BBD ,
     BALANCE32_BBC ,
     BALANCE33_DTD ,
     BALANCE33_CTD ,
     BALANCE33_BBD ,
     BALANCE33_BBC ,
     CONSISTENCY_FLAG ,
     PAID_FLAG ,
     CREATION_DATE ,
     CREATED_BY ,
     LAST_UPDATE_DATE ,
     LAST_UPDATED_BY ,
     LAST_UPDATE_LOGIN
     ) VALUES
     (x_srp_period_id ,
      x_salesrep_id ,
      x_org_id,
      x_period_id ,
      x_start_date ,
      x_end_date ,
      x_srp_plan_assign_id ,
      x_credit_type_id ,
      x_role_id ,
      x_quota_id ,
      x_pay_group_id ,
      Nvl(x_balance1_dtd,0) ,
      Nvl(x_balance1_ctd,0) ,
      Nvl(x_balance1_bbd,0) ,
      Nvl(x_balance1_bbc,0) ,
      Nvl(x_balance2_dtd,0) ,
      Nvl(x_balance2_ctd,0) ,
      Nvl(x_balance2_bbd,0) ,
      Nvl(x_balance2_bbc,0) ,
      Nvl(x_balance3_dtd,0) ,
      Nvl(x_balance3_ctd,0) ,
      Nvl(x_balance3_bbd,0) ,
      Nvl(x_balance3_bbc,0) ,
      Nvl(x_balance4_dtd,0) ,
      Nvl(x_balance4_ctd,0) ,
      Nvl(x_balance4_bbd,0) ,
      Nvl(x_balance4_bbc,0) ,
      Nvl(x_balance5_dtd,0) ,
      Nvl(x_balance5_ctd,0) ,
      Nvl(x_balance5_bbd,0) ,
      Nvl(x_balance5_bbc,0) ,

     Nvl(x_balance6_dtd,0) ,  -- not used, but leave as is
     Nvl(x_balance6_ctd,0) ,
     Nvl(x_balance6_bbd,0) ,
     Nvl(x_balance6_bbc,0) ,
     Nvl(x_balance7_dtd,0) ,
     Nvl(x_balance7_ctd,0) ,
     Nvl(x_balance7_bbd,0) ,
     Nvl(x_balance7_bbc,0) ,
     Nvl(x_balance8_dtd,0) ,
     Nvl(x_balance8_ctd,0) ,
     Nvl(x_balance8_bbd,0) ,
     Nvl(x_balance8_bbc,0) ,
     Nvl(x_balance9_dtd,0) ,
     Nvl(x_balance9_ctd,0) ,
     Nvl(x_balance9_bbd,0) ,
     Nvl(x_balance9_bbc,0) ,
     Nvl(x_balance10_dtd,0) ,
     Nvl(x_balance10_ctd,0) ,
     Nvl(x_balance10_bbd,0) ,
     Nvl(x_balance10_bbc,0) ,
     Nvl(x_balance11_dtd,0) ,
     Nvl(x_balance11_ctd,0) ,
     Nvl(x_balance11_bbd,0) ,
     Nvl(x_balance11_bbc,0) ,
     Nvl(x_balance12_dtd,0) ,
     Nvl(x_balance12_ctd,0) ,
     Nvl(x_balance12_bbd,0) ,
     Nvl(x_balance12_bbc,0) ,
     Nvl(x_balance13_dtd,0) ,
     Nvl(x_balance13_ctd,0) ,
     Nvl(x_balance13_bbd,0) ,
     Nvl(x_balance13_bbc,0) ,
     Nvl(x_balance14_dtd,0) ,
     Nvl(x_balance14_ctd,0) ,
     Nvl(x_balance14_bbd,0) ,
     Nvl(x_balance14_bbc,0) ,
     Nvl(x_balance15_dtd,0) ,
     Nvl(x_balance15_ctd,0) ,
     Nvl(x_balance15_bbd,0) ,
     Nvl(x_balance15_bbc,0) ,
     Nvl(x_balance16_dtd,0) ,
     Nvl(x_balance16_ctd,0) ,
     Nvl(x_balance16_bbd,0) ,
     Nvl(x_balance16_bbc,0) ,
     Nvl(x_balance17_dtd,0) ,
     Nvl(x_balance17_ctd,0) ,
     Nvl(x_balance17_bbd,0) ,
     Nvl(x_balance17_bbc,0) ,
     Nvl(x_balance18_dtd,0) ,
     Nvl(x_balance18_ctd,0) ,
     Nvl(x_balance18_bbd,0) ,
     Nvl(x_balance18_bbc,0) ,
     Nvl(x_balance19_dtd,0) ,
     Nvl(x_balance19_ctd,0) ,
     Nvl(x_balance19_bbd,0) ,
     Nvl(x_balance19_bbc,0) ,
     Nvl(x_balance20_dtd,0) ,
     Nvl(x_balance20_ctd,0) ,
     Nvl(x_balance20_bbd,0) ,
     Nvl(x_balance20_bbc,0) ,
     Nvl(x_balance21_dtd,0) ,
     Nvl(x_balance21_ctd,0) ,
     Nvl(x_balance21_bbd,0) ,
     Nvl(x_balance21_bbc,0) ,
     Nvl(x_balance22_dtd,0) ,
     Nvl(x_balance22_ctd,0) ,
     Nvl(x_balance22_bbd,0) ,
     Nvl(x_balance22_bbc,0) ,
     Nvl(x_balance23_dtd,0) ,
     Nvl(x_balance23_ctd,0) ,
     Nvl(x_balance23_bbd,0) ,
     Nvl(x_balance23_bbc,0) ,
     Nvl(x_balance24_dtd,0) ,
     Nvl(x_balance24_ctd,0) ,
     Nvl(x_balance24_bbd,0) ,
     Nvl(x_balance24_bbc,0) ,
     Nvl(x_balance25_dtd,0) ,
     Nvl(x_balance25_ctd,0) ,
     Nvl(x_balance25_bbd,0) ,
     Nvl(x_balance25_bbc,0) ,
     Nvl(x_balance26_dtd,0) ,
     Nvl(x_balance26_ctd,0) ,
     Nvl(x_balance26_bbd,0) ,
     Nvl(x_balance26_bbc,0) ,
     Nvl(x_balance27_dtd,0) ,
     Nvl(x_balance27_ctd,0) ,
     Nvl(x_balance27_bbd,0) ,
     Nvl(x_balance27_bbc,0) ,
     Nvl(x_balance28_dtd,0) ,
     Nvl(x_balance28_ctd,0) ,
     Nvl(x_balance28_bbd,0) ,
     Nvl(x_balance28_bbc,0) ,
     Nvl(x_balance29_dtd,0) ,
     Nvl(x_balance29_ctd,0) ,
     Nvl(x_balance29_bbd,0) ,
     Nvl(x_balance29_bbc,0) ,
     Nvl(x_balance30_dtd,0) ,
     Nvl(x_balance30_ctd,0) ,
     Nvl(x_balance30_bbd,0) ,
     Nvl(x_balance30_bbc,0) ,
     Nvl(x_balance31_dtd,0) ,
     Nvl(x_balance31_ctd,0) ,
     Nvl(x_balance31_bbd,0) ,
     Nvl(x_balance31_bbc,0) ,
     Nvl(x_balance32_dtd,0) ,
     Nvl(x_balance32_ctd,0) ,
     Nvl(x_balance32_bbd,0) ,
     Nvl(x_balance32_bbc,0) ,
     Nvl(x_balance33_dtd,0) ,
     Nvl(x_balance33_ctd,0) ,
     Nvl(x_balance33_bbd,0) ,
     Nvl(x_balance33_bbc,0) ,
     x_consistency_flag ,
     x_paid_flag ,
     x_creation_date ,
     x_created_by ,
     x_last_update_date ,
     x_last_updated_by ,
     x_last_update_login
     );

   SELECT  1 INTO l_dummy  FROM  CN_SRP_PERIODS_all
       WHERE  SRP_PERIOD_ID = x_srp_period_id;

END Insert_Row;

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Delete_row
-- Purpose
--    Delete the Srp Payment Plan Assign
-- *-------------------------------------------------------------------------*/
PROCEDURE Delete_row( x_srp_period_id     NUMBER ) IS

BEGIN

   DELETE FROM cn_srp_periods_all
     WHERE  srp_period_id = x_srp_period_id ;
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_row;

END CN_SRP_PERIODS_PKG;

/
