--------------------------------------------------------
--  DDL for Package FII_LOB_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_LOB_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
/*$Header: FIILOBAS.pls 115.1 2003/01/11 00:30:40 ilavenil noship $*/
   PROCEDURE insert_row(x_rowid IN OUT NOCOPY VARCHAR2,
                        x_line_of_business IN VARCHAR2 DEFAULT NULL,
                        x_company_cost_center_org_id IN NUMBER DEFAULT NULL,
                        x_last_update_date IN DATE DEFAULT NULL,
                        x_last_updated_by IN NUMBER DEFAULT NULL,
                        x_created_by IN NUMBER DEFAULT NULL,
                        x_creation_date IN DATE DEFAULT NULL,
                        x_last_update_login IN NUMBER DEFAULT NULL);
   PROCEDURE update_row(x_rowid IN VARCHAR2,
                        x_line_of_business IN VARCHAR2 DEFAULT NULL,
                        x_company_cost_center_org_id IN NUMBER DEFAULT NULL,
                        x_last_update_date IN DATE DEFAULT NULL,
                        x_last_updated_by IN NUMBER DEFAULT NULL,
                        x_last_update_login IN NUMBER DEFAULT NULL);
   PROCEDURE delete_row(x_rowid IN VARCHAR2,
                        x_line_of_business IN VARCHAR2);
   PROCEDURE lock_row(x_rowid IN VARCHAR2,
                      x_line_of_business IN VARCHAR2,
                      x_company_cost_center_org_id IN NUMBER);
END fii_lob_assignments_pkg;

 

/
