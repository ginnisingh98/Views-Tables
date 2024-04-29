--------------------------------------------------------
--  DDL for Package CN_WKSHT_BONUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_WKSHT_BONUS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntwbons.pls 115.4 2001/10/29 17:17:24 pkm ship    $ */
--
-- Package Name
-- CN_WKSHT_BONUS_PKG
-- Purpose
--  Table Handler for CN_WORKSHEET_BONUSES
--  FORM 	CNSBPS
--  BLOCK	BONUSES
--
-- History
-- 26-May-99   Renu Chintalapati	Created

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
-- *-------------------------------------------------------------------------*/
PROCEDURE insert_row
   (x_payrun_id                 IN NUMBER
    ,x_salesrep_id              IN NUMBER
    ,x_quota_id                 IN NUMBER
    ,x_comp_plan_id             IN NUMBER
    ,x_amount                   IN NUMBER
    ,x_srp_plan_assign_id       IN NUMBER
    ,x_payment_worksheet_id     IN NUMBER
    ,x_created_by               IN NUMBER
    ,x_creation_date            IN DATE
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--	Lock_row
-- Purpose
--    Lock db row after form record is changed
-- Notes
--    Only called from the form
-- *-------------------------------------------------------------------------*/
PROCEDURE lock_row
  ( x_payment_worksheet_id     IN NUMBER
    ,x_quota_id                IN NUMBER
    ,x_comp_plan_id            IN NUMBER
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--   Update Record
-- Purpose
--   To Update the Srp Payment Plan Assign
--
-- *-------------------------------------------------------------------------*/
PROCEDURE update_row (
		      x_payment_worksheet_id      NUMBER
		      ,x_quota_id                 NUMBER
		      ,x_comp_plan_id             NUMBER
		      ,x_amount                   NUMBER   	:= fnd_api.g_miss_num
		      ,x_last_updated_by          NUMBER
		      ,x_last_update_login       NUMBER
		      ,x_last_update_date         DATE
		      );

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Delete_row
-- Purpose
--    Delete the Srp Payment Plan Assign
--*-------------------------------------------------------------------------*/
PROCEDURE Delete_row( x_payment_worksheet_id     NUMBER );

END CN_WKSHT_BONUS_PKG;

 

/
