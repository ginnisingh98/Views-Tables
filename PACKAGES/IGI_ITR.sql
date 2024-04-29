--------------------------------------------------------
--  DDL for Package IGI_ITR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR" AUTHID CURRENT_USER AS
-- $Header: igiitrgs.pls 120.3.12000000.1 2007/09/12 10:31:09 mbremkum ship $
--
TYPE BatchTabType IS TABLE of NUMBER(15) INDEX by BINARY_INTEGER;
--
l_Action        NUMBER(15) := 0;
--
l_TableRow      binary_integer := 0;
l_BatchIdTable  BatchTabType;
--
procedure SUBMIT
(p_it_header_id number,/* igig_itr_encumbrance_allowed char , */
 p_status_flag in out NOCOPY number, p_status_message in out NOCOPY VARCHAR2);
--
PROCEDURE action (p_action NUMBER);
--
PROCEDURE set_batches (p_batch_id NUMBER);
--
PROCEDURE process_batches;
--
PROCEDURE control ( p_interface_run_id NUMBER
                  , p_group_id         NUMBER
                  , p_set_of_books_id  NUMBER
                  , p_status_code    IN OUT NOCOPY NUMBER
                  , p_status_message IN OUT NOCOPY VARCHAR2 );
--
procedure ACCEPT
(p_it_header_id number
,p_it_line_num number
,p_igig_itr_encumbrance_allowed char
,p_group_id number
,p_status_code in out NOCOPY number
,p_status_message in out NOCOPY char
);

procedure REJECT
(p_it_header_id number
,p_it_line_num number
,p_group_id number
,p_status_code in out NOCOPY number
,p_status_message in out NOCOPY char
);

procedure STATUS( p_batch_id number);
--
END IGI_ITR;

 

/
