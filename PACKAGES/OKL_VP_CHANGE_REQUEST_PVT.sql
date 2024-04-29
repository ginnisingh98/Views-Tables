--------------------------------------------------------
--  DDL for Package OKL_VP_CHANGE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_CHANGE_REQUEST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVCRS.pls 120.1 2005/09/19 07:31:20 sjalasut noship $ */

  SUBTYPE vcrv_rec_type IS okl_vcr_pvt.vcrv_rec_type;
  SUBTYPE vrrv_rec_type IS okl_vrr_pvt.vrrv_rec_type;
  SUBTYPE vrrv_tbl_type IS okl_vrr_pvt.vrrv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_VP_CHANGE_REQUEST_PVT';
  G_APP_NAME       CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';
  G_REQUIRED_VALUE CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_change_request_header
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_change_request_header
  -- Description     : handles creation of change request header for Operating Agreement and Program Agreement
  -- Parameters      : IN p_vcrv_rec vcrv_rec_type
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE create_change_request_header(p_api_version   IN  NUMBER
                                        ,p_init_msg_list IN  VARCHAR2
                                        ,x_return_status OUT NOCOPY VARCHAR2
                                        ,x_msg_count     OUT NOCOPY NUMBER
                                        ,x_msg_data      OUT NOCOPY VARCHAR2
                                        ,p_vcrv_rec      IN  vcrv_rec_type
                                        ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                         );

  -------------------------------------------------------------------------------
  -- PROCEDURE update_change_request_header
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_change_request_header
  -- Description     : handles updation of change request header for Operating Agreement and Program Agreement
  -- Parameters      : IN p_vcrv_rec vcrv_rec_type
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE update_change_request_header(p_api_version   IN  NUMBER
                                        ,p_init_msg_list IN  VARCHAR2
                                        ,x_return_status OUT NOCOPY VARCHAR2
                                        ,x_msg_count     OUT NOCOPY NUMBER
                                        ,x_msg_data      OUT NOCOPY VARCHAR2
                                        ,p_vcrv_rec      IN  vcrv_rec_type
                                        ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                         );

  -------------------------------------------------------------------------------
  -- PROCEDURE create_change_request_lines
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_change_request_lines
  -- Description     : handles creation of change request reasons for Operating Agreement and Program Agreement
  -- Parameters      : IN p_vrrv_tbl vrrv_tbl_type
  --                   OUT x_request_status is the status code of the change request header. if this api is being
  --                   called after the change is request passes validation, then this status is set to
  --                   INCOMPLETE. for all other cases the status from the database is returned
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE create_change_request_lines(p_api_version   IN  NUMBER
                                       ,p_init_msg_list IN  VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vrrv_tbl      IN  vrrv_tbl_type
                                       ,x_vrrv_tbl      OUT NOCOPY vrrv_tbl_type
                                       ,x_request_status OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        );

  -------------------------------------------------------------------------------
  -- PROCEDURE update_change_request_lines
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_change_request_lines
  -- Description     : handles updation of change request reasons for Operating Agreement and Program Agreement
  -- Parameters      : IN p_vrrv_tbl vrrv_tbl_type
  --                   OUT x_request_status is the status code of the change request header. if this api is being
  --                   called after the change is request passes validation, then this status is set to
  --                   INCOMPLETE. for all other cases the status from the database is returned
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE update_change_request_lines(p_api_version   IN  NUMBER
                                       ,p_init_msg_list IN  VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vrrv_tbl      IN  vrrv_tbl_type
                                       ,x_vrrv_tbl      OUT NOCOPY vrrv_tbl_type
                                       ,x_request_status OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        );

  -------------------------------------------------------------------------------
  -- PROCEDURE delete_change_request_lines
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_change_request_lines
  -- Description     : handles deletion of change request reasons for Operating Agreement and Program Agreement
  -- Parameters      : IN p_vrrv_tbl vrrv_tbl_type
  --                   OUT x_request_status is the status code of the change request header. if this api is being
  --                   called after the change is request passes validation, then this status is set to
  --                   INCOMPLETE. for all other cases the status from the database is returned
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE delete_change_request_lines(p_api_version   IN  NUMBER
                                       ,p_init_msg_list IN  VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vrrv_tbl      IN  vrrv_tbl_type
                                       ,x_request_status OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        );

  -------------------------------------------------------------------------------
  -- PROCEDURE create_change_request
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_change_request
  -- Description     : handles creation of change request for Operating Agreement and Program Agreement
  --                   change request implies one header and multiple reason lines
  -- Parameters      : IN p_vcrv_rec vcrv_rec_type
  --                   IN p_vrrv_tbl vrrv_tbl_type
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE create_change_request(p_api_version   IN  NUMBER
                                 ,p_init_msg_list IN  VARCHAR2
                                 ,x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count     OUT NOCOPY NUMBER
                                 ,x_msg_data      OUT NOCOPY VARCHAR2
                                 ,p_vcrv_rec      IN  vcrv_rec_type
                                 ,p_vrrv_tbl      IN  vrrv_tbl_type
                                 ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                 ,x_vrrv_tbl      OUT NOCOPY vrrv_tbl_type
                                  );

  -------------------------------------------------------------------------------
  -- PROCEDURE abandon_change_request
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : abandon_change_request
  -- Description     : procedure abandons change requests for Operating Agreement and Program Agreement
  --                   that have not been sent for approval
  -- Parameters      : IN p_vcrv_rec vcrv_rec_type
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE abandon_change_request(p_api_version   IN  NUMBER
                                  ,p_init_msg_list IN  VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_vcrv_rec      IN  vcrv_rec_type
                                  ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                   );

  -------------------------------------------------------------------------------
  -- PROCEDURE set_change_request_status
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_change_request_status
  -- Description     : procedure updates change requests status for Operating Agreement and Program Agreement
  --                   the status change is required whenever the change request transitions to a state
  --                   For an AGREEMENT type of change request, the change request status is passed on to the
  --                   copied agreement
  -- Parameters      : IN p_vp_crq_id okl_vp_change_requests.id%TYPE
  --                   IN p_status_code okl_vp_change_requests.status_code%TYPE;
  --                      NO OUT parameters, if the x_return_status = OKL_API.G_RET_STS_SUCCESS then
  --                   the effective status of the change request is the passed in status code value
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE set_change_request_status(p_api_version   IN NUMBER
                                     ,p_init_msg_list IN VARCHAR2
                                     ,x_return_status OUT NOCOPY VARCHAR2
                                     ,x_msg_count     OUT NOCOPY NUMBER
                                     ,x_msg_data      OUT NOCOPY VARCHAR2
                                     ,p_vp_crq_id     IN okl_vp_change_requests.id%TYPE
                                     ,p_status_code   IN okl_vp_change_requests.status_code%TYPE
                                      );

  -------------------------------------------------------------------------------
  -- PROCEDURE cascade_request_status_edit
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : cascade_request_status_edit
  -- Description     : procedure updates change requests header status for Operating Agreement and Program Agreement
  --                   to INCOMPLETE when a PASSED agreement is updated
  -- Parameters      : IN p_vp_crq_id change request header id
  --                   OUT x_status_code the effective status of the change request
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE cascade_request_status_edit(p_api_version   IN NUMBER
                                       ,p_init_msg_list IN VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vp_crq_id     IN okl_vp_change_requests.id%TYPE
                                       ,x_status_code   OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        );

  -------------------------------------------------------------------------------
  -- PROCEDURE submit_cr_for_approval
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_cr_for_approval
  -- Description     : procedure raises business events for agreement change request approval.
  --                   if the profile option OKL: Change Request Approval Process is set to NULL or NONE
  --                   this API then also synchronizes the changes on the copied agreement on to the
  --                   original agreement and updates the change request
  -- Parameters      : IN p_chr_id agreement id which is tied to the change request
  --                   OUT x_status_code the effective status of the change request
  -- Version         : 1.0
  -- History         : 26-APR-2005 SJALASUT created
  -- End of comments

  PROCEDURE submit_cr_for_approval(p_api_version   IN NUMBER
                                  ,p_init_msg_list IN VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                  ,x_status_code   OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                  );

  -------------------------------------------------------------------------------
  -- FUNCTION get_assoc_agr_number
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_assoc_agr_number
  -- Description     : function returns the assocaited agreement number with this change request
  --                   if the change request is of type AGREEMENT, then the agreement number is
  --                   determined by the okl_k_headers  record that contains this change request id
  -- Parameters      : IN p_change_request_id id from okl_vp_change_requests table
  --                   returns contract_number of okc_k_headers_b
  -- Version         : 1.0
  -- History         : 18-SEP-2005 SJALASUT created
  -- End of comments

  FUNCTION get_assoc_agr_number(p_change_request_id IN okl_vp_change_requests.id%TYPE) RETURN VARCHAR2;

  -------------------------------------------------------------------------------
  -- FUNCTION get_assoc_agr_id
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_assoc_agr_id
  -- Description     : function returns the assocaited agreement id with this change request
  --                   if the change request is of type AGREEMENT, then the agreement id is
  --                   determined by the okl_k_headers record that contains this change request id
  -- Parameters      : IN p_change_request_id id from okl_vp_change_requests table
  --                   returns id of okc_k_headers_b
  -- Version         : 1.0
  -- History         : 18-SEP-2005 SJALASUT created
  -- End of comments

  FUNCTION get_assoc_agr_id(p_change_request_id IN okl_vp_change_requests.id%TYPE) RETURN NUMBER;

END okl_vp_change_request_pvt;

 

/
