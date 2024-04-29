--------------------------------------------------------
--  DDL for Package HZ_MIGRATE_MOSR_REFERENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIGRATE_MOSR_REFERENCES" AUTHID CURRENT_USER AS
/* $Header: ARHMPINSS.pls 115.1 2003/07/26 12:03:52 rpalanis noship $ */

PROCEDURE MIGRATE_PARTY_REFERENCES(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, l_batch_size IN varchar2);

END;

 

/
