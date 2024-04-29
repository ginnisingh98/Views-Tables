--------------------------------------------------------
--  DDL for Package PO_ENCUMBRANCE_POSTPROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ENCUMBRANCE_POSTPROCESSING" AUTHID CURRENT_USER AS
-- $Header: POXENC2S.pls 120.5.12010000.6 2012/10/04 11:11:08 dtoshniw ship $

-- Package constants
g_REPORT_LEVEL_TRANSACTION  CONSTANT VARCHAR2(15) := 'TRANSACTION';
g_REPORT_LEVEL_DISTRIBUTION CONSTANT VARCHAR2(15) := 'DISTRIBUTION';
--<Bug 12824154 BEGIN >--
g_EXECUTE_GL_CALL_API_EXC     exception;
g_event_id  number;
--<Bug 12824154 END >--


-- Procedures used by PO_DOCUMENT_FUNDS_PVT.do_action:

PROCEDURE insert_packet(
  p_status_code                    IN             VARCHAR2
, p_user_id                        IN             NUMBER
, p_set_of_books_id                IN             NUMBER
, p_currency_code                  IN             VARCHAR2
, p_action                         IN             VARCHAR2
, x_packet_id                      OUT NOCOPY     NUMBER
);

PROCEDURE execute_gl_call(
  p_set_of_books_id                IN             NUMBER
, p_packet_id                      IN OUT NOCOPY  NUMBER
, p_gl_mode                        IN             VARCHAR2
, p_partial_resv_flag              IN             VARCHAR2
, p_override                       IN             VARCHAR2
, p_conc_flag                      IN             VARCHAR2
, p_user_id                        IN             NUMBER
, p_user_resp_id                   IN             NUMBER
, x_return_code                    OUT NOCOPY     VARCHAR2
);

PROCEDURE copy_detailed_gl_results(
  p_packet_id                      IN             NUMBER
, p_gl_return_code                 IN             VARCHAR2
);

PROCEDURE update_document_encumbrance(
  p_doc_type                       IN             VARCHAR2
, p_doc_subtype                    IN             VARCHAR2
, p_action                         IN             VARCHAR2
, p_gl_return_code                 IN             VARCHAR2
);

PROCEDURE create_enc_action_history(
   p_doc_type                       IN             VARCHAR2
,  p_doc_id_tbl                     IN             po_tbl_number
,  p_employee_id                    IN             NUMBER
,  p_action                         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
);

PROCEDURE set_status_requires_reapproval(
   p_document_type	IN	VARCHAR2
,  p_action		IN	VARCHAR2
,  p_cbc_flag           IN      VARCHAR2
);

PROCEDURE create_detailed_report(
   p_gl_return_code		IN		VARCHAR2
,  p_user_id			IN		NUMBER
,  x_online_report_id		OUT NOCOPY	VARCHAR2
,  x_po_return_code		OUT NOCOPY	VARCHAR2
,  x_po_return_msg_name		OUT NOCOPY	VARCHAR2
);


PROCEDURE create_exception_report(
   p_message_text		IN		VARCHAR2
,  p_user_id			IN		NUMBER
,  x_online_report_id		OUT NOCOPY	NUMBER
);

PROCEDURE delete_packet_autonomous(
  p_packet_id                      IN     NUMBER
);
--<bug#5010001 START>
PROCEDURE populate_bc_report_id(
    p_online_report_id IN NUMBER
);

/*12405805
Added to delete
1) Unprocessed events because of checkfunds
2)Invalid events because of exceptions
at the end of encumbrance action*/
PROCEDURE delete_unnecessary_events(
p_packet_id         IN         NUMBER,
p_action            IN         VARCHAR2

);


--<bug#5010001 END>
--<bug#5523323 START>
--Removed the procedure populate_aut_bc_report_id. We do not
--have any autonomous transactions anymore.
--<bug#5523323 END>
--<bug#5353223 START>
FUNCTION get_sign_for_amount(p_event_type_code     IN VARCHAR2,
                             p_main_or_backing_doc IN VARCHAR2,
                             p_adjustment_status   IN VARCHAR2,
                             p_distribution_type   IN VARCHAR2) RETURN NUMBER;
--<bug#5353223 END>

--<BEGIN Bug 12907851>--
-- Added procedure to udpate the encumbrance flag and
-- approval details for distributions whose
-- final amt is zero
PROCEDURE update_zero_amt_rows(p_action IN VARCHAR2,
                              p_doc_type IN VARCHAR2
			     );

-- <Bug 13503748: Edit without unreserve ER.>
-- Adding this function in the spec and removing private function
-- definition from the body.
FUNCTION get_event_type_code(p_distribution_type    IN VARCHAR2,
                             p_action      IN VARCHAR2) RETURN VARCHAR2;


END PO_ENCUMBRANCE_POSTPROCESSING;


/
