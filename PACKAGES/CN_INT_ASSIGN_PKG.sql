--------------------------------------------------------
--  DDL for Package CN_INT_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_INT_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: cntintas.pls 120.2 2005/09/19 12:04:45 ymao noship $ */
--
-- Package Name
--   CN_INT_ASSIGN_PKG
-- Purpose
--   Table handler for CN_CAL_PER_INT_TYPES
-- Form
--   CNINTTP
-- Block
--   INTERVAL_ASSIGNS
--
-- History
--   16-Aug-99  Yonghong Mao  Created

--
-- global variables that represent missing values
--
g_last_update_date           DATE   := Sysdate;
g_last_updated_by            NUMBER := fnd_global.user_id;
g_creation_date              DATE   := Sysdate;
g_created_by                 NUMBER := fnd_global.user_id;
g_last_update_login          NUMBER := fnd_global.login_id;
--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  insert_row
-- Purpose
--  main insert procedure
-- *--------------------------------------------------------------------------*/
PROCEDURE insert_row
  ( x_cal_per_int_type_id IN OUT  NOCOPY cn_cal_per_int_types.cal_per_int_type_id%TYPE,
    x_org_id                      cn_cal_per_int_types.org_id%TYPE,
    x_interval_type_id            cn_cal_per_int_types.interval_type_id%TYPE,
    x_cal_period_id               cn_cal_per_int_types.cal_period_id%TYPE,
    x_interval_number             cn_cal_per_int_types.interval_number%TYPE,
    x_last_update_date            cn_cal_per_int_types.last_update_date%TYPE,
    x_last_updated_by             cn_cal_per_int_types.last_updated_by%TYPE,
    x_creation_date               cn_cal_per_int_types.creation_date%TYPE,
    x_created_by                  cn_cal_per_int_types.created_by%TYPE,
    x_last_update_login           cn_cal_per_int_types.last_update_login%TYPE
    );

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  update_row
-- Purpose
--  Populate the table cn_cal_per_int_types after creating an interval type
-- *--------------------------------------------------------------------------*/
PROCEDURE update_row
  ( x_cal_per_int_type_id     cn_cal_per_int_types.cal_per_int_type_id%TYPE,
    x_interval_number         cn_cal_per_int_types.interval_number%TYPE,
    x_last_update_date        cn_cal_per_int_types.last_update_date%TYPE,
    x_last_updated_by         cn_cal_per_int_types.last_updated_by%TYPE,
    x_last_update_login       cn_cal_per_int_types.last_update_login%TYPE
    );

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  lock_row
-- Purpose
--  lock DB row after form record is changed
-- *--------------------------------------------------------------------------*/
PROCEDURE lock_row
  ( x_cal_per_int_type_id     cn_cal_per_int_types.cal_per_int_type_id%TYPE,
    x_cal_period_id           cn_cal_per_int_types.cal_period_id%TYPE,
    x_interval_type_id        cn_cal_per_int_types.interval_type_id%TYPE,
    x_interval_number         cn_cal_per_int_types.interval_number%TYPE
    );


END CN_INT_ASSIGN_PKG;

 

/
