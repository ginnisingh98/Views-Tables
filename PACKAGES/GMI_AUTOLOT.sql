--------------------------------------------------------
--  DDL for Package GMI_AUTOLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_AUTOLOT" AUTHID CURRENT_USER AS
/* $Header: gmialots.pls 115.1 2003/03/18 14:56:41 jdiiorio noship $ */


PROCEDURE generate_lot_number(p_item_id                    IN   NUMBER,
                             p_in_lot_no                   IN   VARCHAR2,
                             p_orgn_code                   IN   VARCHAR2,
                             p_doc_id                      IN   NUMBER,
                             p_line_id                     IN   NUMBER,
                             p_doc_type                    IN   VARCHAR2,
                             p_out_lot_no                  OUT  NOCOPY VARCHAR2,
                             p_sublot_no                   OUT  NOCOPY VARCHAR2,
                             p_return_status               OUT  NOCOPY NUMBER);


FUNCTION check_for_autolot(p_item_id IN NUMBER)
     RETURN NUMBER;

END gmi_autolot;

 

/
