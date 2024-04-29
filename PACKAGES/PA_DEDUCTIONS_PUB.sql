--------------------------------------------------------
--  DDL for Package PA_DEDUCTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DEDUCTIONS_PUB" AUTHID CURRENT_USER AS
-- /* $Header: PADCTNPS.pls 120.2.12010000.5 2010/03/08 06:26:06 sgottimu noship $ */
/*#
 * This package contains the public APIs for creation of deduction request header and details.
 * The name of the package is PA_DEDUCTIONS_PUB. API's Create_Deduction_Hdr and Create_Deduction_Txn
 * are to create the data into the tables PA_DEDUCTIONS_ALL and PA_DEDUCTION_TRANSACTIONS_ALL.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Deduction Request Creation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PAYABLE_INV_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

  g_pub_dctn_hdr_tbl PA_DEDUCTIONS.g_dctn_hdrtbl;
  g_pub_dctn_txn_tbl PA_DEDUCTIONS.g_dctn_txntbl;

  g_validate_txn VARCHAR2(1) := 'N';
  g_user_id NUMBER(15) := FND_GLOBAL.USER_ID;
  g_resp_id NUMBER := FND_GLOBAL.resp_id;
  g_api_version_number NUMBER := 1.0;

/*#
 * This API creates deduction request header information.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_project_id Input project id
 * @rep:paraminfo {@rep:required}
 * @param p_vendor_id Input vendor id
 * @rep:paraminfo {@rep:required}
 * @param p_vendor_site_id Input vendor site id
 * @rep:paraminfo {@rep:required}
 * @param p_ci_id Input Control item id
 * @param p_po_header_id Input PO Header Id
 * @param p_deduction_req_num Input Deducion request number
 * @rep:paraminfo {@rep:required}
 * @param p_debit_memo_num Input debit memo number
 * @param p_currency_code Input debit memo currency
 * @rep:paraminfo {@rep:required}
 * @param p_conversion_ratetype Input conversion rate type
 * @param p_conversion_ratedate Input conversion rate date
 * @param p_conversion_rate  Input conversion rate
 * @param p_deduction_req_date  Input Deduction request date
 * @rep:paraminfo {@rep:required}
 * @param p_debit_memo_date Input debit memo date
 * @param p_description Input description of the debit memo
 * @param p_org_id Input org_id
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Deduction Request Header
 * @rep:compatibility S
*/
  Procedure Create_Deduction_Hdr( p_api_version_number     IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_commit                 IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_pm_product_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_msg_count              OUT NOCOPY NUMBER
                                 ,p_msg_data               OUT NOCOPY VARCHAR2
                                 ,p_return_status          OUT NOCOPY VARCHAR2
                                 ,p_project_id             IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_vendor_id              IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_vendor_site_id         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_ci_id                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_po_header_id           IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_deduction_req_num      IN OUT NOCOPY VARCHAR2
                                 ,p_debit_memo_num         IN OUT NOCOPY VARCHAR2
                                 ,p_currency_code          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_conversion_ratetype    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_conversion_ratedate    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_conversion_rate        IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_deduction_req_date     IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_debit_memo_date        IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_description            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_status                 IN OUT NOCOPY VARCHAR2
                                 ,p_org_id                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                );

/*#
 * This API creates deduction request detail information.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_deduction_req_num Input Deduction request number
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Input task id
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type Input expenditure type
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_date Input expenditure item date
 * @rep:paraminfo {@rep:required}
 * @param p_gl_date  Input accounting date
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_org_id Input expenditure organization id
 * @rep:paraminfo {@rep:required}
 * @param p_quantity Input quantity
 * @param p_expenditure_item_id Input expenditure item id
 * @param p_orig_projfunc_amount Input Amount in project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_conversion_ratetype Input conversion rate type
 * @param p_conversion_ratedate Input conversion rate date
 * @param p_conversion_rate Input conversion rate
 * @rep:paraminfo {@rep:required}
 * @param p_description Input Detail transaction description.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Deduction Transaction Details
 * @rep:compatibility S
*/
  Procedure Create_Deduction_Txn( p_api_version_number     IN NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_commit                 IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_pm_product_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_msg_count              OUT NOCOPY NUMBER
                                 ,p_msg_data               OUT NOCOPY VARCHAR2
                                 ,p_return_status          OUT NOCOPY VARCHAR2
                                 ,p_deduction_req_num          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_task_id                    IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_expenditure_type           IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_expenditure_item_date      IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_gl_date                    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_expenditure_org_id         IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_quantity                   IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 --,p_override_quantity          IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- bug9052223
                                 ,p_expenditure_item_id        IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                               --  ,p_projfunc_currency_code     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- bug9052223
                                 ,p_orig_projfunc_amount       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                --,p_override_projfunc_amount   IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- bug9052223
                                 ,p_conversion_ratetype        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_conversion_ratedate        IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_conversion_rate            IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                --,p_amount                     IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- bug9052223
                                 ,p_description                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                );

END PA_DEDUCTIONS_PUB;

/
