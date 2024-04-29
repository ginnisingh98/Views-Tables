--------------------------------------------------------
--  DDL for Package OKS_INSERT_ROW_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_INSERT_ROW_UPG" AUTHID CURRENT_USER AS
/* $Header: OKSCOVUS.pls 120.0 2005/05/25 18:38:07 appldev noship $ */


        G_APP_NAME              CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
        G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
        G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_MESSAGE';
        G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_CODE';



    PROCEDURE INSERT_ROW_UPG_KLNV_TBL
                        (x_return_status OUT NOCOPY VARCHAR2,
                         P_KLNV_TBL  OKS_KLN_PVT.klnv_tbl_type) ;

    PROCEDURE INSERT_ROW_UPG_CTZV_TBL
						(x_return_status OUT NOCOPY VARCHAR2,
						 P_CTZV_TBL  OKS_CTZ_PVT.OksCoverageTimezonesVTblType);
    PROCEDURE INSERT_ROW_UPG_CVTV_TBL
						(x_return_status OUT NOCOPY VARCHAR2,
						 P_CVTV_TBL  OKS_CVT_PVT.oks_coverage_times_v_tbl_type);
    PROCEDURE INSERT_ROW_UPG_ACMV_TBL
						(x_return_status OUT NOCOPY VARCHAR2,
						 P_ACMV_TBL  OKS_ACM_PVT.oks_action_times_v_tbl_type);
    PROCEDURE INSERT_ROW_UPG_ACTV_TBL
						(x_return_status OUT NOCOPY VARCHAR2,
						 P_ACTV_TBL  OKS_ACT_PVT.OksActionTimeTypesVTblType);

    PROCEDURE INSERT_ROW_UPG_KHRV_TBL
                        (x_return_status OUT NOCOPY VARCHAR2,
                         P_KHRV_TBL  OKS_KHR_PVT.khrv_tbl_type) ;

    PROCEDURE INSERT_ROW_UPG_sllv_tbl (x_return_status OUT NOCOPY VARCHAR2,
                         p_sllv_tbl  OKS_SLL_PVT.sllv_tbl_type);

    PROCEDURE INSERT_ROW_UPG_letv_tbl (x_return_status OUT NOCOPY VARCHAR2,
                         p_letv_tbl  OKS_BILL_LEVEL_ELEMENTS_PVT.letv_tbl_type);


    PROCEDURE INSERT_ROW_UPG_bill_sch
	(x_return_status OUT NOCOPY VARCHAR2,
	p_oks_billrate_schedules_v_tbl  OKS_BRS_PVT.OksBillrateSchedulesVTblType) ;

  -----------------------------------------------------------------------------
  -- Added by AVReddy for Subscription bulk insert - on Dec 02 03
  -----------------------------------------------------------------------------

    PROCEDURE INSERT_BY_TBL_SUBHDR(
                 x_return_status OUT NOCOPY VARCHAR2
                ,P_SUBHDR_TBL  OKS_SUBSCR_HDR_PVT.schv_tbl_type) ;


    PROCEDURE INSERT_BY_TBL_SUBPTNS(
               x_return_status OUT NOCOPY VARCHAR2
              ,P_SUBPTN_TBL  OKS_SUBSCR_PTRNS_PVT.scpv_tbl_type);


    PROCEDURE INSERT_BY_TBL_SUBELMNTS(
               x_return_status OUT NOCOPY VARCHAR2
              ,P_SUBELMNTS_TBL  OKS_SUBSCR_ELEMS_PVT.scev_tbl_type);

END OKS_Insert_Row_Upg;


 

/
