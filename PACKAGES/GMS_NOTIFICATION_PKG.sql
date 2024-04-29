--------------------------------------------------------
--  DDL for Package GMS_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_NOTIFICATION_PKG" AUTHID CURRENT_USER AS
--$Header: gmsawnos.pls 115.8 2003/03/06 05:34:03 gnema ship $

  PROCEDURE Insert_Row (X_Rowid IN OUT NOCOPY      VARCHAR2,
                       X_award_id in       NUMBER,
                       X_event_type        VARCHAR2,
                       X_user_id           NUMBER);

  PROCEDURE Lock_Row (X_Rowid             VARCHAR2, --bug 2813856, removed IN OUT NOCOPY
                       X_award_id          NUMBER,
                       X_event_type        VARCHAR2,
                       X_user_id           NUMBER);

  PROCEDURE Delete_Row(X_Rowid             VARCHAR2);

  PROCEDURE Crt_default_person_events(x_err_code in out NOCOPY NUMBER,
  				      x_err_stage in out NOCOPY VARCHAR2,
  				      p_award_id INTEGER,
                                          p_person_id INTEGER);

  PROCEDURE Crt_default_report_events(x_err_code in out NOCOPY NUMBER,
  				      x_err_stage in out NOCOPY VARCHAR2,
  				      p_award_id INTEGER,
                                      p_report_template_id INTEGER);

  PROCEDURE Del_default_person_events(x_err_code in out NOCOPY NUMBER,
  				      x_err_stage in out NOCOPY VARCHAR2,
  				      p_award_id INTEGER,
                                      p_person_id INTEGER);

  PROCEDURE Del_default_report_events(x_err_code in out NOCOPY NUMBER,
  				      x_err_stage in out NOCOPY VARCHAR2,
  				      p_award_id INTEGER,
                                      p_report_template_id INTEGER);

END GMS_NOTIFICATION_PKG;

 

/
