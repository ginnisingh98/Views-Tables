--------------------------------------------------------
--  DDL for Package GMP_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: GMPWITMS.pls 115.1 2002/10/25 16:09:02 sgidugu ship $ */

/* PROCEDURE log_message(string IN VARCHAR2); */

PROCEDURE get_items(
                    errbuf          OUT NOCOPY VARCHAR2,
                    retcode         OUT NOCOPY VARCHAR2,
                    p_plant_code    IN  VARCHAR2
                    );
END gmp_items_pkg;

 

/
