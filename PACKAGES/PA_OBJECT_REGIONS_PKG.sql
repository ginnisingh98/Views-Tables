--------------------------------------------------------
--  DDL for Package PA_OBJECT_REGIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OBJECT_REGIONS_PKG" AUTHID CURRENT_USER AS
--$Header: PAAPORHS.pls 120.1 2005/07/01 16:58:44 appldev noship $

procedure INSERT_ROW (

  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PLACEHOLDER_REG_CODE in VARCHAR2,
  P_REPLACEMENT_REG_CODE in VARCHAR2,
  P_CREATION_DATE        in DATE,
  P_CREATED_BY           in NUMBER,
  P_LAST_UPDATE_DATE     in DATE,
  P_LAST_UPDATED_BY      in NUMBER,
  P_LAST_UPDATE_LOGIN    in NUMBER
);

procedure UPDATE_ROW (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PLACEHOLDER_REG_CODE in VARCHAR2,
  P_REPLACEMENT_REG_CODE in VARCHAR2,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_LAST_UPDATE_DATE     in DATE,
  P_LAST_UPDATED_BY      in NUMBER,
  P_LAST_UPDATE_LOGIN    in NUMBER
);

procedure DELETE_ROW (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PLACEHOLDER_REG_CODE in VARCHAR2
  --x_return_status               OUT    VARCHAR2,
  --x_msg_count                   OUT    NUMBER,
  --x_msg_data                    OUT    VARCHAR2
				      ) ;
END  PA_OBJECT_REGIONS_PKG;

 

/
