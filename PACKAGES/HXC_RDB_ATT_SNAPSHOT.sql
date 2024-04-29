--------------------------------------------------------
--  DDL for Package HXC_RDB_ATT_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RDB_ATT_SNAPSHOT" AUTHID CURRENT_USER as
/* $Header: hxcrdbsnpsht.pkh 120.1.12010000.7 2010/04/02 12:36:26 sabvenug noship $ */

g_debug boolean := hr_utility.debug_enabled;

PROCEDURE generate_attribute_info(errbuff   OUT NOCOPY VARCHAR2,
                                  retcode   OUT NOCOPY NUMBER);


end;

/
