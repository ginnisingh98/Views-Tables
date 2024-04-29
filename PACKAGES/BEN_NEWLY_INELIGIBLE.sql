--------------------------------------------------------
--  DDL for Package BEN_NEWLY_INELIGIBLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_NEWLY_INELIGIBLE" AUTHID CURRENT_USER as
/* $Header: beninelg.pkh 120.1.12010000.1 2008/07/29 12:26:09 appldev ship $ */
-----------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
	Manage Newly Ineligible Persons
Purpose
	This package is used to find out whether the person is covered under the
      Program/Plan or OIPL for which he is newly ineligible. And if covered,
      it calls the deenrollment API to deenroll the person.

History
	Date             Who           Version    What?
	----             ---           -------    -----
	28  May 98       J Mohapatra   110.0      Created.
	31  Aug 99       mhoyes        115.1    - Modified g_package
                                                  variable.
        19  Jul 04       bmanyam       115.4      Added 'WHENEVER OSERROR...'
        16  Nov 06       abparekh      115.6      Bug 5642702 : Defined global G_DENROLING_FROM_PGM
	05 Apr  05       rtagarra      115.7      Bug 6000303 : Added procedure defer_delete_enrollment.
*/
-----------------------------------------------------------------------
g_package   varchar2(50) := 'ben_newly_ineligible';
-- Bug 5642702
-- This variable will be set to Y, when a person is de-enroling from the program. So that we can
-- obviate all calls that create/update records in ledger BEN_BNFT_PRVDD_LDGR_F table.
--
g_denroling_from_pgm     varchar2(30) := 'N';
--
procedure main
	  (p_person_id                in number,
	   p_pgm_id                   in number default null,
	   p_pl_id                    in number default null,
	   p_oipl_id                  in number default null,
	   p_business_group_id        in number,
	   p_ler_id                   in number,
	   p_effective_date           in date  );

procedure defer_delete_enrollment
		( p_per_in_ler_id	     in number
		 ,p_person_id		     in number
		 ,p_business_group_id        in number
		 ,p_effective_date           in date
                );
END;

/
