--------------------------------------------------------
--  DDL for Package Body QLTSSCPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTSSCPB" as
/* $Header: qltsscpb.plb 120.1 2005/11/07 02:13:49 srhariha noship $ */


--  This is a wrapper for ss plan mapping.
--  It is needed for the concurrent manager to run
--  This is called from QLTPLMDF.fmb


PROCEDURE wrapper (ERRBUF OUT NOCOPY VARCHAR2,
		   RETCODE OUT NOCOPY NUMBER,
		   ARGUMENT1 IN VARCHAR2,
		   ARGUMENT2 IN VARCHAR2,
		   ARGUMENT3 IN NUMBER) IS

l_plan_id  NUMBER;
BEGIN

    -- ARGUMENT1 --> CREATE
    -- ARGUMENT1 is a bit obsolete, but it is there for legacy purpose
    -- ARGUMENT3 is plan_id and the one we really need

    l_plan_id := to_number(ARGUMENT3);

    IF	(ARGUMENT1 = 'CREATE') THEN

        -- Bug 3769260. shkalyan 30 July 2004.
        -- In order to pre-fetch Plan Chars which will be used
        -- for JRAD Mapping, this call is used.

        qa_chars_api.fetch_plan_chars(l_plan_id);

        -- Bug 3769260. shkalyan 30 July 2004.
        -- In order to pre-fetch Plan Chars which will be used
        -- for JRAD Mapping, this call is used.

        qa_plan_element_api.fetch_qa_plan_chars(l_plan_id);

        qa_jrad_pkg.map_plan(l_plan_id, NULL);
        qa_ssqr_jrad_pkg.map_plan(l_plan_id);

        --
        -- Tracking Bug 4697145
        -- MOAC Upgrade feature to indicate this plan has
        -- been regenerated and on demand mapping can skip.
        -- bso Sun Nov  6 16:52:53 PST 2005
        --
        qa_ssqr_jrad_pkg.jrad_upgraded(l_plan_id);
    END IF;

    RETCODE := 0;
    ERRBUF := '';

END WRAPPER;


END qltsscpb;


/
