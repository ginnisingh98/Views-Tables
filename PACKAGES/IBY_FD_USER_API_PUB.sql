--------------------------------------------------------
--  DDL for Package IBY_FD_USER_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FD_USER_API_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyfduas.pls 120.7.12010000.7 2010/09/01 16:20:37 gmaheswa ship $*/

--
-- Declaring Global variables
--
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_FD_USER_API_PUB';

--
-- module name used for the application debugging framework
--
G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FD_USER_API_PUB';


Type Int_Bank_Acc_Tab_Type is Table of NUMBER INDEX by BINARY_INTEGER;

Type Legal_Entity_Tab_Type is Table of NUMBER INDEX by BINARY_INTEGER;

Type Org_Rec_Type is Record(
   org_id number,
   org_type varchar2(30)
);

Type Org_Tab_Type is Table of Org_Rec_Type INDEX by BINARY_INTEGER;

Type Currency_Tab_Type is Table of VARCHAR2(10) INDEX by BINARY_INTEGER;

PROCEDURE Validate_Method_and_Profile (
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_payment_method_code      IN   VARCHAR2,
     p_ppp_id                   IN   NUMBER,
     p_payment_document_id      IN   NUMBER,
     p_crt_instr_flag           IN   VARCHAR2,
     p_int_bank_acc_arr         IN   Int_Bank_Acc_Tab_Type,
     p_le_arr                   IN   Legal_Entity_Tab_Type,
     p_org_arr                  IN   Org_Tab_Type,
     p_curr_arr                 IN   Currency_Tab_Type,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2
);

FUNCTION Payment_Instruction_Action (
     p_instruction_status       IN   VARCHAR2
) RETURN VARCHAR2;

FUNCTION Pmt_Instr_Terminate_Enabled (
     p_instruction_status       IN   VARCHAR2,
     p_instruction_id           IN   NUMBER,
     p_request_id               IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2;

FUNCTION Instr_Sec_Terminate_Enabled (
     p_instruction_status       IN   VARCHAR2,
     p_org_id                   IN   NUMBER,
     p_instruction_id           IN   NUMBER,
     p_request_id               IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2;

FUNCTION Pmt_Instr_Action_Enabled (
     p_instruction_status       IN   VARCHAR2,
     p_org_id                   IN   NUMBER,
     p_instruction_id           IN   NUMBER,
     p_request_id               IN   NUMBER  DEFAULT NULL
) RETURN VARCHAR2;

PROCEDURE retrieve_default_sra_format(
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_instr_id                 IN   NUMBER,
     x_default_sra_format_code  OUT  NOCOPY VARCHAR2,
     x_default_sra_format_name  OUT  NOCOPY VARCHAR2,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2
);

FUNCTION Is_Pmt_Instr_Complete (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2;


FUNCTION Pmt_Instr_Terminate_Allowed (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2;

FUNCTION Pmt_Instr_Sec_Term_Allowed (
     p_instruction_status       IN   VARCHAR2,
     p_process_type             IN   VARCHAR2,
     p_instruction_id           IN   NUMBER,
     p_org_id                   IN   NUMBER,
     p_pmt_complete_code        IN   VARCHAR2,
     p_request_id               IN   NUMBER DEFAULT NULL,
     p_msg_req                  IN   VARCHAR2 DEFAULT 'Y'
) RETURN VARCHAR2;

FUNCTION PPR_Sec_Term_Allowed (
     p_pay_service_req_id  IN   NUMBER
) RETURN VARCHAR2;

FUNCTION Is_transmitted_Pmt_Inst_Compl (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2;

END IBY_FD_USER_API_PUB;

/
