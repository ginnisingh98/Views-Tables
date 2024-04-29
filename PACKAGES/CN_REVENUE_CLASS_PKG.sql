--------------------------------------------------------
--  DDL for Package CN_REVENUE_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_REVENUE_CLASS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntrclss.pls 120.2 2005/08/07 23:02:56 vensrini noship $ */
--
-- Package Name
-- CN_REVENUE_CLASS_PKG
-- Purpose
--  Table Handler for CN_REVENUE_CLASS
--
-- History
-- 02-feb-01	Kumar Sivasankaran	Created

--==========================================================================
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
--==========================================================================

PROCEDURE insert_row
   (x_revenue_class_id  IN OUT NOCOPY NUMBER
    ,p_name                    VARCHAR2    := NULL
    ,p_description              VARCHAR2   := NULL
    ,p_liability_account_id    NUMBER      := NULL
    ,p_expense_account_id      NUMBER      := NULL
    ,p_Created_By               NUMBER
    ,p_Creation_Date            DATE
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER
    ,p_org_id	IN		NUMBER
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--   Update Record
-- Purpose
--
-- *-------------------------------------------------------------------------*/
PROCEDURE update_row
   ( p_revenue_class_id        NUMBER     :=  fnd_api.g_miss_num
    ,p_name                    VARCHAR2    := fnd_api.g_miss_char
    ,p_description              VARCHAR2   := fnd_api.g_miss_char
    ,p_liability_account_id    NUMBER      := fnd_api.g_miss_num
    ,p_expense_account_id      NUMBER      := fnd_api.g_miss_num
    ,p_object_version_number  NUMBER      := NULL
    ,p_Last_Updated_By         NUMBER
    ,p_Last_Update_Date        DATE
    ,p_Last_Update_Login       NUMBER );

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Delete_row
-- Purpose
--*-------------------------------------------------------------------------*/
PROCEDURE Delete_row( p_revenue_class_id     NUMBER );

END CN_REVENUE_CLASS_PKG;
 

/
