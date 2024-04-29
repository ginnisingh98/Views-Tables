--------------------------------------------------------
--  DDL for Package Body PA_CC_AP_INV_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_AP_INV_CLIENT_EXTN" 
--  $Header: PACCINPB.pls 120.2 2005/08/10 14:10:34 eyefimov noship $
AS


PROCEDURE override_exp_type_exp_org (
          p_internal_billing_type         IN  VARCHAR2,
          p_project_id                    IN   NUMBER,
          p_receiver_project_id           IN  NUMBER,
          p_receiver_task_id              IN  NUMBER,
          p_draft_invoice_number          IN  NUMBER,
          p_draft_invoice_line_num        IN  NUMBER,
          p_invoice_date                  IN  DATE,
          p_ra_invoice_number             IN  VARCHAR,
          p_provider_org_id               IN  NUMBER,
          p_receiver_org_id               IN  NUMBER,
          p_cc_ar_invoice_id              IN  NUMBER,
          p_cc_ar_invoice_line_num        IN  NUMBER,
          p_project_customer_id           IN  NUMBER,
          p_vendor_id                     IN  NUMBER,
          p_vendor_site_id                IN  NUMBER,
          p_expenditure_type              IN  VARCHAR2,
          p_expenditure_organization_id   IN  NUMBER,
          x_expenditure_type              OUT NOCOPY VARCHAR2,
          x_expenditure_organization_id   OUT NOCOPY NUMBER,
          x_status                        IN OUT NOCOPY NUMBER,
          x_Error_Stage                   IN OUT NOCOPY VARCHAR2,
          X_Error_Code                    IN OUT NOCOPY NUMBER)

IS


BEGIN

            x_status := 0;
            pa_cc_utils.set_curr_function('PA_CC_AP_INV_CLIENT_EXTN.OVERRIDE_EXP_TYPE_EXP_ORG');
            --
            -- Default code returns the expenditure_type and expenditure organization
            -- that were passed to it.
            --
            pa_cc_utils.log_message('Calling the custom code in client extension ');
            X_Error_Stage := 'Assigning the original values back to it';

            x_expenditure_type :=  p_expenditure_type ;
            x_expenditure_organization_id :=  p_expenditure_organization_id ;

            pa_cc_utils.reset_curr_function;

EXCEPTION

WHEN OTHERS THEN
     RAISE ;

END override_exp_type_exp_org ;

END PA_CC_AP_INV_CLIENT_EXTN;

/
