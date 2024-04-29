--------------------------------------------------------
--  DDL for Package CN_CLASSIFICATION_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CLASSIFICATION_GEN" AUTHID CURRENT_USER AS
-- $Header: cnclgens.pls 120.3 2005/07/12 23:01:58 appldev ship $


--
-- Procedure Name
--   revenue_classes
-- Purpose
--   This function generates the code for classifying transactions into
--   revenue classes based on certain rules.
-- History
--   12/13/93           Devesh Khatu            Created
--   06-JUN-95          Amy Erickson            Updated
--
FUNCTION revenue_classes (
        debug_pipe      VARCHAR2,
        debug_level     NUMBER := 1,
	X_module_id     cn_modules.module_id%TYPE,
        x_ruleset_id_in cn_rulesets.ruleset_id%TYPE,
	x_org_id_in cn_rulesets.org_id%TYPE)  RETURN BOOLEAN ;

g_ruleset_id            cn_rulesets.ruleset_id%type;
g_org_id                cn_rulesets.org_id%type;

--
-- Procedure Name
--   classification_install
-- Purpose
--   This procedure generates the code and then installs the
--   modified rule definitions in the database.
-- History
--   07/04/2000         Sohail Khawaja          Created
--
  PROCEDURE Classification_Install(
                 x_errbuf OUT NOCOPY VARCHAR2,
                 x_retcode OUT NOCOPY NUMBER,
                 x_ruleset_id IN NUMBER,
		 x_org_id IN NUMBER);

-- Called by the methods to get the current org_id  and the org_id string rep
PROCEDURE get_cached_org_info (
			x_cached_org_id OUT NOCOPY integer,
			x_cached_org_append OUT NOCOPY VARCHAR2);


-- clku
-- procedure to check for if single quotes are paired up in a string
PROCEDURE check_text_paired_quotes (l_in_text IN VARCHAR2,
                                   l_out_paired_quotes OUT NOCOPY BOOLEAN );

END cn_classification_gen;

 

/
