--------------------------------------------------------
--  DDL for Package OKS_MASSCHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_MASSCHANGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRMASS.pls 120.2 2007/12/07 09:03:57 mkarra ship $ */


     ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_TRUE                       CONSTANT VARCHAR2(1)   :=  OKC_API.G_TRUE;
  G_FALSE                      CONSTANT VARCHAR2(1)   :=  OKC_API.G_FALSE;
  G_RET_STS_SUCCESS	       CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR	       CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) :=  OKC_API.G_PARENT_TABLE_TOKEN;
  G_NO_PARENT_RECORD	       CONSTANT VARCHAR2(200) := 'OKS_NO_PARENT_RECORD';
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) :=  OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED         CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';


    ---------------------------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME	                CONSTANT VARCHAR2(200) := 'OKS_MASSCHANGE_PVT';
  G_APP_NAME_OKS	        CONSTANT VARCHAR2(3)   := 'OKS';
  G_APP_NAME_OKC	        CONSTANT VARCHAR2(3)   := 'OKC';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_NOT_SELECTED	        CONSTANT VARCHAR2(200) := 'NOT_SELECTED';
  G_SELECTED		        CONSTANT VARCHAR2(200) := 'SELECTED';
  G_PROCESSED		        CONSTANT VARCHAR2(200) := 'PROCESSED';
  G_REJECTED		        CONSTANT VARCHAR2(200) := 'REJECTED';
  G_INVALID_OL		        CONSTANT VARCHAR2(200) := 'INVALID_OL';
  G_OI_STATUS_CODE	        CONSTANT VARCHAR2(200) := 'SAVED';
  G_REQUEST_ID                  CONSTANT NUMBER        := FND_GLOBAL.CONC_REQUEST_ID;
  G_PROGRAM_APPLICATION_ID      CONSTANT NUMBER        := FND_GLOBAL.PROG_APPL_ID;
  G_PROGRAM_ID                  CONSTANT NUMBER        := FND_GLOBAL.CONC_PROGRAM_ID;
  ---------------------------------------------------------------------------

  TYPE criteria_rec_type IS RECORD
		(oie_id               Number,
                 update_level         Varchar2(100),
		 update_level_value   Varchar2(100),
		 attribute            Varchar2(100),
		 old_value            Varchar2(240),
                 new_value            Varchar2(240),
		 ORG_ID 	      Number);

  TYPE opr_instance_rec_type IS RECORD
		(oie_id              Number,
                name                 Varchar2(150),
                status_code          Varchar2(50),
                update_level         Varchar2(100),
		update_level_value   Varchar2(100));
-- /*
-- subtype masschange_request_rec_type is OKC_OPER_INST_PUB.mrdv_rec_type;
-- subtype masschange_request_tbl_type is OKC_OPER_INST_PUB.mrdv_tbl_type;
-- */

 TYPE masschange_request_rec_type IS RECORD
		(id                  Number,
         	oie_id               Number,
         	ole_id               Number,
		attribute_name       Varchar2(100),
		old_value            Varchar2(240),
         	new_value            Varchar2(240),
         	qa_check_yn          Varchar2(3));

  TYPE ole_rec_type IS RECORD
        (id                   Number,
         oie_id               Number,
         chr_id               Number,
         process_flag         Varchar2(3),
         select_yn            Varchar2(1));

  TYPE ole_tbl_type IS TABLE OF ole_rec_type INDEX BY BINARY_INTEGER;

-- /*
--  subtype oiev_rec_type is OKC_OPER_INST_PUB.oiev_rec_type;
--  subtype oiev_tbl_type is OKC_OPER_INST_PUB.oiev_tbl_type;
--  subtype olev_rec_type is OKC_OPER_INST_PUB.olev_rec_type;
--  subtype olev_tbl_type is OKC_OPER_INST_PUB.olev_tbl_type;
--  subtype mrdv_rec_type is OKC_OPER_INST_PUB.mrdv_rec_type;
--  subtype mrdv_tbl_type is OKC_OPER_INST_PUB.mrdv_tbl_type;
-- */


  TYPE eligible_contract_rec IS RECORD
		(contract_id              Number,
		 contract_number          Varchar2(120),
		 contract_number_modifier Varchar2(120),
		 short_description        Varchar2(600),
		 start_date               Date,
		 end_date                 Date,
		 party                    okx_parties_v.name%type,
		 old_value                Varchar2(240),
		 contract_status          Varchar2(50),
                 process_flag             Varchar2(3) ,
                 qcl_id                   Number,
                 object_version_number    Number,
                 ole_id                   Number,
                 org_id                   Number,
                 qa_check_yn              Varchar2(3)  ,
                 operating_unit           VArchar2(240) ,
		 billed_at_source         Varchar2(2));

  TYPE eligible_contracts_tbl IS TABLE of eligible_contract_rec INDEX BY BINARY_INTEGER;

  TYPE masschg_contract_rec IS RECORD
		(contract_id              Number,
		 subject_chr_id           Number);
  TYPE masschg_contracts_tbl IS TABLE of masschg_contract_rec INDEX BY BINARY_INTEGER;

  subtype chrv_tbl_type is okc_contract_pub.chrv_tbl_type;

  --PROCEDURES and FUNCTIONS

  PROCEDURE get_eligible_contracts
	(p_api_version		     IN  Number
	,p_init_msg_list	     IN  Varchar2
	,p_ctr_rec	             IN  criteria_rec_type
        ,p_query_type                IN  Varchar2 DEFAULT 'FETCH'
        ,p_upg_orig_system_ref       IN  Varchar2
	,x_return_status 	     OUT NOCOPY Varchar2
	,x_msg_count		     OUT NOCOPY Number
	,x_msg_data		     OUT NOCOPY Varchar2
	,x_eligible_contracts	     OUT NOCOPY eligible_contracts_tbl);


 PROCEDURE LOCK_CONTRACT_HEADER(p_header_id IN NUMBER,
                                p_object_version_number IN NUMBER,
                                x_return_status OUT NOCOPY Varchar2);

 PROCEDURE UPDATE_CONTRACT(p_chrv_rec       IN  okc_contract_pub.chrv_rec_type,
                           x_return_status  OUT NOCOPY VARCHAR2);

 PROCEDURE LOG_MESSAGES(p_mesg IN VARCHAR2);

  FUNCTION SUBMIT_CONC_FORM(p_oie_id        IN NUMBER,
                            p_process_type  IN VARCHAR2,
                            p_schedule_time IN VARCHAR2,
                            p_check_yn      IN VARCHAR2)
  RETURN NUMBER;

 PROCEDURE SUBMIT_CONC(ERRBUF                         OUT NOCOPY VARCHAR2,
                       RETCODE                        OUT NOCOPY NUMBER,
                       p_oie_id                       IN NUMBER,
                       p_process_type                 IN VARCHAR2,
                       p_check_yn                     IN VARCHAR2);

 PROCEDURE SUBMIT(ERRBUF                         OUT NOCOPY VARCHAR2,
                  RETCODE                        OUT NOCOPY NUMBER,
                  p_api_version                  IN  NUMBER,
                  p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                  x_return_status                OUT NOCOPY VARCHAR2,
                  x_msg_count                    OUT NOCOPY NUMBER,
                  x_msg_data                     OUT NOCOPY VARCHAR2,
                  p_conc_program                 IN  VARCHAR2,
         	  p_process_type                 IN  Varchar2,
                  p_oie_id                       IN  NUMBER,
                  p_check_yn                     IN  Varchar2 );

 PROCEDURE Notify_completion(p_process_type    IN Varchar2,
                             p_req_id          IN Number,
                             p_masschange_name IN Varchar2);

 PROCEDURE SUBMIT_MASSCHANGE(ERRBUF                         OUT NOCOPY VARCHAR2,
                             RETCODE                        OUT NOCOPY NUMBER,
                             p_oie_id                       IN NUMBER,
                             p_check_yn                     IN  Varchar2);

 PROCEDURE PREVIEW_MASSCHANGE(ERRBUF                         OUT NOCOPY VARCHAR2,
                              RETCODE                        OUT NOCOPY NUMBER,
                              p_oie_id                       IN NUMBER,
                              p_check_yn                     IN  Varchar2);

--/*PROCEDURE CREATE_OPERATION_INSTANCES (p_oie_rec  IN OKS_MASSCHANGE_PVT.opr_instance_rec_type,
--                                       x_oie_id   OUT NOCOPY NUMBER);
--*/

PROCEDURE CREATE_OPERATION_INSTANCES (p_oie_rec  IN opr_instance_rec_type,
                                      p_mrd_rec  IN masschange_request_rec_type,
                                      x_oie_id   OUT NOCOPY NUMBER);

PROCEDURE UPDATE_OPERATION_INSTANCES (p_oie_rec  IN opr_instance_rec_type,
                                      p_mrd_rec  IN masschange_request_rec_type,
                                      x_return_status OUT NOCOPY Varchar2);

PROCEDURE DELETE_OPERATION_INSTANCES (p_oie_rec  IN opr_instance_rec_type,
                                      x_return_status OUT NOCOPY Varchar2);

PROCEDURE CREATE_MASSCHANGE_LINE_DTLS(p_omr_rec  IN masschange_request_rec_type,
                                     x_omr_id   OUT NOCOPY NUMBER);
PROCEDURE CREATE_OPERATION_LINES (p_ole_tbl IN ole_tbl_type, --olev_tbl_type,
                                  x_ole_tbl OUT NOCOPY OKC_OPER_INST_PUB.olev_tbl_type);

PROCEDURE UPDATE_OPERATION_LINES(p_ole_id IN NUMBER,
                                 p_select_yn IN VARCHAR2,
                                 p_qa_check_yn IN VARCHAR2 ) ;


PROCEDURE DELETE_OPERATION_LINES (p_oie_id IN Number,
                                  x_return_status OUT NOCOPY Varchar2);

PROCEDURE get_attribute_value(p_attr_code IN Varchar2,
                                 p_attr_id IN Varchar2,
                                 p_org_id   IN Number,
                                 x_attr_value OUT NOCOPY Varchar2,
                                 x_attr_name  OUT NOCOPY Varchar2);

PROCEDURE Create_Mschg_Class_Operation;



PROCEDURE UPDATE_LINE_STATUS(p_oie_id IN Number);
PROCEDURE UPDATE_QA_CHECK_YN_COL ;

END OKS_MASSCHANGE_PVT;

/
