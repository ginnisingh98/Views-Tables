--------------------------------------------------------
--  DDL for Package OKC_TERMS_QA_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_QA_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGDQAS.pls 120.1 2006/06/20 21:58:34 rvohra noship $ */

    TYPE qa_result_rec_type IS RECORD (
        Document_type        VARCHAR2(30),
        Document_id          NUMBER,
        Sequence_id          NUMBER,
        Error_record_type    VARCHAR2(30),
        Title                VARCHAR2(240),
        Article_ID           NUMBER,
        Deliverable_Id       NUMBER,
        Section_Name         VARCHAR2(240),
        Error_severity       VARCHAR2(1),
        QA_Code              VARCHAR2(30),
        Message_name         VARCHAR2(30),
        Problem_short_desc   VARCHAR2(2000),
        Problem_details      VARCHAR2(2000),
        Problem_details_short      VARCHAR2(2000),
        Suggestion           VARCHAR2(2000),
        Creation_date        DATE,
        Reference_Column1    VARCHAR2(2000),
        Reference_Column2    VARCHAR2(2000),
        Reference_Column3    VARCHAR2(2000),
        Reference_Column4    VARCHAR2(2000),
        Reference_Column5    VARCHAR2(2000),
        error_record_type_name Varchar2(2000),
        error_severity_name    Varchar2(2000)
        );

    TYPE qa_result_tbl_type IS TABLE OF qa_result_rec_type INDEX BY BINARY_INTEGER;

    -- declaring record type for deliverable due date events
    TYPE BUSDOCDATES_REC_TYPE IS RECORD (
        event_code      VARCHAR2(30),
        event_date      DATE
        );

    -- declaring table of records
    TYPE BUSDOCDATES_TBL_TYPE IS TABLE OF BUSDOCDATES_REC_TYPE INDEX BY BINARY_INTEGER;


    ---------------------------------------------------------------------------
    -- GLOBAL CONSTANTS
    ---------------------------------------------------------------------------

    G_NORMAL_QA             CONSTANT VARCHAR2(30) :=  'NORMAL';
    G_AMEND_QA              CONSTANT VARCHAR2(30) :=  'AMEND';

    G_QA_STS_SUCCESS             CONSTANT   varchar2(1) := 'S';
    G_QA_STS_ERROR               CONSTANT   varchar2(1) := 'E';
    G_QA_STS_WARNING             CONSTANT   varchar2(1) := 'W';


    /* version 1, logs valiation messages in OKC_QA_ERRORS_T table
    returns x_sequence_id as out parameter
    11.5.10+ : Modified to accept addtional in parameter p_validation_level
               p_commit DEFAULT FND_API.G_TRUE added to ensure backward compatibility,
                pass as FND_API.G_FALSE if do not want to commit changes
    */
    PROCEDURE QA_Doc     (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_qa_mode           IN  VARCHAR2 DEFAULT G_NORMAL_QA,
        p_doc_type          IN  VARCHAR2,
        p_doc_id            IN  NUMBER,

        x_sequence_id       OUT NOCOPY NUMBER,
        x_qa_return_status  OUT NOCOPY VARCHAR2,
        p_qa_terms_only     IN VARCHAR2 DEFAULT 'N',
        p_validation_level  IN VARCHAR2 DEFAULT 'A',
        p_commit			IN	VARCHAR2 DEFAULT FND_API.G_TRUE,
	   p_run_expert_flag   IN VARCHAR2 DEFAULT 'Y'           -- Bug 5186245
        );

    /* version 2, does not log valiation messages in OKC_QA_ERRORS_T table
    returns x_qa_result_tbl as out parameter
    11.5.10+: No modification
    */
    PROCEDURE QA_Doc     (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_qa_mode           IN  VARCHAR2 DEFAULT G_NORMAL_QA,
        p_doc_type          IN  VARCHAR2,
        p_doc_id            IN  NUMBER,

        x_qa_result_tbl     OUT NOCOPY qa_result_tbl_type,
        x_qa_return_status  OUT NOCOPY VARCHAR2,
        p_qa_terms_only     IN VARCHAR2 DEFAULT 'N'    ,
	   p_run_expert_flag   IN VARCHAR2 DEFAULT 'Y'    -- Bug 5186245
        );

    /* version 3, does not log valiation messages in OKC_QA_ERRORS_T table
    returns x_qa_result_tbl as out parameter, takes in additional parameter
    p_bus_doc_date_events_tbl
    11.5.10+: No modification
    */
    PROCEDURE QA_Doc     (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_qa_mode           IN  VARCHAR2 DEFAULT G_NORMAL_QA,
        p_doc_type          IN  VARCHAR2,
        p_doc_id            IN  NUMBER,

        x_qa_result_tbl     OUT NOCOPY qa_result_tbl_type,
        x_qa_return_status  OUT NOCOPY VARCHAR2,

        p_bus_doc_date_events_tbl   IN BUSDOCDATES_TBL_TYPE,
	   p_run_expert_flag   IN VARCHAR2 DEFAULT 'Y'    -- Bug 5186245
        );

    PROCEDURE Check_Terms(
        x_return_status     OUT NOCOPY VARCHAR2,
        p_chr_id            IN  NUMBER
        );

END OKC_TERMS_QA_GRP;

 

/
