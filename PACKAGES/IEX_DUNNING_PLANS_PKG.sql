--------------------------------------------------------
--  DDL for Package IEX_DUNNING_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DUNNING_PLANS_PKG" AUTHID CURRENT_USER as
/* $Header: iextdpls.pls 120.0 2005/07/09 21:53:15 ctlee noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  x_CREATION_DATE in  DATE,
  x_CREATED_BY in      NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in  NUMBER,
  x_LAST_UPDATE_LOGIN in NUMBER,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
  );

procedure LOCK_ROW (
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  -- x_CREATION_DATE in  DATE,
  -- x_CREATED_BY in      NUMBER,
  -- x_LAST_UPDATE_DATE in DATE,
  -- x_LAST_UPDATED_BY in  NUMBER,
  -- x_LAST_UPDATE_LOGIN in NUMBER,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
);

procedure UPDATE_ROW (
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  -- x_CREATION_DATE in  DATE,
  -- x_CREATED_BY in      NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in  NUMBER,
  x_LAST_UPDATE_LOGIN in NUMBER,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
);

procedure DELETE_ROW (
  x_dunning_plan_id in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2
  ) ;

procedure LOAD_ROW (
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
  );

end IEX_DUNNING_PLANS_PKG;

 

/
