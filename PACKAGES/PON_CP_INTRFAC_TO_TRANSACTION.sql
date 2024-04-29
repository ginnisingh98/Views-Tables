--------------------------------------------------------
--  DDL for Package PON_CP_INTRFAC_TO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_CP_INTRFAC_TO_TRANSACTION" AUTHID CURRENT_USER as
/* $Header: PONCPITS.pls 120.4.12010000.2 2013/08/16 05:55:24 irasoolm ship $ */

procedure DEFAULT_PREV_ROUND_AMEND_LINES(
p_auction_header_id IN NUMBER,
p_batch_id IN NUMBER);

FUNCTION GET_NEXT_PE_SEQUENCE_NUMBER(p_auction_header IN NUMBER,
                                     p_line_number IN NUMBER)
RETURN NUMBER;

FUNCTION GET_SEQUENCE_NUMBER(p_batch_id          IN NUMBER,
                             p_interface_line_id IN NUMBER,
                             p_template_sequence_number IN NUMBER) RETURN NUMBER;

FUNCTION GET_ATTR_GROUP_SEQ_NUMBER(p_batch_id          IN NUMBER,
                                   p_interface_line_id IN NUMBER,
                                   p_attr_group        IN VARCHAR2,
                                   p_template_group_seq_number IN NUMBER) RETURN NUMBER;

FUNCTION GET_ATTR_DISP_SEQ_NUMBER(p_batch_id          IN NUMBER,
                                  p_interface_line_id IN NUMBER,
                                  p_attr_group        IN VARCHAR2,
                                  p_template_disp_seq_number IN NUMBER) RETURN NUMBER;

PROCEDURE SYNCH_FROM_INTERFACE(
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    p_user_id               IN NUMBER,
    p_party_id              IN NUMBER,
    x_number_of_lines       OUT NOCOPY NUMBER,
    x_max_disp_line         OUT NOCOPY NUMBER,
    x_last_line_close_date  OUT NOCOPY DATE,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, F: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
);

PROCEDURE SYNCH_FROM_INTERFACE(
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    p_user_id               IN NUMBER,
    p_party_id              IN NUMBER,
    p_commit                IN VARCHAR2,
    x_number_of_lines       OUT NOCOPY NUMBER,
    x_max_disp_line         OUT NOCOPY NUMBER,
    x_last_line_close_date  OUT NOCOPY DATE,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, F: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
);


PROCEDURE SYNCH_PAYMENTS_FROM_INTERFACE(
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, E: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_CONCURRENT_ERRORS (
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, F: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
);

END PON_CP_INTRFAC_TO_TRANSACTION;

/
