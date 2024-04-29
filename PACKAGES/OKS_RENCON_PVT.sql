--------------------------------------------------------
--  DDL for Package OKS_RENCON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_RENCON_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRENCS.pls 120.3.12000000.1 2007/01/16 22:10:21 appldev ship $*/
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------


 TYPE sources_rec_type IS RECORD (
    contract_id        NUMBER := OKC_API.G_MISS_NUM,
    line_id            NUMBER := OKC_API.G_MISS_NUM,
    subline_id         NUMBER := OKC_API.G_MISS_NUM,
    operation_lines_id NUMBER := OKC_API.G_MISS_NUM,
    parent_ole_id      NUMBER := OKC_API.G_MISS_NUM,
    oie_id             NUMBER := OKC_API.G_MISS_NUM,
    select_yn          VARCHAR2(3),
    ol_status          VARCHAR2(200));

 TYPE sources_tbl_type IS TABLE OF sources_rec_type INDEX BY BINARY_INTEGER;

 TYPE merge_rec_type IS RECORD (
    line_id             NUMBER,
    inventory_item_id   VARCHAR2(200),
    inv_organization_id VARCHAR2(200),
    lrt_rule            VARCHAR2(200),
    bto_id              VARCHAR2(200),
    start_date          DATE,
    end_date            DATE);

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;

  G_REQUIRED_VALUE      CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED  CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  G_PROGRAM_NAME        CONSTANT VARCHAR2(200) := 'OKS_RENCON_PVT';
  G_OKS_APP_NAME        CONSTANT VARCHAR2(3) := 'OKS'; --all new nessages should use this

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_REQUEST_ID             CONSTANT NUMBER        := FND_GLOBAL.CONC_REQUEST_ID;
  G_PROGRAM_APPLICATION_ID CONSTANT NUMBER        := FND_GLOBAL.PROG_APPL_ID;
  G_PROGRAM_ID             CONSTANT NUMBER        := FND_GLOBAL.CONC_PROGRAM_ID;
  G_PKG_NAME               CONSTANT VARCHAR2(200) := 'OKS_RENCON_PVT';
  G_APP_NAME               CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_NOT_SELECTED           CONSTANT VARCHAR2(200) := 'NOT_SELECTED';
  G_SELECTED               CONSTANT VARCHAR2(200) := 'SELECTED';
  G_PROCESSED              CONSTANT VARCHAR2(200) := 'PROCESSED';
  G_REJECTED               CONSTANT VARCHAR2(200) := 'REJECTED';
  G_INVALID_OL             CONSTANT VARCHAR2(200) := 'INVALID_OL';
  G_OI_STATUS_CODE         CONSTANT VARCHAR2(200) := 'ENTERED';
  G_TARGET_VALID           CONSTANT VARCHAR2(200) := 'C';
  G_TARGET_INVALID         CONSTANT VARCHAR2(200) := 'S';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE GET_VALID_OPER_LINE_SOURCES (p_target_id     IN  NUMBER,
                                         x_sources_tbl   OUT NOCOPY sources_tbl_type,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                         p_conc_program  IN VARCHAR2,
                                         p_select_yn     IN VARCHAR2 DEFAULT 'N');

  PROCEDURE GET_VALID_LINE_SOURCES (p_target_id     IN  NUMBER,
                                    x_sources_tbl   OUT NOCOPY sources_tbl_type,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    p_conc_program  IN VARCHAR2,
                                    p_select_yn     IN VARCHAR2 DEFAULT 'N');

  PROCEDURE CREATE_OPERATION_INSTANCES (p_target_chr_id IN NUMBER,
                                        p_oie_id out NOCOPY NUMBER);

  PROCEDURE CREATE_OPERATION_LINES (p_target_chr_id IN NUMBER,
                                    p_oie_id IN NUMBER,
                                    p_sources_tbl_type IN OUT NOCOPY OKS_RENCON_PVT.sources_tbl_type,
                                    p_select_yn IN VARCHAR2 DEFAULT 'N');

  FUNCTION FIND_OL_STATUS(p_object_cle_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION IS_VALID_TARGET(p_target_id IN NUMBER) RETURN BOOLEAN;

  FUNCTION GET_PARENT_LINE_ID(p_parent_ole_id IN NUMBER) RETURN NUMBER;

  FUNCTION GET_LRT_RULE(p_line_id IN NUMBER) RETURN VARCHAR2;

  PROCEDURE GET_LINE_DETAILS(p_line_id IN NUMBER, x_line_details OUT NOCOPY OKS_RENCON_PVT.merge_rec_type);

  FUNCTION MERGE_ELIGIBLE_YN(p_source_line_details IN  OKS_RENCON_PVT.merge_rec_type,
                             p_target_line_details IN  OKS_RENCON_PVT.merge_rec_type) RETURN VARCHAR2;

  PROCEDURE MERGE(p_source_line_id IN NUMBER,
                  p_target_contract_id IN NUMBER,
                  x_target_line_id OUT NOCOPY NUMBER);

  PROCEDURE SUBMIT_CONC(ERRBUF                         OUT NOCOPY VARCHAR2,
                        RETCODE                        OUT NOCOPY NUMBER,
                        p_oie_id                       IN NUMBER);

  FUNCTION SUBMIT_FORM_CONC(p_oie_id                       IN NUMBER) RETURN NUMBER;

  PROCEDURE SUBMIT(ERRBUF                         OUT NOCOPY VARCHAR2,
                   RETCODE                        OUT NOCOPY NUMBER,
                   p_api_version                  IN NUMBER,
                   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                   x_return_status                OUT NOCOPY VARCHAR2,
                   x_msg_count                    OUT NOCOPY NUMBER,
                   x_msg_data                     OUT NOCOPY VARCHAR2,
                   p_conc_program                 IN VARCHAR2,
                   p_oie_id                       IN NUMBER);

  PROCEDURE UPDATE_CONTRACT_AMOUNT(p_header_id IN NUMBER,
                                   x_return_status  OUT NOCOPY VARCHAR2);


  PROCEDURE LOG_MESSAGES(p_mesg IN VARCHAR2);

END OKS_RENCON_PVT;

 

/
