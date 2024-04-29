--------------------------------------------------------
--  DDL for Package POS_SUP_PROF_PRG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUP_PROF_PRG_GRP" AUTHID CURRENT_USER as
/* $Header: POSSPPGS.pls 115.1 2003/01/03 19:30:30 bfreeman noship $ */

procedure handle_purge(
        x_return_status     OUT NOCOPY VARCHAR2);

END POS_SUP_PROF_PRG_GRP;

 

/
