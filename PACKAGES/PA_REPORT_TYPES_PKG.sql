--------------------------------------------------------
--  DDL for Package PA_REPORT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REPORT_TYPES_PKG" AUTHID CURRENT_USER AS
--$Header: PARTYPHS.pls 120.1 2005/08/19 17:02:27 mwasowic noship $


procedure INSERT_ROW (
  P_NAME                    IN VARCHAR2,
  P_PAGE_ID                 IN NUMBER,
  P_OVERRIDE_PAGE_LAYOUT    IN VARCHAR2,
  P_DESCRIPTION             IN VARCHAR2,
  P_GENERATION_METHOD       IN VARCHAR2,
  P_START_DATE_ACTIVE       IN DATE,
  P_END_DATE_ACTIVE         IN DATE,
  p_LAST_UPDATED_BY         IN NUMBER,
  p_CREATED_BY              IN NUMBER,
  p_LAST_UPDATE_LOGIN       IN NUMBER,
  x_report_Type_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
);

procedure UPDATE_ROW (
  P_REPORT_TYPE_ID          IN NUMBER,
  P_NAME                    IN VARCHAR2,
  P_PAGE_ID                 IN NUMBER,
  P_OVERRIDE_PAGE_LAYOUT    IN VARCHAR2,
  P_DESCRIPTION             IN VARCHAR2,
  P_GENERATION_METHOD       IN VARCHAR2,
  P_START_DATE_ACTIVE       IN DATE,
  P_END_DATE_ACTIVE         IN DATE,
  P_RECORD_VERSION_NUMBER   IN NUMBER,
  p_LAST_UPDATED_BY         IN NUMBER,
  p_LAST_UPDATE_LOGIN       IN NUMBER,
  x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure DELETE_ROW (
		      P_REPORT_TYPE_ID in NUMBER,
                      P_RECORD_VERSION_NUMBER in NUMBER,
		      x_return_status      OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END  PA_REPORT_TYPES_PKG;

 

/
