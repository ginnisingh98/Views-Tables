--------------------------------------------------------
--  DDL for Package CN_SRP_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: cnsrprds.pls 120.0 2005/06/06 17:35:21 appldev noship $ */
--
-- Package Name
-- CN_SRP_PERIODS_PKG
-- Purpose
--  Table Handler for CN_SRP_PERIODS
-- History
-- 26-Jun-99	Angela Chung	Created
-- 02-Nov-99    Angela Chung    remove proc : mark_event, raise_status
--

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
-- *-------------------------------------------------------------------------*/

PROCEDURE INSERT_ROW
  (X_SRP_PERIOD_ID IN OUT NOCOPY NUMBER,
   X_SALESREP_ID IN NUMBER,
   x_org_id      IN NUMBER,
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
);

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Delete_row
-- Purpose
--    Delete the Srp Payment Plan Assign
-- *-------------------------------------------------------------------------*/

PROCEDURE DELETE_ROW
  (X_SRP_PERIOD_ID IN NUMBER);

END CN_SRP_PERIODS_PKG;
 

/