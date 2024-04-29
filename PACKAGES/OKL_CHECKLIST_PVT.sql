--------------------------------------------------------
--  DDL for Package OKL_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CHECKLIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCKLS.pls 120.5 2006/04/03 06:05:33 pagarg noship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKL_CHECKLIST_PVT';
 G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
 G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
 G_RET_STS_ERROR		       CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
 G_EXCEPTION_ERROR		 EXCEPTION;
 G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

 G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
 G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
 G_LLA_RANGE_CHECK            CONSTANT VARCHAR2(30) := 'OKL_LLA_RANGE_CHECK';
 G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;

 G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
 G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';

 G_UPDATE_MODE                CONSTANT VARCHAR2(30) := 'UPDATE_MODE';
 G_INSERT_MODE                CONSTANT VARCHAR2(30) := 'INSERT_MODE';
 G_CHECKLIST_TYPE_LOOKUP_TYPE CONSTANT VARCHAR2(30) := 'OKL_CHECKLIST_TYPE';

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
  subtype clhv_rec_type is OKL_CLH_pvt.clhv_rec_type;
  subtype clhv_tbl_type is OKL_CLH_pvt.clhv_tbl_type;
  subtype cldv_rec_type is OKL_CLD_pvt.cldv_rec_type;
  subtype cldv_tbl_type is OKL_CLD_pvt.cldv_tbl_type;

 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_hdr
-- Description     : wrapper api for create checklist header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_hdr
-- Description     : wrapper api for update checklist template header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_hdr
-- Description     : wrapper api for delete checklist template header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_dtl
-- Description     : wrapper api for create checklist details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_hdr
-- Description     : wrapper api for update checklist template details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_dtl
-- Description     : wrapper api for delete checklist template details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
 );

-- START: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : submit_for_approval
-- Description     : Submit a checklst for approval
-- Business Rules  : 1. System will update status to 'Active' for object itself
--                      and all associate checklist if applicable.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE submit_for_approval(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_status_code                  OUT NOCOPY VARCHAR2
   ,p_clh_id                       IN  NUMBER
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_inst_hdr
-- Description     : wrapper api for create checklist instance header
-- Business Rules  :
--                   1. END_DATE is required
--                   2. CHECKLIST_OBJ_ID and CHECKLIST_OBJ_TYPE_CODE are required
--                   3. CHECKLIST_OBJ_TYPE_CODE is referring from fnd_lookups type
--                      = 'CHECKLIST_OBJ_TYPE_CODE'
--                   4. CHECKLIST_TYPE will be defaulting to 'NONE'
--                   5. CHECKLIST_NUMBER will be defaulting to 'CHECKLIST_INSTANCE'
--                      appending system generated sequence number
--                   6. CHECKLIST_PURPOSE_CODE will be defaulting to 'CHECKLIST_INSTANCE'
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_inst_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_inst_hdr
-- Description     : wrapper api for update checklist instance header
-- Business Rules  :
--                   1. System allows to update the following columns
--                   SHORT_DESCRIPTION, DESCRIPTION, START_DATE, END_DATE, STATUS_CODE
--                   DECISION_DATE, CHECKLIST_OBJ_ID, CHECKLIST_OBJ_TYPE_CODE
--
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_inst_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_inst_hdr
-- Description     : wrapper api for delete checklist instance header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_inst_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_inst_dtl
-- Description     : wrapper api for create checklist instance details
-- Business Rules  :
--                   1. CKL_ID, TODO_ITEM_CODE, and INST_CHECKLIST_TYPE are required
--                   2. CKL_ID is referring from okl_checklists.ID as FK
--                   3. TODO_ITEM_CODE is referring from fnd_lookups type
--                      = 'OKL_TODO_ITEMS'
--                   4. INST_CHECKLIST_TYPE is referring from fnd_lookups type
--                      = 'OKL_CHECKLIST_TYPE'
--                   5. The following columns are referring from fnd_lookups type
--                      = 'OKL_YES_NO'
--                        MANDATORY_FLAG
--                        USER_COMPLETE_FLAG
--                   6. FUNCTION_VALIDATE_RSTS is referring from fnd_lookups type
--                      = 'OKL_FUN_VALIDATE_RSTS'
--                   7. System will defaulting DNZ_CHECKLIST_OBJ_ID from the
--                      corresponding okl_chekclists.CHECKLIST_OBJ_ID
--                   8. FUNCTION_ID is referring from OKL_DATA_SRC_FNCTNS_V
--                   9. MANDATORY_FLAG and USER_COMPLETE_FLAG will defult to 'N'
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_inst_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_inst_hdr
-- Description     : wrapper api for update checklist instance details
-- Business Rules  :
--                   1. System allows to update the following columns
--                   TODO_ITEM_CODE, MANDATORY_FLAG, USER_COMPLETE_FLAG
--                   ADMIN_NOTE, USER_NOTE, FUNCTION_ID, FUNCTION_VALIDATE_RSTS
--                   FUNCTION_VALIDATE_MSG, and INST_CHECKLIST_TYPE
--
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_inst_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_inst_dtl
-- Description     : wrapper api for delete checklist instance details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_inst_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : chk_eligible_for_approval
-- Description     : Check if it's eligible for approval
-- Business Rules  :
-- The following scenarios are not eligible for approval
-- 1	Checklist template (either group or individual) status is Active.
-- 2	Group checklist template doesn't have child checklist assocaite with it.
-- 3 	Group checklist template does have child checklist associate with it,
--      but child checklist doesn't have items defined.
-- 4	Checklist template does have group checklist assocaite with it (Has parent checklist).
-- 5    Checklist template doesn't have items defined.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE chk_eligible_for_approval(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clh_id                       IN  NUMBER
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_function
-- Description     : This API will execute function for each item and
--                   update the execution results for the function.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_function(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_checklist_obj_id             IN  NUMBER
 );

-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement

-- START: June 06, 2005 cklee: Modification for okl.h lease app enhancement
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_contract_checklist
-- Description     : Wrapper API for creates a checklist instance header and detail,
--                   for which the checklists copy the corresponding lease application.
-- Business Rules  :
--                   1. Create an instance of the checklist header for the contract.
--                   2. Create the detail list items for the checklist header,
--                      for which the checklist copy corresponding lease application.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_contract_checklist(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  NUMBER
 );
-- END: June 06, 2005 cklee: Modification for okl.h lease app enhancement

  ------------------------------------------------------------------------------
  -- PROCEDURE upd_chklst_dtl_apl_flag
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : upd_chklst_dtl_apl_flag
  -- Description     : This procedure updates the appeal flag for the given
  --                   table of checklist detail items
  -- Business Rules  : This procedure updates the appeal flag for the given
  --                   table of checklist detail items
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Apr-2006 PAGARG created Bug 4872271
  --
  -- End of comments
  PROCEDURE upd_chklst_dtl_apl_flag(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_cldv_tbl           IN  CLDV_TBL_TYPE,
            x_cldv_tbl           OUT NOCOPY CLDV_TBL_TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

END OKL_CHECKLIST_PVT;

/
