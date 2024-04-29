--------------------------------------------------------
--  DDL for Package OKL_XMLP_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XMLP_PARAMS_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRXMPS.pls 120.1 2007/01/04 14:51:29 udhenuko noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME                  CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT   VARCHAR2(200) := 'OKL_XMLP_PARAMS_PVT';
  G_API_TYPE		            CONSTANT VARCHAR2(4) := '_PVT';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;


SUBTYPE xmp_rec_type IS okl_xmp_pvt.xmp_rec_type ;
SUBTYPE xmp_tbl_type IS okl_xmp_pvt.xmp_tbl_type ;
---------------------------------------------------------------------------
-- Procedures and Functions
---------------------------------------------------------------------------
 ----------------------------------------------------------------------------
 -- PROCEDURE create_xmlp_params_rec
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_xmlp_params_rec
  -- Description     : procedure for inserting the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure creates a record containing the parameter
  --                   name, value and type code. x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec, x_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE create_xmlp_params_rec     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_rec         IN  xmp_rec_type
                                 ,x_xmp_rec         OUT NOCOPY xmp_rec_type
                                );

----------------------------------------------------------------------------
 -- PROCEDURE create_xmlp_params_tbl
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_xmlp_params_tbl
  -- Description     : procedure for inserting the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure creates a record containing the parameter
  --                   name, value and type code. x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_tbl, x_xmp_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE create_xmlp_params_tbl     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_tbl         IN  xmp_tbl_type
                                 ,x_xmp_tbl         OUT NOCOPY xmp_tbl_type
                                );

 -----------------------------------------------------------------------------
 -- PROCEDURE update_xmlp_params_rec
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_xmlp_params_rec
  -- Description     : procedure for updating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure updates a record based on the id provided.
  --                   x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec, x_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_xmlp_params_rec     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_rec         IN  xmp_rec_type
                                 ,x_xmp_rec         OUT NOCOPY xmp_rec_type
                                );

-----------------------------------------------------------------------------
 -- PROCEDURE update_xmlp_params_tbl
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_xmlp_params_tbl
  -- Description     : procedure for updating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure updates a record based on the id provided.
  --                   x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_tbl, x_xmp_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_xmlp_params_tbl     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_tbl         IN  xmp_tbl_type
                                 ,x_xmp_tbl         OUT NOCOPY xmp_tbl_type
                                );

 ----------------------------------------------------------------------------
 -- PROCEDURE delete_xmlp_params_rec
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_xmlp_params_rec
  -- Description     : procedure for deleting the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure deletes a record based on the id provided.
  --                   x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec, x_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE delete_xmlp_params     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_batch_id         IN  OKL_XMLP_PARAMS.Batch_Id%TYPE
                                );


 ---------------------------------------------------------------------------
 -- PROCEDURE validate_xmlp_params_rec
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_xmlp_params_rec
  -- Description     : procedure for validating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : Validates the record passed to it. x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE validate_xmlp_params_rec( p_api_version     IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2,
                            p_xmp_rec            IN  xmp_rec_type);

 ---------------------------------------------------------------------------
 -- PROCEDURE validate_xmlp_params_tbl
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_xmlp_params_tbl
  -- Description     : procedure for validating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : Validates the records passed to it. x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE validate_xmlp_params_tbl( p_api_version     IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2,
                            p_xmp_tbl            IN  xmp_tbl_type);

END OKL_XMLP_PARAMS_PVT;

/
