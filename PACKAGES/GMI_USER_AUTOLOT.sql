--------------------------------------------------------
--  DDL for Package GMI_USER_AUTOLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_USER_AUTOLOT" AUTHID CURRENT_USER AS
/* $Header: gmiltsts.pls 115.0 2003/03/18 15:01:34 jdiiorio noship $ */


PROCEDURE user_lot_number(p_item_id                   IN   NUMBER,
                        p_in_lot_no                   IN   VARCHAR2,
                        p_orgn_code                   IN   VARCHAR2,
                        p_doc_id                      IN   NUMBER,
                        p_line_id                     IN   NUMBER,
                        p_doc_type                    IN   VARCHAR2,
                        p_u_out_lot_no                OUT  NOCOPY VARCHAR2,
                        p_u_sublot_no                 OUT  NOCOPY VARCHAR2,
                        p_u_return_status             OUT  NOCOPY NUMBER);


END gmi_user_autolot;

 

/
