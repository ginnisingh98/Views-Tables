--------------------------------------------------------
--  DDL for Package PA_CI_SUPPLIER_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_SUPPLIER_UTILS" AUTHID CURRENT_USER AS
--$Header: PASIUTLS.pls 120.0.12010000.9 2010/04/26 15:18:26 gboomina ship $

--TYPE PA_VC_1000_150 IS VARRAY(1000) OF VARCHAR2(150);
--TYPE PA_VC_1000_NUM IS VARRAY(1000) OF NUMBER;

PROCEDURE print_msg(p_msg varchar2);


PROCEDURE deleteSIrecord(P_CALLING_MODE  IN varchar2
                       ,p_ROWID          IN varchar2
                       ,P_CI_TRANSACTION_ID  IN number
                       ,X_RETURN_STATUS    IN OUT NOCOPY varchar2
                       ,x_MSG_DATA   IN OUT NOCOPY varchar2
                       ,X_MSG_COUNT  IN OUT NOCOPY number );

PROCEDURE validate_SI_record(
	    p_RECORD_STATUS               IN  VARCHAR2
	    ,p_CI_ID                	IN  NUMBER
	    ,P_CALLING_MODE                IN  VARCHAR2
        ,P_CI_STATUS            	IN  VARCHAR2
	    ,P_ORG_ID                      IN  VARCHAR2
        ,x_VENDOR_ID                   IN  OUT NOCOPY  NUMBER
	    ,p_VENDOR_NAME		       IN   VARCHAR2
        ,x_PO_HEADER_ID                IN  OUT NOCOPY NUMBER
        ,p_PO_NUMBER                   IN  VARCHAR2
        ,x_PO_LINE_ID                  IN  OUT NOCOPY  NUMBER
        ,p_PO_LINE_NUM                 IN   NUMBER
        ,p_ADJUSTED_TRANSACTION_ID     IN   NUMBER
        ,p_CURRENCY_CODE               IN   VARCHAR2
        ,p_CHANGE_AMOUNT               IN   NUMBER
        ,p_CHANGE_TYPE                 IN   VARCHAR2
        ,p_CHANGE_DESCRIPTION          IN   VARCHAR2
		,p_Task_Id                   IN VARCHAR2
		,p_Resource_List_Mem_Id      IN VARCHAR2
		,p_From_Date                 IN VARCHAR2
		,p_To_Date                   IN VARCHAR2
		,p_Estimated_Cost            IN VARCHAR2
		,p_Quoted_Cost               IN VARCHAR2
		,p_Negotiated_Cost           IN VARCHAR2
		,p_Burdened_cost             IN VARCHAR2
		,p_revenue_override_rate      IN varchar2
        ,p_audit_history_number        in number default null
        ,p_current_audit_flag          in varchar2 default 'Y'
        ,p_Original_supp_trans_id      in number default null
        ,p_Source_supp_trans_id        in number default null
		,p_Sup_ref_no                in number default null
		,p_version_type                in varchar2 default 'ALL'
        ,p_ci_transaction_id           IN   NUMBER
       ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      );

PROCEDURE validate_insert_SI(
	 p_ROWID                       IN  OUT NOCOPY PA_VC_1000_150
        ,p_RECORD_STATUS               IN  PA_VC_1000_150
        ,p_CI_ID                	IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_CI_TYPE_ID                  IN  PA_VC_1000_150
        ,p_CI_IMPACT_ID                IN  PA_VC_1000_150
        ,P_CALLING_MODE                IN  VARCHAR2
        ,P_CI_STATUS            	IN  PA_VC_1000_150
        ,P_ORG_ID                      IN  PA_VC_1000_150
        ,x_VENDOR_ID                   IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_VENDOR_NAME                 IN  PA_VC_1000_150
        ,x_PO_HEADER_ID                IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_PO_NUMBER                   IN  PA_VC_1000_150
        ,x_PO_LINE_ID                  IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_PO_LINE_NUM                 IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_ADJUSTED_TRANSACTION_ID     IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_CURRENCY_CODE               IN  PA_VC_1000_150
        ,p_CHANGE_AMOUNT               IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_CHANGE_TYPE                 IN  PA_VC_1000_150
        ,p_CHANGE_DESCRIPTION          IN  PA_VC_1000_150
		,p_Task_Id                   IN PA_VC_1000_150
        ,p_Resource_List_Mem_Id      IN PA_VC_1000_150
		,p_From_Date                 IN PA_VC_1000_150
		,p_To_Date                   IN PA_VC_1000_150
		,p_Estimated_Cost            IN PA_VC_1000_150
		,p_Quoted_Cost               IN PA_VC_1000_150
		,p_Negotiated_Cost           IN PA_VC_1000_150
		,p_Burdened_cost             IN PA_VC_1000_150
		,p_revenue_override_rate      IN PA_VC_1000_150
        ,p_audit_history_number        in number default null
        ,p_current_audit_flag          in varchar2 default 'Y'
        ,p_Original_supp_trans_id      in number default null
        ,p_Source_supp_trans_id        in number default null
		,p_Sup_ref_no                in number default null
		,p_version_type                in varchar2 default 'ALL'
        -- gboomina modified for supplier cost 12.1.3 requirement - start
        ,p_expenditure_type            in  varchar2
        ,p_expenditure_org_id          in number
        ,p_change_reason_code          in varchar2
        ,p_quote_negotiation_reference in varchar2
        ,p_need_by_date                in varchar2
        -- gboomina modified for supplier cost 12.1.3 requirement - end
	    ,p_ci_transaction_id           IN  OUT NOCOPY PA_VC_1000_150
        ,p_RECORD_ID                   IN  OUT NOCOPY PA_VC_1000_150
        ,p_REC_RETURN_STATUS           IN  OUT NOCOPY PA_VC_1000_150
        ,x_return_status               IN OUT NOCOPY VARCHAR2
        ,x_msg_data                    IN OUT NOCOPY VARCHAR2
        ,x_msg_count                   IN OUT NOCOPY NUMBER
);
-- This API calls validate the supplier impact record and calls table
-- handler depending on the record status if record status is NEW it inserts
-- else it UPDATES pa_info_supplier_info table.
-- This API is called from PaSupplierImplementVORowImpl.java method for each row
PROCEDURE validateSI(p_ROWID                      IN OUT NOCOPY VARCHAR2
                     ,p_RECORD_STATUS             IN VARCHAR2
                     ,p_CI_ID                     IN VARCHAR2
                     ,p_CI_TYPE_ID                IN VARCHAR2
                     ,p_CI_IMPACT_ID              IN VARCHAR2
                     ,P_CALLING_MODE              IN VARCHAR2
                     ,P_ORG_ID                    IN VARCHAR2
                     ,p_VENDOR_NAME               IN VARCHAR2
                     ,p_PO_NUMBER                 IN VARCHAR2
                     ,p_PO_LINE_NUM               IN VARCHAR2
                     ,p_ADJUSTED_TRANSACTION_ID   IN VARCHAR2
                     ,p_CURRENCY_CODE             IN VARCHAR2
                     ,p_CHANGE_AMOUNT             IN VARCHAR2
                     ,p_CHANGE_TYPE               IN VARCHAR2
                     ,p_CHANGE_DESCRIPTION        IN VARCHAR2
                     ,p_Task_Id                   IN VARCHAR2
                     ,p_Resource_List_Mem_Id      IN VARCHAR2
                     ,p_From_Date                 IN VARCHAR2
                     ,p_To_Date                   IN VARCHAR2
                     ,p_Estimated_Cost            IN VARCHAR2
                     ,p_Quoted_Cost               IN VARCHAR2
                     ,p_Negotiated_Cost           IN VARCHAR2
                     ,p_Burdened_cost             IN VARCHAR2
                     ,p_Revenue                   IN VARCHAR2 default NULL
                     ,p_revenue_override_rate      IN varchar2
                     ,p_audit_history_number      in number default null
                     ,p_current_audit_flag        in varchar2 default 'Y'
                     ,p_Original_supp_trans_id    in number default null
                     ,p_Source_supp_trans_id      in number default null
                     ,p_Sup_ref_no                in number default null
                     ,p_version_type                in varchar2 default 'ALL'
                     -- gboomina modified for supplier cost 12.1.3 requirement - start
                     ,p_expenditure_type            in  varchar2
                     ,p_expenditure_org_id          in number
                     ,p_change_reason_code          in varchar2
                     ,p_quote_negotiation_reference in varchar2
                     ,p_need_by_date                in varchar2
                     -- gboomina modified for supplier cost 12.1.3 requirement - end
                     ,p_CI_TRANSACTION_ID         IN OUT NOCOPY VARCHAR2
                     ,x_return_status             IN OUT NOCOPY VARCHAR2
                     ,x_msg_data                  IN OUT NOCOPY VARCHAR2
                     ,x_msg_count                 IN OUT NOCOPY NUMBER
                    );

            PROCEDURE Merge_suppliers
                ( p_from_ci_item_id          IN NUMBER
                 ,p_to_ci_item_id            IN NUMBER
                 ,x_return_status            OUT NOCOPY VARCHAR2
                 ,x_error_msg                OUT NOCOPY VARCHAR2
                   );

PROCEDURE DELETE_IMPACT(p_ci_id               IN  NUMBER
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_data           OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER
                        );

PROCEDURE IS_SI_DELETE_OK(p_ci_id               IN  NUMBER
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_data           OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER
                        );

PROCEDURE GET_RESOURCE_LIST_ID(p_project_id IN NUMBER
                               ,x_res_list_id OUT NOCOPY number
                               ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_data           OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER);

PROCEDURE GET_Original_Ci_ID(p_ci_id IN NUMBER
                             ,x_original_ci_id     OUT NOCOPY number
                             ,x_return_status      OUT NOCOPY VARCHAR2
                             ,x_msg_data           OUT NOCOPY VARCHAR2
                             ,x_msg_count          OUT NOCOPY NUMBER);


PROCEDURE GET_TOTAL_COST(p_ci_id IN NUMBER
                        ,x_total_cost         OUT NOCOPY NUMBER
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_data           OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER);



FUNCTION IS_SI_DELETE_OK(p_ci_id   IN  NUMBER) return varchar2;

FUNCTION get_formated_amount(p_currency_code  varchar2
         		    ,p_amount number ) return varchar2 ;


-- gboomina added for 12.1.3 supplier cost requirement - start
G_PKG_NAME varchar2(30) := 'PA';
PROCEDURE delete_supplier_costs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ci_transaction_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE ,
    p_ci_id                        IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_resource_assignment_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE
    );

procedure save_supplier_costs(
     p_api_version                     IN NUMBER
    ,p_init_msg_list                   IN VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                   IN OUT NOCOPY VARCHAR2
    ,x_msg_data                        IN OUT NOCOPY VARCHAR2
    ,x_msg_count                       IN OUT NOCOPY NUMBER
    ,p_rowid_tbl                       IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_ci_transaction_id_tbl           IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_ci_id                           IN NUMBER
    ,p_ci_type_id                      IN NUMBER
    ,p_ci_impact_id                    IN NUMBER DEFAULT NULL
    ,p_calling_mode                    IN VARCHAR2
    ,p_org_id                          IN NUMBER
    ,p_version_type                    IN VARCHAR2 DEFAULT 'ALL'
    ,p_record_status_tbl               IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_vendor_name_tbl                 IN SYSTEM.PA_VARCHAR2_150_TBL_TYPE
    ,p_vendor_id_tbl                   IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_po_number_tbl                   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_po_header_id_tbl                IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_po_line_num_tbl                 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_po_line_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_currency_code_tbl               IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_change_amount_tbl               IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_change_type_tbl                 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_change_description_tbl          IN SYSTEM.PA_VARCHAR2_150_TBL_TYPE
    ,p_task_id_tbl                     IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_resource_list_mem_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_adjusted_transaction_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_from_date_tbl                   IN SYSTEM.PA_DATE_TBL_TYPE
    ,p_to_date_tbl                     IN SYSTEM.PA_DATE_TBL_TYPE
    ,p_need_by_date_tbl                IN SYSTEM.PA_DATE_TBL_TYPE
    ,p_estimated_cost_tbl              IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_quoted_cost_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_negotiated_cost_tbl             IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_burdened_cost_tbl               IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_revenue_tbl                     IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
    ,p_revenue_override_rate_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_audit_history_number_tbl        IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_current_audit_flag_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_original_supp_trans_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_source_supp_trans_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_sup_ref_no_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
    ,p_expenditure_type_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_expenditure_org_id_tbl          IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_change_reason_code_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_quote_negotiation_ref_tbl       IN SYSTEM.PA_VARCHAR2_150_TBL_TYPE
    ,p_resource_assignment_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE
);
-- gboomina added for 12.1.3 supplier cost requirement - end



END PA_CI_SUPPLIER_UTILS;

/
