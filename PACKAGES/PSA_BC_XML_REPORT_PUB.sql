--------------------------------------------------------
--  DDL for Package PSA_BC_XML_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_BC_XML_REPORT_PUB" AUTHID CURRENT_USER AS
/*  $Header: PSAXMLRS.pls 120.5 2006/12/01 17:19:31 agovil noship $ */



------- Create a STRUCTURE with all SRS paramaters ----------

TYPE funds_check_report_rec_type IS RECORD(
        LEDGER_ID                               GL_LEDGERS.LEDGER_ID%TYPE,
        PERIOD_FROM                             VARCHAR2(30),
        PERIOD_TO                               VARCHAR2(30),
        CHART_OF_ACCTS_ID                       NUMBER,
        CCID_LOW                                VARCHAR2(1000),
        CCID_HIGH                               VARCHAR2(1000),
	APPLICATION_SHORT_NAME	                VARCHAR2(8),
	BC_FUNDS_CHECK_STATUS	                PSA_LOOKUP_CODES.lookup_code%TYPE,
	BC_FUNDS_CHECK_ORDER_BY	                PSA_LOOKUP_CODES.lookup_code%TYPE,
	PACKET_EVENT_FLAG		        VARCHAR2(1),
	APPLICATION_ID			        NUMBER(15),
	SEQUENCE_ID                             NUMBER(15)
);

------- This is the first procedure and will be called from Concurrent program.-----
------- The executable name in concurrent program -----
------- will be PSA_BC_XML_REPORT_PUB.create_bc_report -------

PROCEDURE create_bc_report(
	errbuf                                          OUT NOCOPY VARCHAR2,
	retcode                                         OUT NOCOPY NUMBER,

	P_LEDGER_ID                                     IN NUMBER DEFAULT NULL,
	P_PERIOD_FROM				        IN VARCHAR2 DEFAULT NULL,
	P_PERIOD_TO					IN VARCHAR2 DEFAULT NULL,
        P_CHART_OF_ACCTS_ID                             IN NUMBER,
        P_CCID_LOW                                      IN VARCHAR2 DEFAULT NULL,
        P_CCID_HIGH                                     IN VARCHAR2 DEFAULT NULL,
	P_APPLICATION_SHORT_NAME	                IN VARCHAR2 DEFAULT NULL,
	P_FUNDS_CHECK_STATUS		                IN VARCHAR2 DEFAULT NULL,
	P_ORDER_BY                                      IN VARCHAR2 DEFAULT NULL
);

------- This Procedure is invoked when the BC report is invoked from Forms
PROCEDURE create_bc_transaction_report(
--        x_xml_out                             OUT NOCOPY CLOB,
	errbuf                                  OUT NOCOPY VARCHAR2,
	retcode                                 OUT NOCOPY NUMBER,
	P_LEDGER_ID                             IN NUMBER DEFAULT NULL,
	P_APPLICATION_ID                        IN NUMBER DEFAULT NULL,
	P_PACKET_EVENT_FLAG                     IN VARCHAR2 DEFAULT NULL,
	P_SEQUENCE_ID                           IN NUMBER DEFAULT NULL
);

------- This procedure will build the SQL query from PSA_BC_REPORT_V view
------- for all products for the given paramters -------

PROCEDURE build_report_query(
    x_return_status                     OUT NOCOPY VARCHAR2,
    x_source                            IN VARCHAR2 DEFAULT NULL,
    p_para_rec                          IN PSA_BC_XML_REPORT_PUB.funds_check_report_rec_type,
    p_application_short_name            IN VARCHAR2 DEFAULT NULL,
    x_report_query                      OUT NOCOPY VARCHAR2
);



PROCEDURE get_xml(
    x_return_status OUT NOCOPY VARCHAR2,
    p_query         IN VARCHAR2,
    p_rowset_tag    IN VARCHAR2 DEFAULT NULL,
    p_row_tag       IN VARCHAR2 DEFAULT NULL,
    x_xml           OUT NOCOPY CLOB
);


PROCEDURE construct_bc_report_output(
   x_return_status  OUT NOCOPY VARCHAR2,
   x_source		IN VARCHAR2 DEFAULT NULL,
   p_para_rec       IN  PSA_BC_XML_REPORT_PUB.funds_check_report_rec_type,
   p_trxs	    IN CLOB
);


PROCEDURE save_xml(
    x_return_status OUT NOCOPY VARCHAR2,
    x_source					IN VARCHAR2 DEFAULT NULL,
    p_application_id  IN NUMBER,
    p_sequence_id  IN NUMBER,
    p_trxs          IN CLOB,
    p_offset        IN INTEGER DEFAULT 1
);

PROCEDURE save_xml_to_db(
    x_return_status    OUT   NOCOPY VARCHAR2,
    p_application_id   IN NUMBER,
    p_sequence_id      IN NUMBER,
    p_trxs             IN CLOB
);

END PSA_BC_XML_REPORT_PUB;


/
