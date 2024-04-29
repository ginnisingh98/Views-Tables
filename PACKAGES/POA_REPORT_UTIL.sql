--------------------------------------------------------
--  DDL for Package POA_REPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_REPORT_UTIL" AUTHID CURRENT_USER AS
/* $Header: poarutls.pls 115.6 2002/12/28 00:54:54 iali ship $ */

TYPE SOB_Rec_Type IS RECORD (
  SOB_ID        NUMBER := NULL
);

TYPE SOB_Tbl_Type IS TABLE of SOB_Rec_Type
  INDEX BY BINARY_INTEGER;

PROCEDURE Build_OrderDates(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_CTL_ViewBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_LSS_ViewBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SPA_ViewBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_ReportingDates(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SupplierItem(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_PrefSupplier(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_ConsSupplier(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_QualityCost(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_DeliveryCost(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_HiddenStartDate(p_start_date IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_HiddenEndDate(p_end_date IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_HiddenCurrency(p_currency_code IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_HiddenItem(p_item_id IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SupplierNum(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SupplierOrderBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);


PROCEDURE Build_SavingsOperatingUnit(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_PPS_OperatingUnit(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);


PROCEDURE Build_SavingsBuyer(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SavingsCommodity(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SavingsItem(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SavingsSupplier(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_KPIPeriodType(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_KPI_2PeriodType(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_SavingsShipToOrg(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER);

PROCEDURE Build_Selection(p_name IN VARCHAR2,
    p_select IN VARCHAR2, p_output IN OUT NOCOPY VARCHAR2);

PROCEDURE Build_ErrorPage(
p_param IN BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type);

FUNCTION Validate_OrderDates(p_fdate IN OUT NOCOPY VARCHAR2,
    p_tdate IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION Validate_SupplierNum(p_num_of_suppliers IN OUT NOCOPY NUMBER)
    RETURN BOOLEAN;

FUNCTION Validate_QualityCost(p_quality_cost IN OUT NOCOPY NUMBER)
   RETURN BOOLEAN;

FUNCTION Validate_DeliveryCost(p_delivery_cost IN OUT NOCOPY NUMBER)
   RETURN BOOLEAN;

FUNCTION Validate_SupplierItem(p_item_name IN VARCHAR2,
    p_item_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_PrefSupplier(p_pref_supp_name IN VARCHAR2,
    p_pref_supp_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_ConsSupplier(p_cons_supp_name IN VARCHAR2,
    p_cons_supp_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_SavingsBuyer(p_buyer_name IN VARCHAR2,
    p_buyer_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_SavingsSupplier(p_supplier_name IN VARCHAR2,
    p_supplier_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_SavingsShipToOrg(p_org_name IN VARCHAR2,
    p_org_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_SavingsOperatingUnit(p_oper_unit_name IN VARCHAR2,
    p_oper_unit_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_PPS_OperatingUnit(p_oper_unit_name IN VARCHAR2,
    p_oper_unit_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION Validate_SavingsCommodity(p_commodity_name IN VARCHAR2,
    p_commodity_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

PROCEDURE Retrieve_Org_Where_Clause(p_user_id IN NUMBER := NULL,
p_user_name IN VARCHAR2 := NULL,
x_where_clause OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2,
x_error_Tbl OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);

PROCEDURE Retrieve_Set_of_Books_Id(
x_Responsibility_tbl IN BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type,
x_SOB_tbl OUT NOCOPY POA_REPORT_UTIL.SOB_Tbl_Type,
x_return_status OUT NOCOPY VARCHAR2);


END POA_REPORT_UTIL;

 

/
