--------------------------------------------------------
--  DDL for Package PER_FNAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FNAME_PKG" AUTHID CURRENT_USER AS
/* $Header: pepefnam.pkh 115.0 2003/01/07 05:03:51 fsheikh noship $ */

procedure REBUILD_FULLNAME ( errbuf out NOCOPY varchar2,
                             retcode out NOCOPY NUMBER,
                             p_legislation_code varchar2);


END PER_FNAME_PKG;


 

/
