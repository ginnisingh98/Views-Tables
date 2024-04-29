--------------------------------------------------------
--  DDL for Package GHR_SF113_A
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF113_A" AUTHID CURRENT_USER AS
/* $Header: ghsf113a.pkh 120.1 2006/07/14 21:48:02 deenath ship $ */
--
--
Function get_org_info(p_business_group_id  IN number)
	return varchar2 ;
-- pragma restrict_references (get_org_info, WNDS);
--
--
Function validate_agcy (p_agcy    	IN  varchar2,
				p_segment   IN  varchar2)
	return   boolean;
-- pragma restrict_references (validate_agency, WNDS);
--
--
Procedure sf113a_sec1 (	 p_rpt_date	       IN              date
			,p_empl_as_of_date     IN              date
			,p_agcy	               IN              varchar2
			,p_segment	       IN              varchar2
			,p_l1a                 IN OUT NOCOPY   number
                        ,p_l1b                 IN OUT NOCOPY   number
                        ,p_l1c                 IN OUT NOCOPY   number
                        ,p_l1d                 IN OUT NOCOPY   number
                        ,p_l1e                 IN OUT NOCOPY   number
                        ,p_l2a                 IN OUT NOCOPY   number
                        ,p_l2b                 IN OUT NOCOPY   number
                        ,p_l2c                 IN OUT NOCOPY   number
                        ,p_l2d                 IN OUT NOCOPY   number
                        ,p_l2e                 IN OUT NOCOPY   number
                        ,p_l3a                 IN OUT NOCOPY   number
                        ,p_l3b                 IN OUT NOCOPY   number
                        ,p_l3c                 IN OUT NOCOPY   number
                        ,p_l3d                 IN OUT NOCOPY   number
                        ,p_l3e                 IN OUT NOCOPY   number
                        ,p_l4a                 IN OUT NOCOPY   number
                        ,p_l4b                 IN OUT NOCOPY   number
                        ,p_l4c                 IN OUT NOCOPY   number
                        ,p_l4d                 IN OUT NOCOPY   number
                        ,p_l4e                 IN OUT NOCOPY   number
                        ,p_l5a                 IN OUT NOCOPY   number
                        ,p_l5b                 IN OUT NOCOPY   number
                        ,p_l5c                 IN OUT NOCOPY   number
                        ,p_l5d                 IN OUT NOCOPY   number
                        ,p_l5e                 IN OUT NOCOPY   number
                        ,p_l6a                 IN OUT NOCOPY   number
                        ,p_l6b                 IN OUT NOCOPY   number
                        ,p_l6c                 IN OUT NOCOPY   number
                        ,p_l6d                 IN OUT NOCOPY   number
                        ,p_l6e                 IN OUT NOCOPY   number
                        ,p_l7a                 IN OUT NOCOPY   number
                        ,p_l7b                 IN OUT NOCOPY   number
                        ,p_l7c                 IN OUT NOCOPY   number
                        ,p_l7d                 IN OUT NOCOPY   number
                        ,p_l7e                 IN OUT NOCOPY   number
                        ,p_l8a                 IN OUT NOCOPY   number
                        ,p_l8b                 IN OUT NOCOPY   number
                        ,p_l8c                 IN OUT NOCOPY   number
                        ,p_l8d                 IN OUT NOCOPY   number
                        ,p_l8e                 IN OUT NOCOPY   number
                        ,p_l9a                 IN OUT NOCOPY   number
                        ,p_l9b                 IN OUT NOCOPY   number
                        ,p_l9c                 IN OUT NOCOPY   number
                        ,p_l9d                 IN OUT NOCOPY   number
                        ,p_l9e                 IN OUT NOCOPY   number
                        ,p_l10a                IN OUT NOCOPY   number
                        ,p_l10b                IN OUT NOCOPY   number
                        ,p_l10c                IN OUT NOCOPY   number
                        ,p_l10d                IN OUT NOCOPY   number
                        ,p_l10e                IN OUT NOCOPY   number
                        ,p_l11a                IN OUT NOCOPY   number
                        ,p_l11b                IN OUT NOCOPY   number
                        ,p_l11c                IN OUT NOCOPY   number
                        ,p_l11d                IN OUT NOCOPY   number
                        ,p_l11e                IN OUT NOCOPY   number
                        ,p_l12a                IN OUT NOCOPY   number
                        ,p_l12b                IN OUT NOCOPY   number
                        ,p_l12c                IN OUT NOCOPY   number
                        ,p_l12d                IN OUT NOCOPY   number
                        ,p_l12e                IN OUT NOCOPY   number
                        ,p_l13a                IN OUT NOCOPY   number
                        ,p_l13b                IN OUT NOCOPY   number
                        ,p_l13c                IN OUT NOCOPY   number
                        ,p_l13d                IN OUT NOCOPY   number
                        ,p_l13e                IN OUT NOCOPY   number
                        ,p_l14a                IN OUT NOCOPY   number
                        ,p_l14b                IN OUT NOCOPY   number
                        ,p_l14c                IN OUT NOCOPY   number
                        ,p_l14d                IN OUT NOCOPY   number
                        ,p_l14e                IN OUT NOCOPY   number
                        ,p_l15a                IN OUT NOCOPY   number
                        ,p_l15b                IN OUT NOCOPY   number
                        ,p_l15c                IN OUT NOCOPY   number
                        ,p_l15d                IN OUT NOCOPY   number
                        ,p_l15e                IN OUT NOCOPY   number
                        ,p_l16a                IN OUT NOCOPY   number
                        ,p_l16b                IN OUT NOCOPY   number
                        ,p_l16c                IN OUT NOCOPY   number
                        ,p_l16d                IN OUT NOCOPY   number
                        ,p_l16e                IN OUT NOCOPY   number
                        ,p_l29a                IN OUT NOCOPY   number
                        ,p_l29b                IN OUT NOCOPY   number
                        ,p_l29c                IN OUT NOCOPY   number
                        ,p_l29d                IN OUT NOCOPY   number
                        ,p_l29e                IN OUT NOCOPY   number
                        ,p_l30a                IN OUT NOCOPY   number
                        ,p_l30b                IN OUT NOCOPY   number
                        ,p_l30c                IN OUT NOCOPY   number
                        ,p_l30d                IN OUT NOCOPY   number
                        ,p_l30e                IN OUT NOCOPY   number);
--
--
--
Procedure sf113a_sec2 (p_agcy                  	IN                varchar2
	              ,p_rpt_date            	IN                date
		      ,p_empl_as_of_date        IN                date
	              ,p_pay_from          	IN                date
	              ,p_pay_to               	IN                date
	              ,p_segment            	IN                varchar2
	              ,p_l17a                   IN OUT NOCOPY     number
                      ,p_l17b                   IN OUT NOCOPY     number
                      ,p_l17c                   IN OUT NOCOPY     number
                      ,p_l17d                   IN OUT NOCOPY     number
                      ,p_l17e                   IN OUT NOCOPY     number
                      ,p_l18a                   IN OUT NOCOPY     number
                      ,p_l18b                   IN OUT NOCOPY     number
                      ,p_l18c                   IN OUT NOCOPY     number
                      ,p_l18d                   IN OUT NOCOPY     number
                      ,p_l18e                   IN OUT NOCOPY     number
                      ,p_l31a                   IN OUT NOCOPY     number
                      ,p_l31b                   IN OUT NOCOPY     number
                      ,p_l31c                   IN OUT NOCOPY     number
                      ,p_l31d                   IN OUT NOCOPY     number
                      ,p_l31e                   IN OUT NOCOPY     number);
--
--
--
Procedure sf113a_sec3 (p_agcy                  	IN   	          varchar2
		      ,p_rpt_date            	IN                date
		      ,p_empl_as_of_date        IN                date
		      ,p_last_rpt_date     	IN                date
		      ,p_pay_from          	IN                date
		      ,p_pay_to               	IN                date
		      ,p_segment             	IN                varchar2
		      ,p_l19a                   IN OUT NOCOPY     number
                      ,p_l19b                   IN OUT NOCOPY     number
                      ,p_l19c                   IN OUT NOCOPY     number
                      ,p_l19d                   IN OUT NOCOPY     number
                      ,p_l19e                   IN OUT NOCOPY     number
                      ,p_l20a                   IN OUT NOCOPY     number
                      ,p_l20b                   IN OUT NOCOPY     number
                      ,p_l20c                   IN OUT NOCOPY     number
                      ,p_l20d                   IN OUT NOCOPY     number
                      ,p_l20e                   IN OUT NOCOPY     number
                      ,p_l21a                   IN OUT NOCOPY     number
                      ,p_l21b                   IN OUT NOCOPY     number
                      ,p_l21c                   IN OUT NOCOPY     number
                      ,p_l21d                   IN OUT NOCOPY     number
                      ,p_l21e                   IN OUT NOCOPY     number
                      ,p_l22a                   IN OUT NOCOPY     number
                      ,p_l22b                   IN OUT NOCOPY     number
                      ,p_l22c                   IN OUT NOCOPY     number
                      ,p_l22d                   IN OUT NOCOPY     number
                      ,p_l22e                   IN OUT NOCOPY     number
                      ,p_l23a                   IN OUT NOCOPY     number
                      ,p_l23b                   IN OUT NOCOPY     number
                      ,p_l23c                   IN OUT NOCOPY     number
                      ,p_l23d                   IN OUT NOCOPY     number
                      ,p_l23e                   IN OUT NOCOPY     number
                      ,p_l24a                   IN OUT NOCOPY     number
                      ,p_l24b                   IN OUT NOCOPY     number
                      ,p_l24c                   IN OUT NOCOPY     number
                      ,p_l24d                   IN OUT NOCOPY     number
                      ,p_l24e                   IN OUT NOCOPY     number
                      ,p_l25a                   IN OUT NOCOPY     number
                      ,p_l25b                   IN OUT NOCOPY     number
                      ,p_l25c                   IN OUT NOCOPY     number
                      ,p_l25d                   IN OUT NOCOPY     number
                      ,p_l25e                   IN OUT NOCOPY     number
                      ,p_l26a                   IN OUT NOCOPY     number
                      ,p_l26b                   IN OUT NOCOPY     number
                      ,p_l26c                   IN OUT NOCOPY     number
                      ,p_l26d                   IN OUT NOCOPY     number
                      ,p_l26e                   IN OUT NOCOPY     number
                      ,p_l27a                   IN OUT NOCOPY     number
                      ,p_l27b                   IN OUT NOCOPY     number
                      ,p_l27c                   IN OUT NOCOPY     number
                      ,p_l27d                   IN OUT NOCOPY     number
                      ,p_l27e                   IN OUT NOCOPY     number
                      ,p_l28a                   IN OUT NOCOPY     number
                      ,p_l28b                   IN OUT NOCOPY     number
                      ,p_l28c                   IN OUT NOCOPY     number
                      ,p_l28d                   IN OUT NOCOPY     number
                      ,p_l28e                   IN OUT NOCOPY     number);
--
--
PROCEDURE ghr_sf113_payroll (	p_pay_from	IN DATE,
				p_pay_to	IN DATE	);
--
--This is the main procedure that generates the XML file for SF113A report.
  PROCEDURE ghr_sf113a_out(errbuf                     OUT NOCOPY VARCHAR2,
                           retcode                    OUT NOCOPY NUMBER,
                           p_agency_code           IN            VARCHAR2,
                           p_agency_subelement     IN            VARCHAR2,
                           p_business_id           IN            NUMBER,
                           p_employment_as_of_date IN            VARCHAR2,
                           p_pay_from              IN            VARCHAR2,
                           p_pay_to                IN            VARCHAR2,
                           p_previous_report_date  IN            VARCHAR2,
                           p_rpt_date              IN            VARCHAR2);
--
--This procedure replaces Zeroes with NULL.
  PROCEDURE repl_zero(p_l1a  IN OUT NOCOPY   number
                     ,p_l1b  IN OUT NOCOPY   number
                     ,p_l1c  IN OUT NOCOPY   number
                     ,p_l1d  IN OUT NOCOPY   number
                     ,p_l1e  IN OUT NOCOPY   number
                     ,p_l2a  IN OUT NOCOPY   number
                     ,p_l2b  IN OUT NOCOPY   number
                     ,p_l2c  IN OUT NOCOPY   number
                     ,p_l2d  IN OUT NOCOPY   number
                     ,p_l2e  IN OUT NOCOPY   number
                     ,p_l3a  IN OUT NOCOPY   number
                     ,p_l3b  IN OUT NOCOPY   number
                     ,p_l3c  IN OUT NOCOPY   number
                     ,p_l3d  IN OUT NOCOPY   number
                     ,p_l3e  IN OUT NOCOPY   number
                     ,p_l4a  IN OUT NOCOPY   number
                     ,p_l4b  IN OUT NOCOPY   number
                     ,p_l4c  IN OUT NOCOPY   number
                     ,p_l4d  IN OUT NOCOPY   number
                     ,p_l4e  IN OUT NOCOPY   number
                     ,p_l5a  IN OUT NOCOPY   number
                     ,p_l5b  IN OUT NOCOPY   number
                     ,p_l5c  IN OUT NOCOPY   number
                     ,p_l5d  IN OUT NOCOPY   number
                     ,p_l5e  IN OUT NOCOPY   number
                     ,p_l6a  IN OUT NOCOPY   number
                     ,p_l6b  IN OUT NOCOPY   number
                     ,p_l6c  IN OUT NOCOPY   number
                     ,p_l6d  IN OUT NOCOPY   number
                     ,p_l6e  IN OUT NOCOPY   number
                     ,p_l7a  IN OUT NOCOPY   number
                     ,p_l7b  IN OUT NOCOPY   number
                     ,p_l7c  IN OUT NOCOPY   number
                     ,p_l7d  IN OUT NOCOPY   number
                     ,p_l7e  IN OUT NOCOPY   number
                     ,p_l8a  IN OUT NOCOPY   number
                     ,p_l8b  IN OUT NOCOPY   number
                     ,p_l8c  IN OUT NOCOPY   number
                     ,p_l8d  IN OUT NOCOPY   number
                     ,p_l8e  IN OUT NOCOPY   number
                     ,p_l9a  IN OUT NOCOPY   number
                     ,p_l9b  IN OUT NOCOPY   number
                     ,p_l9c  IN OUT NOCOPY   number
                     ,p_l9d  IN OUT NOCOPY   number
                     ,p_l9e  IN OUT NOCOPY   number
                     ,p_l10a IN OUT NOCOPY   number
                     ,p_l10b IN OUT NOCOPY   number
                     ,p_l10c IN OUT NOCOPY   number
                     ,p_l10d IN OUT NOCOPY   number
                     ,p_l10e IN OUT NOCOPY   number
                     ,p_l11a IN OUT NOCOPY   number
                     ,p_l11b IN OUT NOCOPY   number
                     ,p_l11c IN OUT NOCOPY   number
                     ,p_l11d IN OUT NOCOPY   number
                     ,p_l11e IN OUT NOCOPY   number
                     ,p_l12a IN OUT NOCOPY   number
                     ,p_l12b IN OUT NOCOPY   number
                     ,p_l12c IN OUT NOCOPY   number
                     ,p_l12d IN OUT NOCOPY   number
                     ,p_l12e IN OUT NOCOPY   number
                     ,p_l13a IN OUT NOCOPY   number
                     ,p_l13b IN OUT NOCOPY   number
                     ,p_l13c IN OUT NOCOPY   number
                     ,p_l13d IN OUT NOCOPY   number
                     ,p_l13e IN OUT NOCOPY   number
                     ,p_l14a IN OUT NOCOPY   number
                     ,p_l14b IN OUT NOCOPY   number
                     ,p_l14c IN OUT NOCOPY   number
                     ,p_l14d IN OUT NOCOPY   number
                     ,p_l14e IN OUT NOCOPY   number
                     ,p_l15a IN OUT NOCOPY   number
                     ,p_l15b IN OUT NOCOPY   number
                     ,p_l15c IN OUT NOCOPY   number
                     ,p_l15d IN OUT NOCOPY   number
                     ,p_l15e IN OUT NOCOPY   number
                     ,p_l16a IN OUT NOCOPY   number
                     ,p_l16b IN OUT NOCOPY   number
                     ,p_l16c IN OUT NOCOPY   number
                     ,p_l16d IN OUT NOCOPY   number
                     ,p_l16e IN OUT NOCOPY   number
                     ,p_l17a IN OUT NOCOPY   number
                     ,p_l17b IN OUT NOCOPY   number
                     ,p_l17c IN OUT NOCOPY   number
                     ,p_l17d IN OUT NOCOPY   number
                     ,p_l17e IN OUT NOCOPY   number
                     ,p_l18a IN OUT NOCOPY   number
                     ,p_l18b IN OUT NOCOPY   number
                     ,p_l18c IN OUT NOCOPY   number
                     ,p_l18d IN OUT NOCOPY   number
                     ,p_l18e IN OUT NOCOPY   number
                     ,p_l19a IN OUT NOCOPY   number
                     ,p_l19b IN OUT NOCOPY   number
                     ,p_l19c IN OUT NOCOPY   number
                     ,p_l19d IN OUT NOCOPY   number
                     ,p_l19e IN OUT NOCOPY   number
                     ,p_l20a IN OUT NOCOPY   number
                     ,p_l20b IN OUT NOCOPY   number
                     ,p_l20c IN OUT NOCOPY   number
                     ,p_l20d IN OUT NOCOPY   number
                     ,p_l20e IN OUT NOCOPY   number
                     ,p_l21a IN OUT NOCOPY   number
                     ,p_l21b IN OUT NOCOPY   number
                     ,p_l21c IN OUT NOCOPY   number
                     ,p_l21d IN OUT NOCOPY   number
                     ,p_l21e IN OUT NOCOPY   number
                     ,p_l22a IN OUT NOCOPY   number
                     ,p_l22b IN OUT NOCOPY   number
                     ,p_l22c IN OUT NOCOPY   number
                     ,p_l22d IN OUT NOCOPY   number
                     ,p_l22e IN OUT NOCOPY   number
                     ,p_l23a IN OUT NOCOPY   number
                     ,p_l23b IN OUT NOCOPY   number
                     ,p_l23c IN OUT NOCOPY   number
                     ,p_l23d IN OUT NOCOPY   number
                     ,p_l23e IN OUT NOCOPY   number
                     ,p_l24a IN OUT NOCOPY   number
                     ,p_l24b IN OUT NOCOPY   number
                     ,p_l24c IN OUT NOCOPY   number
                     ,p_l24d IN OUT NOCOPY   number
                     ,p_l24e IN OUT NOCOPY   number
                     ,p_l25a IN OUT NOCOPY   number
                     ,p_l25b IN OUT NOCOPY   number
                     ,p_l25c IN OUT NOCOPY   number
                     ,p_l25d IN OUT NOCOPY   number
                     ,p_l25e IN OUT NOCOPY   number
                     ,p_l26a IN OUT NOCOPY   number
                     ,p_l26b IN OUT NOCOPY   number
                     ,p_l26c IN OUT NOCOPY   number
                     ,p_l26d IN OUT NOCOPY   number
                     ,p_l26e IN OUT NOCOPY   number
                     ,p_l27a IN OUT NOCOPY   number
                     ,p_l27b IN OUT NOCOPY   number
                     ,p_l27c IN OUT NOCOPY   number
                     ,p_l27d IN OUT NOCOPY   number
                     ,p_l27e IN OUT NOCOPY   number
                     ,p_l28a IN OUT NOCOPY   number
                     ,p_l28b IN OUT NOCOPY   number
                     ,p_l28c IN OUT NOCOPY   number
                     ,p_l28d IN OUT NOCOPY   number
                     ,p_l28e IN OUT NOCOPY   number
                     ,p_l29a IN OUT NOCOPY   number
                     ,p_l29b IN OUT NOCOPY   number
                     ,p_l29c IN OUT NOCOPY   number
                     ,p_l29d IN OUT NOCOPY   number
                     ,p_l29e IN OUT NOCOPY   number
                     ,p_l30a IN OUT NOCOPY   number
                     ,p_l30b IN OUT NOCOPY   number
                     ,p_l30c IN OUT NOCOPY   number
                     ,p_l30d IN OUT NOCOPY   number
                     ,p_l30e IN OUT NOCOPY   number
                     ,p_l31a IN OUT NOCOPY   number
                     ,p_l31b IN OUT NOCOPY   number
                     ,p_l31c IN OUT NOCOPY   number
                     ,p_l31d IN OUT NOCOPY   number
                     ,p_l31e IN OUT NOCOPY   number);
--
--
END ghr_sf113_a;

/
