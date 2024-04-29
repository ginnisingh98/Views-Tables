--------------------------------------------------------
--  DDL for Package PA_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EVENT_PVT" AUTHID DEFINER AS
/* $Header: PAEVAPVS.pls 120.4.12010000.2 2008/08/22 16:09:25 mumohan ship $ */

/* Global Constants */
pub_excp                        exception;--user defined exception
G_PKG_PVT                       constant varchar2(100):='PA_EVENT_PVT';

FUNCTION CHECK_CREATE_EVENT_OK
(P_pm_product_code      		IN      VARCHAR2
,P_event_in_rec         		IN      PA_EVENT_PUB.Event_Rec_in_type
,P_project_currency_code                IN      VARCHAR2
,P_proj_func_currency_code              IN      VARCHAR2
,P_project_bil_rate_date_code           IN      VARCHAR2
,P_project_rate_type                    IN      VARCHAR2
,p_project_bil_rate_date		IN 	VARCHAR2
,p_projfunc_bil_rate_date_code          IN      VARCHAR2
,P_projfunc_rate_type			IN	VARCHAR2
,p_projfunc_bil_rate_date		IN 	VARCHAR2
,P_funding_rate_type                    IN      VARCHAR2
,P_multi_currency_billing_flag          IN      VARCHAR2
,p_project_id                           IN      NUMBER
,p_projfunc_bil_exchange_rate           IN      NUMBER -- Added  for bug 3013137
,p_funding_bil_rate_date_code           IN      VARCHAR2  --Added for bug 3053190
,x_task_id                              OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
,x_organization_id                      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_inv_org_id                           OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
,x_agreement_id                         OUT     NOCOPY NUMBER  -- Federal Uptake
,P_event_type_classification            OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
RETURN VARCHAR2;


FUNCTION CHECK_UPDATE_EVENT_OK
(P_pm_product_code                      IN      VARCHAR2
,P_event_in_rec                         IN      PA_EVENT_PUB.Event_rec_in_type
,P_project_currency_code                IN      VARCHAR2
,P_proj_func_currency_code              IN      VARCHAR2
,P_project_bil_rate_date_code           IN      VARCHAR2
,P_project_rate_type                    IN      VARCHAR2
,p_project_bil_rate_date		IN 	VARCHAR2
,p_projfunc_bil_rate_date_code          IN      VARCHAR2
,P_projfunc_rate_type                   IN      VARCHAR2
,p_projfunc_bil_rate_date               IN      VARCHAR2
,P_funding_rate_type                    IN      VARCHAR2
,P_multi_currency_billing_flag          IN      VARCHAR2
,p_project_id                           IN      NUMBER
,p_projfunc_bil_exchange_rate           IN      NUMBER -- Added for bug 3013137
,p_funding_bill_rate_date_code          IN      VARCHAR2 --Added for bug 3053190
,x_task_id                              OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
,x_organization_id                      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_inv_org_id                           OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
,x_agreement_id                         OUT     NOCOPY NUMBER  -- Federal Uptake
,p_event_type_classification            OUT     NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
,P_event_processed                      OUT     NOCOPY VARCHAR2)  /* Added for Bug 7110782 */
RETURN VARCHAR2;

PROCEDURE VALIDATE_FLEXFIELD
( P_desc_flex_name       IN      VARCHAR2
 ,P_attribute_category   IN      VARCHAR2
 ,P_attribute1           IN      VARCHAR2
 ,P_attribute2           IN      VARCHAR2
 ,P_attribute3           IN      VARCHAR2
 ,P_attribute4           IN      VARCHAR2
 ,P_attribute5           IN      VARCHAR2
 ,P_attribute6           IN      VARCHAR2
 ,P_attribute7           IN      VARCHAR2
 ,P_attribute8           IN      VARCHAR2
 ,P_attribute9           IN      VARCHAR2
 ,P_attribute10          IN      VARCHAR2
 ,P_return_msg           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_valid_status         OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE CHECK_MDTY_PARAMS1
    ( p_api_version_number              IN   NUMBER
     ,p_api_name                        IN   VARCHAR2
     ,p_pm_product_code                 IN   VARCHAR2
     ,p_function_name                   IN   VARCHAR2
     ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


g_api_version_number            NUMBER := 1.0;

PROCEDURE CHECK_MDTY_PARAMS2
   (  p_pm_event_reference    IN   VARCHAR2
     ,P_pm_product_code       IN   VARCHAR2
     ,p_project_number        IN   VARCHAR2
     ,p_event_type            IN   VARCHAR2
     ,p_organization_name     IN   VARCHAR2
     ,p_calling_place         IN   VARCHAR2
     ,x_return_status         OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


FUNCTION CONV_EVENT_REF_TO_ID
(P_pm_product_code	IN	VARCHAR2
,P_pm_event_reference	IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,P_event_id		IN OUT	NOCOPY NUMBER) --File.Sql.39 bug 4440895
RETURN VARCHAR2;

FUNCTION CHECK_DELETE_EVENT_OK
(P_pm_event_reference   IN      VARCHAR2
,P_event_id     	IN      NUMBER)
RETURN VARCHAR2;


FUNCTION CHECK_EVENT_REF_UNQ
(P_pm_product_code	IN	VARCHAR2
,P_pm_event_reference	IN	VARCHAR2)
RETURN VARCHAR2;

FUNCTION CHECK_YES_NO
(P_flag         IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION FETCH_EVENT_ID
(P_pm_product_code      IN      VARCHAR2
,P_pm_event_reference   IN      VARCHAR2)
RETURN NUMBER;



END PA_EVENT_PVT;

/
