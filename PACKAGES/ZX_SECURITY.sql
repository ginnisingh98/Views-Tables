--------------------------------------------------------
--  DDL for Package ZX_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_SECURITY" AUTHID CURRENT_USER AS
/* $Header: zxifdtaccsecpvts.pls 120.10.12010000.2 2008/11/12 12:29:43 spasala ship $ */

--
-- Global Variables
-- Purpose
--  Used in security policy functions to determine the correct predicate for a
--  single subscriber
--

G_FIRST_PARTY_ORG_ID      NUMBER ;
G_EFFECTIVE_DATE     	  DATE;
G_ICX_SESSION_ID     	  NUMBER;

FUNCTION get_effective_date RETURN DATE;

--
-- Name
--   single_read_access
-- Purpose
--  Security policy function to control read access to rules and formula setup
--  data for a single subscriber
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION single_read_access  (D1 VARCHAR2, D2 VARCHAR2)
RETURN VARCHAR2;

--
-- Name
--   single_read_access_for_excp
-- Purpose
--  Security policy function to control read access to exception setup
--  data for a single first party organization
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION single_read_access_for_excp  (D1 VARCHAR2, D2 VARCHAR2)
RETURN VARCHAR2 ;

--
-- Name
--   single_read_access_for_ovrd
-- Purpose
--  Security policy function to control read access to tax setup data for a
--  single first party organization
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--
FUNCTION single_read_access_for_ovrd (D1 VARCHAR2, D2 VARCHAR2)
RETURN VARCHAR2;

--
-- Name
--   multiple_read_access
-- Purpose
--  Security policy function to control read access to tax setup data for
--  multiple subscribers
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION multiple_read_access  (D1 VARCHAR2, D2 VARCHAR2)
RETURN VARCHAR2;

--
-- Name
--   multiple_read_access_for_excp
-- Purpose
--  Security policy function to control read access to exception setup data for
--  multiple first party organizations
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION multiple_read_access_for_excp  (D1 VARCHAR2, D2 VARCHAR2)
RETURN VARCHAR2 ;
--
-- Name
--   write_access
-- Purpose
--  Security policy function to control write access to tax setup data
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION write_access (D1 VARCHAR2, D2 VARCHAR2)
RETURN VARCHAR2;

--
-- Name
--   write_access_for_excp
-- Purpose
--  Security policy function to control write access to exception setup data
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--
FUNCTION write_access_for_excp (D1 VARCHAR2, D2 VARCHAR2)
RETURN  VARCHAR2;

--
-- Name
--   first_party_org_access
-- Purpose
--  Security policy function to control data in zx_exemptions_v
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--
FUNCTION first_party_org_access (D1 VARCHAR2, D2 VARCHAR2)
RETURN  VARCHAR2;



--
-- Name
--   add_icx_session_id
-- Purpose
--  Security policy function to control data
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION add_icx_session_id (D1 VARCHAR2, D2 VARCHAR2)
RETURN  VARCHAR2;

--
-- Name
--   single_regime_access
-- Purpose
--  Security policy function to determince regime applicability process
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION single_regime_access (D1 VARCHAR2, D2 VARCHAR2)

RETURN VARCHAR2;


--
-- Name
--   set_security_context
-- Purpose
--  Sets the global variables G_FIRST_PARTY_ORG_ID and G_EFFECTIVE_DATE
--

PROCEDURE set_security_context(p_legal_entity_id IN NUMBER,
                               p_internal_org_id IN NUMBER,
                               p_effective_date  IN DATE,
                               x_return_status  OUT NOCOPY VARCHAR2);

PROCEDURE set_security_context_ui(p_legal_entity_id IN NUMBER,
                               p_internal_org_id IN NUMBER,
                               p_effective_date  IN DATE,
                               x_return_status  OUT NOCOPY VARCHAR2);

PROCEDURE set_security_context(p_first_party_org_id IN NUMBER,
                               p_effective_date     IN DATE,
                               x_return_status     OUT NOCOPY VARCHAR2);


PROCEDURE check_write_access (p_first_party_org_id IN NUMBER,
                              p_tax_regime_code    IN VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE name_value (name VARCHAR2, value VARCHAR2);

END zx_security;

/
