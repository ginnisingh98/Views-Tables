--------------------------------------------------------
--  DDL for Package PA_CI_SUPPLIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_SUPPLIER_PKG" AUTHID CURRENT_USER AS
--$Header: PACISIIS.pls 120.0.12010000.10 2010/04/13 15:47:19 gboomina ship $

--TYPE PA_VC_1000_150 IS VARRAY(1000) OF VARCHAR2(150);
--TYPE PA_VC_1000_NUM IS VARRAY(1000) OF NUMBER;


PROCEDURE insert_row (
        x_rowid                        in out NOCOPY VARCHAR2
        ,x_CI_transaction_id           IN OUT NOCOPY NUMBER
        ,p_CI_TYPE_ID                  IN   NUMBER
        ,p_CI_ID                       IN   NUMBER
        ,p_CI_IMPACT_ID                IN   NUMBER
        ,p_VENDOR_ID                   IN   NUMBER
        ,p_PO_HEADER_ID                IN   NUMBER
        ,p_PO_LINE_ID                  IN   NUMBER
        ,p_ADJUSTED_TRANSACTION_ID     IN   NUMBER
        ,p_CURRENCY_CODE               IN   VARCHAR2
        ,p_CHANGE_AMOUNT               IN   NUMBER
        ,p_CHANGE_TYPE                 IN   VARCHAR2
        ,p_CHANGE_DESCRIPTION          IN   VARCHAR2
        ,p_CREATED_BY                  IN   NUMBER
        ,p_CREATION_DATE               IN   DATE
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
		,p_Task_Id                     IN NUMBER
		,p_Resource_List_Mem_Id        IN NUMBER
		,p_From_Date                   IN varchar2
		,p_To_Date                     IN varchar2
		,p_Estimated_Cost              IN NUMBER
		,p_Quoted_Cost                 IN NUMBER
		,p_Negotiated_Cost             IN NUMBER
		,p_Burdened_cost             IN NUMBER
		,p_Revenue                   IN NUMBER default NULL
		,p_revenue_override_rate     in number
        ,p_audit_history_number        in number
        ,p_current_audit_flag          in varchar2
        ,p_Original_supp_trans_id              in number
        ,p_Source_supp_trans_id                in number
		,p_Sup_ref_no                  in number default null
		,p_version_type                in varchar2 default 'ALL'
        ,p_ci_status                   IN   VARCHAR2 default null
        -- gboomina modified for supplier cost 12.1.3 requirement - start
        ,p_expenditure_type            in varchar2 default null
        ,p_expenditure_org_id          in number default null
        ,p_change_reason_code          in varchar2 default null
        ,p_quote_negotiation_reference in varchar2 default null
        ,p_need_by_date                in varchar2 default null
        -- gboomina modified for supplier cost 12.1.3 requirement - end
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      );

 PROCEDURE update_row
        (p_rowid                       IN   VARCHAR2
        ,p_ci_transaction_id           IN   NUMBER
        ,p_CI_TYPE_ID                   IN   NUMBER
        ,p_CI_ID                	IN   NUMBER
        ,p_CI_IMPACT_ID              	IN   NUMBER
        ,p_VENDOR_ID                   IN   NUMBER
        ,p_PO_HEADER_ID                IN   NUMBER
        ,p_PO_LINE_ID                  IN   NUMBER
        ,p_ADJUSTED_TRANSACTION_ID     IN   NUMBER
        ,p_CURRENCY_CODE               IN   VARCHAR2
        ,p_CHANGE_AMOUNT               IN   NUMBER
        ,p_CHANGE_TYPE                 IN   VARCHAR2
        ,p_CHANGE_DESCRIPTION          IN   VARCHAR2
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
		,p_Task_Id                     IN NUMBER
		,p_Resource_List_Mem_Id        IN NUMBER
		,p_From_Date                   IN varchar2
		,p_To_Date                     IN varchar2
		,p_Estimated_Cost              IN NUMBER
		,p_Quoted_Cost                 IN NUMBER
		,p_Negotiated_Cost             IN NUMBER
		,p_Burdened_cost             IN NUMBER
		,p_Revenue                   IN NUMBER default NULL
		,p_revenue_override_rate     in number
        ,p_audit_history_number      in number
        ,p_current_audit_flag        in varchar2
        ,p_Original_supp_trans_id    in number
        ,p_Source_supp_trans_id      in number
        -- gboomina modified for supplier cost 12.1.3 requirement - start
	,p_Sup_ref_no                  in number default null
	,p_version_type                in varchar2 default 'ALL'
	,p_ci_status                   IN VARCHAR2 default null
        ,p_expenditure_type            in varchar2 default null
        ,p_expenditure_org_id          in number default null
        ,p_change_reason_code          in varchar2 default null
        ,p_quote_negotiation_reference in varchar2 default null
        ,p_need_by_date                in varchar2 default null
        -- gboomina modified for supplier cost 12.1.3 requirement - end
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      );
 PROCEDURE  delete_row (p_ci_transaction_id in NUMBER);

 PROCEDURE delete_row (x_rowid      in VARCHAR2);

 PROCEDURE lock_row (x_rowid    in VARCHAR2);


END PA_CI_SUPPLIER_PKG;

/
