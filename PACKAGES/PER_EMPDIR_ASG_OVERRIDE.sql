--------------------------------------------------------
--  DDL for Package PER_EMPDIR_ASG_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EMPDIR_ASG_OVERRIDE" AUTHID CURRENT_USER AS
/* $Header: peredcor.pkh 115.0 2003/08/03 02:03 smallina noship $ */

    PROCEDURE before_dml(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_rec_locator IN NUMBER
       ,p_srcSystem IN VARCHAR2);

    FUNCTION isOverrideEnabled RETURN BOOLEAN;

END PER_EMPDIR_ASG_OVERRIDE;

 

/
