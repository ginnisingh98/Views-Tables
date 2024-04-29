--------------------------------------------------------
--  DDL for Package Body POA_OLTP_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_OLTP_GENERIC_PKG" AS
/* $Header: poagpksb.pls 115.3 2002/09/05 01:47:20 jhou noship $ */

-- Global variables to cache some values to improve performance
g_creation_date DATE := NUll;
g_poh_id NUMBER := NUll;
g_poh_approved_date DATE := NUll;
g_por_id NUMBER := NUll;
g_por_approved_date DATE := NUll;
g_line_location_id NUMBER := NUll;
g_pll_approved_date DATE := NUll;


FUNCTION get_approved_date_poh (p_creation_date IN DATE,
                                p_poh_id IN NUMBER) return DATE IS
app_date DATE;

BEGIN

IF (p_creation_date = g_creation_date AND
    p_poh_id = g_poh_id) THEN
  return g_poh_approved_date;
END IF;

select min(approved_date)
into app_date
from po_headers_archive_all poh
where poh.po_header_id = p_poh_id
and poh.approved_date >= p_creation_date;

g_poh_approved_date := app_date;
g_creation_date := p_creation_date;
g_poh_id := p_poh_id;

return app_date;
END get_approved_date_poh;

FUNCTION get_approved_date_por (p_creation_date IN DATE,
                                p_por_id IN NUMBER) return DATE IS
app_date DATE;

BEGIN

IF (p_creation_date = g_creation_date AND
    p_por_id = g_por_id) THEN
  return g_por_approved_date;
END IF;

select min(approved_date)
into app_date
from po_releases_archive_all por
where por.po_release_id = p_por_id
and por.approved_date >= p_creation_date;

g_por_approved_date := app_date;
g_creation_date := p_creation_date;
g_por_id := p_por_id;

return app_date;
END get_approved_date_por;

FUNCTION get_approved_date_pll (p_creation_date IN DATE,
                                p_line_location_id IN NUMBER) return DATE IS
app_date DATE;

BEGIN

IF (p_creation_date = g_creation_date AND
    p_line_location_id = g_line_location_id) THEN
  return g_pll_approved_date;
END IF;

select min(approved_date)
into app_date
from po_line_locations_archive_all pll
where pll.line_location_id = p_line_location_id
and pll.approved_date >= p_creation_date;

g_pll_approved_date := app_date;
g_creation_date := p_creation_date;
g_line_location_id := p_line_location_id;

return app_date;
END get_approved_date_pll;


END POA_OLTP_GENERIC_PKG;


/
