--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPCHRS.pls 120.3 2005/07/19 05:11:29 maanand noship $ */

-- Define record/table type for the amount manipulations in Authoring form
 TYPE Price_Table_Record IS RECORD (
		ID  NUMBER,
		CLE_ID  NUMBER,
		LEVEL   NUMBER,
		AMOUNT  NUMBER,
		EXT_AMOUNT  NUMBER,
		NGT_AMOUNT  NUMBER,
		PRICED_YN VARCHAR2(1)
		);

  TYPE Price_Table_Type IS TABLE OF Price_Table_Record
	  INDEX BY BINARY_INTEGER;

  subtype chrv_rec_type is okc_contract_pvt.chrv_rec_type;
  subtype chrv_tbl_type is okc_contract_pvt.chrv_tbl_type;
  subtype clev_rec_type is okc_contract_pvt.clev_rec_type;
  subtype clev_tbl_type is okc_contract_pvt.clev_tbl_type;
  subtype cacv_rec_type is okc_contract_pvt.cacv_rec_type;
  subtype cacv_tbl_type is okc_contract_pvt.cacv_tbl_type;
  subtype cpsv_rec_type is okc_contract_pvt.cpsv_rec_type;
  subtype cpsv_tbl_type is okc_contract_pvt.cpsv_tbl_type;
  subtype gvev_rec_type is okc_contract_pvt.gvev_rec_type;
  subtype gvev_tbl_type is okc_contract_pvt.gvev_tbl_type;
  subtype cvmv_rec_type is okc_contract_pvt.cvmv_rec_type;
  subtype cvmv_tbl_type is okc_contract_pvt.cvmv_tbl_type;
  subtype control_rec_type is okc_util.okc_control_rec_type;

  -- Global variables for user hooks
  g_pkg_name		CONSTANT	VARCHAR2(200)	:= 'OKC_CONTRACT_PUB';
  g_app_name		CONSTANT	VARCHAR2(3)	:= OKC_API.G_APP_NAME;

  g_chrv_rec		chrv_rec_type;
  g_chrv_tbl		chrv_tbl_type;
  g_clev_rec		clev_rec_type;
  g_clev_tbl		clev_tbl_type;
  g_cacv_rec		cacv_rec_type;
  g_cacv_tbl		cacv_tbl_type;
  g_cpsv_rec		cpsv_rec_type;
  g_cpsv_tbl		cpsv_tbl_type;
  g_gvev_rec		gvev_rec_type;
  g_gvev_tbl		gvev_tbl_type;

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY  chrv_rec_type,
    p_check_access                 IN  VARCHAR2 DEFAULT 'N');


  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY chrv_tbl_type,
    p_check_access                 IN VARCHAR2 DEFAULT 'N');

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY chrv_rec_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_tbl                     IN chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY chrv_tbl_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN chrv_rec_type,
    p_control_rec		   IN control_rec_type,
    x_chrv_rec                     OUT NOCOPY chrv_rec_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_tbl                     IN chrv_tbl_type,
    p_control_rec                  IN control_rec_type,
    x_chrv_tbl                     OUT NOCOPY chrv_tbl_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type);

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type);

  -- The p_restricted_update i sdefaulted to 'F' as it is added
  -- in a later stage and not to error out current create_contract_line
  -- calls from forms
  --
  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT 'F',
    p_clev_rec                     IN  clev_rec_type,
    x_clev_rec                     OUT NOCOPY  clev_rec_type);

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT 'F',
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_rec                     IN clev_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                      IN NUMBER);

  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);

  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type);

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY gvev_tbl_type);

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type);

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY gvev_tbl_type);

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type);

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type);

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type);

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type);

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type);

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type);

  PROCEDURE create_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY cpsv_rec_type);

  PROCEDURE create_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY cpsv_tbl_type);

  PROCEDURE update_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY cpsv_rec_type);

  PROCEDURE update_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY cpsv_tbl_type);

  PROCEDURE delete_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type);

  PROCEDURE delete_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type);

  PROCEDURE lock_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type);

  PROCEDURE lock_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type);

  PROCEDURE validate_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type);

  PROCEDURE validate_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type);

  PROCEDURE create_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY cacv_rec_type);

  PROCEDURE create_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY cacv_tbl_type);

  PROCEDURE update_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY cacv_rec_type);

  PROCEDURE update_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY cacv_tbl_type);

  PROCEDURE delete_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type);

  PROCEDURE delete_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type);

  PROCEDURE lock_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type);

  PROCEDURE lock_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type);

  PROCEDURE validate_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type);

  PROCEDURE validate_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type);

  PROCEDURE add_language;

  PROCEDURE Get_Active_Process (
		p_api_version				IN NUMBER,
		p_init_msg_list			IN VARCHAR2,
		x_return_status		 OUT NOCOPY VARCHAR2,
		x_msg_count			 OUT NOCOPY NUMBER,
		x_msg_data			 OUT NOCOPY VARCHAR2,
		p_contract_number             IN VARCHAR2,
		p_contract_number_modifier    IN VARCHAR2,
		x_wf_name				 OUT NOCOPY VARCHAR2,
		x_wf_process_name		 OUT NOCOPY VARCHAR2,
		x_package_name			 OUT NOCOPY VARCHAR2,
		x_procedure_name		 OUT NOCOPY VARCHAR2,
		x_usage				 OUT NOCOPY VARCHAR2);

  FUNCTION Update_Allowed(p_chr_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE Initialize(x_chrv_tbl OUT NOCOPY chrv_tbl_type);
  PROCEDURE Initialize(x_clev_tbl OUT NOCOPY clev_tbl_type);
  PROCEDURE Initialize(x_cpsv_tbl OUT NOCOPY cpsv_tbl_type);
  PROCEDURE Initialize(x_cacv_tbl OUT NOCOPY cacv_tbl_type);
  PROCEDURE Initialize(x_gvev_tbl OUT NOCOPY gvev_tbl_type);
  PROCEDURE Initialize(x_cvmv_tbl OUT NOCOPY cvmv_tbl_type);

  FUNCTION Increment_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2;

-- Added for Bug.No.1789860 Function Get_concat_line_nos added in OKC_CONTRACT_PVT
  FUNCTION Get_concat_line_no(p_cle_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

 -- GCHADHA --
 -- FIX FOR BUG 4314347 --

    PROCEDURE  UPDATE_LINES(p_id in number,
        p_sts_code in varchar2,
        p_new_ste_code in VARCHAR2,
        p_old_ste_code in VARCHAR2,
        p_ste_code in VARCHAR2,
        x_return_status OUT NOCOPY BOOLEAN);

  -- END GCHADHA --


END OKC_CONTRACT_PUB;

 

/
