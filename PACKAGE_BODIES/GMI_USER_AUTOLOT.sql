--------------------------------------------------------
--  DDL for Package Body GMI_USER_AUTOLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_USER_AUTOLOT" AS
/* $Header: gmiltstb.pls 115.0 2003/03/18 15:02:00 jdiiorio noship $ */

PROCEDURE user_lot_number(p_item_id                   IN   NUMBER,
                        p_in_lot_no                   IN   VARCHAR2,
                        p_orgn_code                   IN   VARCHAR2,
                        p_doc_id                      IN   NUMBER,
                        p_line_id                     IN   NUMBER,
                        p_doc_type                    IN   VARCHAR2,
                        p_u_out_lot_no                OUT  NOCOPY VARCHAR2,
                        p_u_sublot_no                 OUT  NOCOPY VARCHAR2,
                        p_u_return_status             OUT  NOCOPY NUMBER)


IS

BEGIN

   p_u_return_status := 0;
   p_u_out_lot_no := NULL;
   p_u_sublot_no := NULL;

END user_lot_number;
END;

/
