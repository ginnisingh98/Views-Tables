--------------------------------------------------------
--  DDL for Package OKS_COVERAGES_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COVERAGES_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: OKSIMCVS.pls 115.2 2003/02/04 23:53:18 hmedheka noship $ */


l_clev_tbl_in             okc_cle_pvt.clev_tbl_type;
x_clev_tbl_in             okc_cle_pvt.clev_tbl_type;

l_cimv_tbl_in             okc_cim_pvt.cimv_tbl_type;
x_cimv_tbl_in             okc_cim_pvt.cimv_tbl_type;

l_rgpv_tbl_in             okc_rgp_pvt.rgpv_tbl_type;
x_rgpv_tbl_in             okc_rgp_pvt.rgpv_tbl_type;

l_isev_ext_tbl_in         okc_time_pvt.isev_ext_tbl_type;
x_isev_ext_tbl_in         okc_time_pvt.isev_ext_tbl_type;

l_isev_rel_tbl_in         okc_time_pvt.isev_rel_tbl_type;
x_isev_rel_tbl_in         okc_time_pvt.isev_rel_tbl_type;

l_rulv_tbl_in             okc_rul_pvt.rulv_tbl_type;
x_rulv_tbl_in             okc_rul_pvt.rulv_tbl_type;

l_igsv_ext_tbl_in         okc_time_pvt.igsv_ext_tbl_type;
x_igsv_ext_tbl_in         okc_time_pvt.igsv_ext_tbl_type;

l_ctiv_tbl_in             okc_cti_pvt.ctiv_tbl_type;
x_ctiv_tbl_in             okc_cti_pvt.ctiv_tbl_type;

l_cplv_tbl_in		      okc_cpl_pvt.cplv_tbl_type;
x_cplv_tbl_in		      okc_cpl_pvt.cplv_tbl_type;

l_ctcv_tbl_in		      okc_ctc_pvt.ctcv_tbl_type;
x_ctcv_tbl_in		      okc_ctc_pvt.ctcv_tbl_type;

l_tgdv_ext_tbl_in         okc_time_pvt.tgdv_ext_tbl_Type;
x_tgdv_ext_tbl_in         okc_time_pvt.tgdv_ext_tbl_Type;

l_tgdv_rcn_tbl_in         okc_time_pvt.tgdv_ext_tbl_Type;
x_tgdv_rcn_tbl_in         okc_time_pvt.tgdv_ext_tbl_Type;

l_rilv_tbl_in             okc_ril_pvt.rilv_tbl_type;
x_rilv_tbl_in             okc_ril_pvt.rilv_tbl_type;

l_rilt_tbl_in             okc_ril_pvt.rilv_tbl_type;
x_rilt_tbl_in             okc_ril_pvt.rilv_tbl_type;

g_timezone_id               NUMBER := nvl(FND_PROFILE.VALUE('CS_UPG_CONTRACTS_TIMEZONE'),47);

g_CREATION_DATE date := sysdate;
g_CREATED_BY number := -1;
g_LAST_UPDATE_DATE date := sysdate;
g_LAST_UPDATED_BY number := -1;
g_LAST_UPDATE_LOGIN number := -1;

l_api_version		Number  := 1;
l_init_msg_list		varchar2(200);
L_MSG_INDEX_OUT number;
l_msg_count		number;
l_msg_data		varchar2(2000);

PROCEDURE COVERAGE_MIGRATE (P_FromId        IN  NUMBER,
                            P_ToId          IN  NUMBER,
                            P_VALIDATE_FLAG IN  VARCHAR2,
                            P_LOG_PARAMETER IN  VARCHAR2);


PROCEDURE BUSINESS_PROCESSES_MIGRATE(   P_FromId        IN  NUMBER,
                                        P_ToId          IN  NUMBER,
                                        P_VALIDATE_FLAG IN  VARCHAR2,
                                        P_LOG_PARAMETER IN  VARCHAR2);



PROCEDURE BILL_TYPES_MIGRATE(   P_FromId        IN  NUMBER,
                                P_ToId          IN  NUMBER,
                                P_VALIDATE_FLAG IN  VARCHAR2,
                                P_LOG_PARAMETER IN  VARCHAR2);


PROCEDURE BILL_RATES_MIGRATE(   P_FromId        IN  NUMBER,
                                P_ToId          IN  NUMBER,
                                P_VALIDATE_FLAG IN  VARCHAR2,
                                P_LOG_PARAMETER IN  VARCHAR2);

PROCEDURE PRINT_REPORT		(   P_FromId        IN  NUMBER,
                                P_ToId          IN  NUMBER);

TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER ;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE ;
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
g_line_ref VARCHAR2(30) := 'OKS_CON_LINES_INT_ALL'; --'Int_Contract_Line';
g_covline_ref VARCHAR2(30) := 'OKS_COVERAGES_INT_ALL';
g_bpline_ref VARCHAR2(30) := 'OKS_COV_TXN_GROUPS_INT_ALL';
g_btline_ref VARCHAR2(30) := 'OKS_COV_BILL_TYPES_INT_ALL';
rulv_ctr NUMBER := 0;
time_ctr NUMBER := 0;


END OKS_COVERAGES_MIGRATION;

 

/
