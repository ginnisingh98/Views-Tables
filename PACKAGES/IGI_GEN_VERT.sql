--------------------------------------------------------
--  DDL for Package IGI_GEN_VERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_GEN_VERT" AUTHID CURRENT_USER AS
-- $Header: igigccbs.pls 120.5.12000000.2 2007/07/02 08:58:54 smannava ship $
--
/* ================================================================== */

/* START GLOBAL VARIABLES  USED BY IGILUTIL2 */

IGI_IGILUTIL2_CBC BOOLEAN;
IGI_IGILUTIL2_CC  BOOLEAN;
IGI_IGILUTIL2_CIS BOOLEAN;
IGI_IGILUTIL2_DOS BOOLEAN;
IGI_IGILUTIL2_EXP BOOLEAN;
IGI_IGILUTIL2_IAC BOOLEAN;
IGI_IGILUTIL2_MHC BOOLEAN;
IGI_IGILUTIL2_SIA BOOLEAN;
IGI_IGILUTIL2_STP BOOLEAN;

/* END GLOBAL VARIABLES */

FUNCTION is_req_installed
                (p_option_name VARCHAR2
		)
RETURN BOOLEAN;

--sdixit 28 jul 2003 MOAC changes START
FUNCTION is_req_installed
                (p_option_name VARCHAR2
                 ,p_org_id NUMBER)
RETURN VARCHAR2;
--sdixit MOAC chenges END

--B Shergill 20-OCT-98 Generic addition	START(1)
PRAGMA RESTRICT_REFERENCES(is_req_installed, WNDS);
--B Shergill 20-OCT-98 Generic addition	END(1)



PROCEDURE get_option_status
                ( p_option_name IN  VARCHAR2
                , p_status_flag OUT NOCOPY VARCHAR2
                , p_error_num   OUT NOCOPY NUMBER
                );
PROCEDURE DEBUG
                ( p_module          IN VARCHAR2
                , p_module_variable IN VARCHAR2
                , p_variable_value  IN VARCHAR2
                , P_message         IN VARCHAR2
                );


FUNCTION GET_LOOKUP_MEANING
                ( l_lookup_type                 VARCHAR2
                )
RETURN VARCHAR2;


--B Shergill 20-OCT-98 EFC addition	START(1)
PROCEDURE IGI_EFC_CHECK_OPTIONS
					(	p_sob 	NUMBER
					,	p_efc1	IN OUT NOCOPY VARCHAR2
					);
--B Shergill 20-OCT-98 EFC addition	END(1)


--M Thompson 23-Dec-98 SOB functions used by HUL  START(2)
FUNCTION get_ap_sob_id
RETURN NUMBER;


FUNCTION get_ar_sob_id
RETURN NUMBER;


FUNCTION get_po_sob_id
RETURN NUMBER;
-- END(2)

FUNCTION igiInstalled RETURN BOOLEAN;

FUNCTION cacheProductOptions RETURN BOOLEAN;

FUNCTION productEnabled ( prod IN VARCHAR2 ) RETURN BOOLEAN;

/* ================================================================== */
END;    -- End of package header create

 

/
