--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_OUTPUT_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_OUTPUT_TAX" AS
/* $Header: PAXPOTXB.pls 120.8 2006/03/22 14:21:38 sbsivara noship $ */

  PROCEDURE get_tax_code
      (  P_project_id               IN    NUMBER,
         P_customer_id              IN    NUMBER DEFAULT NULL,
         P_bill_to_site_use_id      IN    NUMBER DEFAULT NULL,
         P_ship_to_site_use_id      IN    NUMBER DEFAULT NULL,
         P_set_of_books_id          IN    NUMBER DEFAULT NULL,
         P_expenditure_item_id      IN    NUMBER DEFAULT NULL,
         P_event_id                 IN    NUMBER DEFAULT NULL,
         P_line_type                IN    VARCHAR2  DEFAULT NULL,
         P_request_id               IN    NUMBER DEFAULT NULL,
         P_user_id                  IN    NUMBER DEFAULT NULL,
         X_output_tax_code          OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
  IS
  BEGIN

    -- Set default Tax id as Null.

    X_output_tax_code := NULL;

  END get_tax_code;

END pa_client_extn_output_tax;

/
