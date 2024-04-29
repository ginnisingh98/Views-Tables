--------------------------------------------------------
--  DDL for Package QLTVCREB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTVCREB" AUTHID CURRENT_USER AS
/* $Header: qltvcreb.pls 120.1.12010000.1 2008/07/25 09:23:18 appldev ship $ */


 PROCEDURE global_view
          (x_view_name IN VARCHAR2);

 PROCEDURE plan_view
           (x_view_name IN VARCHAR2,
            x_old_view_name IN VARCHAR2,
            x_plan_id IN NUMBER);

 PROCEDURE import_plan_view
           (x_view_name IN VARCHAR2,
            x_old_view_name IN VARCHAR2,
            x_plan_id IN NUMBER);

END QLTVCREB;

/
