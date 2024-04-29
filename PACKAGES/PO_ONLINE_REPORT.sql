--------------------------------------------------------
--  DDL for Package PO_ONLINE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ONLINE_REPORT" AUTHID CURRENT_USER AS
/* $Header: POXPOONS.pls 115.2 2002/11/25 22:39:53 sbull ship $ */

  -- Determine how Multiple Inserts into the Online Reporting table are
  -- to be handled

  FUNCTION insert_many(p_docid       IN     NUMBER,
                       p_doctyp      IN     VARCHAR2,
                       p_docsubtyp   IN     VARCHAR2,
                       p_lineid      IN     NUMBER,
                       p_shipid      IN     NUMBER,
                       p_message     IN     VARCHAR2,
                       p_reportid    IN     NUMBER,
                       p_numtokens   IN     NUMBER,
                       p_sqlstring   IN     VARCHAR2,
                       p_sequence    IN     NUMBER,
                       p_action_date IN     DATE,
                       p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


  -- Determine how Single Inserts into the Online Reporting table are
  -- to be handled

  FUNCTION insert_single(p_linenum     IN     NUMBER,
                         p_shipnum     IN     NUMBER,
                         p_distnum     IN     NUMBER,
                         p_message     IN     VARCHAR2,
                         p_reportid    IN     NUMBER,
                         p_sequence    IN     NUMBER,
                         p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


  -- Get Debug Information

  FUNCTION get_debug RETURN VARCHAR2;


END PO_ONLINE_REPORT;

 

/
