--------------------------------------------------------
--  DDL for Package OKC_ARTICLES_MIGRATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLES_MIGRATE_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGARTMIGS.pls 120.0 2005/05/25 23:15:03 appldev noship $ */



  TYPE article_txt_tbl_type is table of OKC_ART_INTERFACE_ALL.ARTICLE_TEXT%TYPE ;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

/*===================================================
 | PROCEDURE conc_migrate_articles
 |           conc. program wrapper for migrate_articles
 |           This will internally call the main API.
 |           Parameters passed are
 |           1. p_fetchsize is fetch and/or commit size for BULK operations
 +==================================================*/
  PROCEDURE conc_migrate_articles(
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY VARCHAR2,
    p_fetchsize      IN  NUMBER  := 100 );


/*===================================================
 | PROCEDURE migrate articles
 |           The users can specify if this is to be run only for an org.
 |           The default behavior is to run for all orgs that are setup
 |           through HR Org EITs.
 |           If the user specifies that this is for the current org and that
 |           belongs to the Global Org, this will be run as a regular migration
 |           The users will need to specify a batch size or commit size.
 |
 |           Parameters passed are
 |           1. p_fetchsize is fetch and/or commit size for BULK operations
 +==================================================*/
  PROCEDURE migrate_articles(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fetchsize                    IN NUMBER := 100
  );


END OKC_ARTICLES_MIGRATE_GRP;

 

/
