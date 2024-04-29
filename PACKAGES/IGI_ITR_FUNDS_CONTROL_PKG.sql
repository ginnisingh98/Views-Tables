--------------------------------------------------------
--  DDL for Package IGI_ITR_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_FUNDS_CONTROL_PKG" AUTHID CURRENT_USER AS
-- $Header: igiitrhs.pls 120.6.12010000.2 2008/08/04 13:03:37 sasukuma ship $
Procedure Funds_Check_Reserve(
    p_it_header_id	  IN     igi_itr_charge_headers.it_header_id%type,
    p_it_service_line_id  IN     igi_itr_charge_lines.it_service_line_id%type,
    p_set_of_books_id     IN     igi_itr_charge_headers.set_of_books_id%type,
    p_reversal_amount     IN     igi_itr_charge_lines.entered_dr%type,
    p_called_by           IN     varchar2, -- fundschecker(F)/approval(A)
    p_return_message_name IN OUT NOCOPY varchar2,
    p_calling_sequence    IN     varchar2);

Function Encumbrance_Enabled(
    p_set_of_books_id IN igi_itr_charge_headers.set_of_books_id%type) Return Boolean;

Procedure Bc_Packets_Insert(
    p_packet_id		       IN gl_bc_packets.packet_id%type,
    p_set_of_books_id 	       IN gl_bc_packets.ledger_id%type,
    p_ccid                     IN gl_bc_packets.code_combination_id%type,
    p_amount                   IN gl_bc_packets.entered_dr%type,
    p_period_year	       IN gl_bc_packets.period_year%type,
    p_period_num	       IN gl_bc_packets.period_num%type,
    p_quarter_num	       IN gl_bc_packets.quarter_num%type,
    p_gl_user		       IN gl_bc_packets.last_updated_by%type,
    p_enc_type_id	       IN gl_bc_packets.encumbrance_type_id%type,
    p_ref2		       IN gl_bc_packets.reference2%type,
    p_ref4	               IN gl_bc_packets.reference4%type,
    p_ref5	               IN gl_bc_packets.reference5%type,
    p_je_source		       IN gl_bc_packets.je_source_name%type,
    p_je_category	       IN gl_bc_packets.je_category_name%type,
    p_actual_flag	       IN gl_bc_packets.actual_flag%type,
    p_period_name	       IN gl_bc_packets.period_name%type,
    p_base_currency_code       IN gl_bc_packets.currency_code%type,
    p_status_code	       IN gl_bc_packets.status_code%type,
    p_reversal_flag	       IN igi_itr_charge_lines_audit.reversal_flag%type,
    p_status_flag              IN igi_itr_charge_lines.status_flag%type,
    p_prevent_encumbrance_flag IN igi_itr_charge_lines.prevent_encumbrance_flag%type,
    p_charge_name              IN igi_itr_charge_headers.name%type, --shsaxena for bug 2948237
 -- p_description              IN varchar2,
    p_calling_sequence 	       IN varchar2);

Procedure Setup_Gl_Fundschk_Params(
    p_packet_id   	IN OUT NOCOPY igi_itr_charge_lines_audit.packet_id%type,
    p_mode     	        IN OUT NOCOPY varchar2,
    p_partial_resv_flag IN OUT NOCOPY varchar2,
    p_called_by 	IN     varchar2,
    p_calling_sequence 	IN     varchar2);

Procedure Fundscheck_Init(
    p_chart_of_accounts_id IN OUT NOCOPY gl_sets_of_books.chart_of_accounts_id%type,
    p_set_of_books_id      IN     igi_itr_charge_headers.set_of_books_id%type,
    p_itr_enc_type_id 	   IN OUT NOCOPY igi_itr_charge_setup.encumbrance_type_id%type,
    p_gl_user_id           IN OUT NOCOPY number,
    p_calling_sequence 	   IN     varchar2);

Procedure Get_Gl_Fundschk_Packet_Id(
    p_packet_id IN OUT NOCOPY igi_itr_charge_lines_audit.packet_id%type);

END IGI_ITR_FUNDS_CONTROL_PKG;

/
