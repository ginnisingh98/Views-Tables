--------------------------------------------------------
--  DDL for Package PO_FUNDS_CHECKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_FUNDS_CHECKER" AUTHID CURRENT_USER AS
/* $Header: POXPOFCS.pls 115.2 2002/11/25 22:41:38 sbull ship $ */

  -- Funds Control Action on an Entity

  FUNCTION po_funds_control(p_docid           IN     NUMBER,
                            p_doctyp          IN     VARCHAR2,
                            p_docsubtyp       IN     VARCHAR2,
                            p_lineid          IN     NUMBER,
                            p_shipid          IN     NUMBER,
                            p_distid          IN     NUMBER DEFAULT 0,
                            p_action          IN     VARCHAR2,
                            p_override_period IN     VARCHAR2 DEFAULT NULL,
                            p_recreate_demand IN     VARCHAR2 DEFAULT 'N',
                            p_conc_flag       IN     VARCHAR2 DEFAULT 'N',
                            p_return_code     IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


  -- Check whether it is OK to invoke Funds Checker

  FUNCTION po_fc_ok(p_doctyp  IN     VARCHAR2,
                    p_lineid  IN     NUMBER,
                    p_shipid  IN     NUMBER,
                    p_distid  IN     NUMBER DEFAULT 0,
                    p_action  IN     VARCHAR2,
                    p_fc_ok   IN OUT NOCOPY BOOLEAN) RETURN BOOLEAN;


  -- Insert into the Funds Checker queue

  FUNCTION po_fc_ins(p_docid           IN     NUMBER,
                     p_doctyp          IN     VARCHAR2,
                     p_docsubtyp       IN     VARCHAR2,
                     p_lineid          IN     NUMBER,
                     p_shipid          IN     NUMBER,
                     p_distid          IN     NUMBER DEFAULT 0,
                     p_action          IN     VARCHAR2,
                     p_override_period IN     VARCHAR2,
                     p_recreate_demand IN     VARCHAR2,
                     p_packetid        IN OUT NOCOPY NUMBER) RETURN BOOLEAN;


  -- Check Level for Funds Check

  FUNCTION po_fc_level(p_docid   IN     NUMBER,
                       p_lineid  IN     NUMBER,
                       p_shipid  IN     NUMBER,
                       p_distid  IN     NUMBER DEFAULT 0,
                       p_fclevel IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


  -- Get Debug Information

  FUNCTION get_debug RETURN VARCHAR2;


END PO_FUNDS_CHECKER;

 

/
